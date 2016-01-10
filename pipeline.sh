#!/bin/bash

db="relations.db"
corpus="corpora/CloudComputing.txt"
question_relation_file="question_relation.txt"
answer_file="answers.txt"

if [[ ! -f pipeline_log.md ]]; then
	cp new_pipeline_log.md pipeline_log.md
fi

lastcommit=$(git rev-parse HEAD)
printf "\n\n### $(date +"%Y-%m-%d %H:%M") - ${lastcommit:0:6}\n" >> pipeline_log.md




# Parameterhandling
if [ $# -eq 0 ]; then
	cat << EOF
Frage-Antwort-System - Prototyp

Als erster Parameter kann dbready übergeben werden, wenn die Datenbank bereits erzeugt wurde, ansonsten wird sie neu erstellt.
Als zweiter Parameter kann eine erste Frage übergeben werden, ansonsten wird die erste Frage zur Laufzeit aufgenommen.
Es kann aber auch eine Datei mit durch Zeilenumbrüche getrennte Fragen als zweiter Parameter übergeben werden.
Als dritter Parameter kann justonce übergeben werden, damit nur eine einzige Frage bearbeitet wird.

EOF
fi



if [[ $1 == "dbready" ]]; then
	printf "Datenbank wird aufgrund der Übergabe des Parameters dbready nicht neu erstellt.\n\n" >> pipeline_log.md
else
	printf "parallel: Beginne process_corpus.sh\n\n" >> pipeline_log.md

	./process_corpus.sh "$corpus" $db &
fi	


if [[ $3 == "justonce" ]]; then
	justonce="true"
fi	



qasystem(){
	if [[ $# -lt 2 || -z "$2" ]]; then
	    echo -n "Ask a question about the document(s) in '$corpus': "
	    read q
	else
		q="$2"
	fi

	if [[ -f "$q" ]]; then
		return 1
	else
		printf "q: $q ($(date +"%H:%M:%S"))\n\n" >> pipeline_log.md


		last_index=${#q} && last_index=$(($last_index-1))
		last=${q:$last_index}
		number_of_question_marks=$(grep -o "?" <<< "$q" | wc -l | xargs)

		if [[ $last != "?" || $number_of_question_marks -eq 0 ]]; then
			echo "Please pose one question only."
			printf "\tlast($last) != ? || number_of_question_marks($number_of_question_marks) -eq 0\n\n" >> pipeline_log.md
			return
		elif [[ $number_of_question_marks -gt 1 ]]; then
			echo "Please pose only one question at a time."
			printf "\tnumber_of_question_marks($number_of_question_marks) -gt 1\n\n" >> pipeline_log.md
			return
		fi
	fi


	qfile="question.txt"
	echo "$q" > $qfile






	./process_question_reverb.sh $qfile $question_relation_file
	result_process_question_reverb=$?

	if [ $result_process_question_reverb -eq 1 ]; then
		./process_question_stanford.sh $qfile $question_relation_file
		result_process_question_stanford=$?

		if [ $result_process_question_stanford -eq 1 ]; then
			echo "I do not understand your question, sorry."
			return
		fi
	elif [ $result_process_question_reverb -eq 2 ]; then
		echo "Internal Error 1"
		exit
	else
		printf "\tExtraktion mit ReVerb erfolgreich\n" >> pipeline_log.md
	fi

	rm question.txt

	printf "\n\t$question_relation_file:\n" >> pipeline_log.md
	awk '{printf "\t"$0"\n";}' $question_relation_file >> pipeline_log.md

	if [[ $(wc -l $question_relation_file | xargs | cut -f1 -d\ ) -gt 3 ]]; then
		echo "Internal error 2"
		printf "\t\$question_relation_file hat mehr als drei Zeilen ... Abbruch dieser Frage\n\n----\n" >> pipeline_log.md
		return
	fi





	question_verb="$(awk 'NR == 2' $question_relation_file)"
	syns=$(./get_synonyms.py "$question_verb" v 2)
	printf "\n\tgefundene Synonyme zum question verb ($question_verb): $syns\n" >> pipeline_log.md





	# Warte auf process_corpus
	if [[ $1 != "dbready" ]]; then
		wait %1 2> /dev/null
		process_corpus_result=$?
		if [ $process_corpus_result -eq 1 ]; then
			echo "I could not find the document. I must terminate this session, sorry."
			exit
		elif [[ $process_corpus_result -eq 2 ]]; then
			echo "There are errors in the document. I must stop, sorry."
			exit
		fi
	fi






	tables=$(./get_matching_table_names.py $db "$question_verb" "$syns")
	printf "\n\tgefundene Tabellen: $tables\n" >> pipeline_log.md

	if [ ! -z "$tables" ]; then
		./print_matches_in_tables.py $db $question_relation_file "$tables" $answer_file
		result_print_matches_in_tables=$?

		if [ $result_print_matches_in_tables -eq 4 ]; then
			echo "Please be more specific. Your question was too vague."	
			return
		elif [ $result_print_matches_in_tables -ne 0 ]; then
			printf "\tFehler in print_matches_in_tables ... (Rückgabewert war $result_print_matches_in_tables)\n" >> pipeline_log.md
		fi

		if [[ -z "$(cat $answer_file)" ]]; then
			echo "Unfortunately I can't find information about your question."	
			printf "\tkeine Antwort gefunden\n\n" >> pipeline_log.md
		else
			sed 's/_/ /g' $answer_file > tmp
			rm $answer_file
			mv tmp $answer_file
			answers=$(cat $answer_file)
			rm $answer_file
			echo $answers
			answers_formatted=$(printf "\n$answers" | tr '\n' '#' | sed -E $'s/#/\\\n- /g')
			printf "\n\ngefundene Antworten:\n$answers_formatted\n\n" >> pipeline_log.md
		fi
	else
		echo "Sorry, I don't know the answer."
	fi
}


qasystem "$@"
result=$?

if [[ $result -eq 1 ]]; then
	all_questions_file="$2"
	dbready="$1"

	printf "\n\n**Start einer Batchverarbeitung mit Datei:** <code>$all_questions_file</code>\n\n" >> pipeline_log.md


	while read line; do
		if [[ "$line" != _* && $line != "" ]]; then
			qasystem egal "$line"
		fi
	done <"$all_questions_file"
elif [ -z "$justonce" ]; then
	while [ 1 ]; do
		qasystem
	done
fi