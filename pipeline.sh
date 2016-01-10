#!/bin/bash



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

log(){
	s="$1"
	if [[ "$2" == *with_echo* ]]; then
		echo "$s"

		if [[ "$2" == *no_tab* ]]; then
			printf ">$s\n" >> pipeline_log.md
		else
			printf "\t>$s\n" >> pipeline_log.md

		fi
	else
		printf "$s" >> pipeline_log.md
	fi
}



# Variablen und Start
db="relations.db"
corpus="corpora/CloudComputing.txt"
question_relation_file="question_relation.txt"
answer_file="answers.txt"

if [[ ! -f pipeline_log.md ]]; then
	cp new_pipeline_log.md pipeline_log.md
fi

lastcommit=$(git rev-parse HEAD)
log "\n\n### $(date +"%Y-%m-%d %H:%M") - ${lastcommit:0:6}\n"



if [[ $1 == "dbready" ]]; then
	log "Datenbank wird aufgrund der Übergabe des Parameters dbready nicht neu erstellt.\n\n"
else
	log "parallel: Beginne process_corpus.sh\n\n"

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
	fi

	log "\n<span class='big'>q: $q ($(date +"%H:%M:%S"))</span>\n\n"


	last_index=${#q} && last_index=$(($last_index-1))
	last=${q:$last_index}
	number_of_question_marks=$(grep -o "?" <<< "$q" | wc -l | xargs)

	if [[ $last != "?" || $number_of_question_marks -eq 0 ]]; then
		log "Please pose one question only." with_echo
		log "\tlast($last) != ? || number_of_question_marks($number_of_question_marks) -eq 0\n\n"
		return
	elif [[ $number_of_question_marks -gt 1 ]]; then
		log "Please pose only one question at a time." with_echo
		log "\tnumber_of_question_marks($number_of_question_marks) -gt 1\n\n"
		return
	fi


	qfile="question.txt"
	echo "$q" > $qfile

	./process_question_reverb.sh $qfile $question_relation_file
	result_process_question_reverb=$?

	if [ $result_process_question_reverb -eq 1 ]; then
		./process_question_stanford.sh $qfile $question_relation_file
		result_process_question_stanford=$?

		if [ $result_process_question_stanford -eq 1 ]; then
			log "I do not understand your question, sorry." with_echo
			return
		fi
	elif [ $result_process_question_reverb -eq 2 ]; then
		log "Internal Error 1" with_echo
		exit
	else
		log "\tExtraktion mit ReVerb erfolgreich\n"
	fi

	rm question.txt

	log "\n\t$question_relation_file:\n"
	awk '{printf "\t"$0"\n";}' $question_relation_file >> pipeline_log.md

	if [[ $(wc -l $question_relation_file | xargs | cut -f1 -d\ ) -gt 3 ]]; then
		log "Internal error 2" with_echo
		log "\t\$question_relation_file hat mehr als drei Zeilen ... Abbruch dieser Frage\n\n"
		return
	fi




	predicate_synonyms_file="predicate_synonyms.txt"
	question_verb="$(awk 'NR == 2' $question_relation_file)"
	./get_synonyms.py "$question_verb" $predicate_synonyms_file v 2
	result_get_synonyms=$?

	if [ $result_get_synonyms -eq 0 ]; then
		syns=$(cat $predicate_synonyms_file)
		rm $predicate_synonyms_file
		log "\n\tgefundene Synonyme zum question verb ($question_verb): $syns\n"
	else
		log "\n\tget_synonyms Fehler $result_get_synonyms: NLTK kennt $question_verb nicht als Verb. Wahrscheinlich keine Tabellen auffindbar\n"
	fi




	# Warte auf process_corpus
	if [[ $1 != "dbready" ]]; then
		wait %1 2> /dev/null
		process_corpus_result=$?
		if [ $process_corpus_result -eq 1 ]; then
			log "I could not find the document. I must terminate this session, sorry." "with_echo no_tab"
			exit
		elif [[ $process_corpus_result -eq 2 ]]; then
			log "There are errors in the document. I must stop, sorry." "with_echo no_tab"
			exit
		fi
	fi






	tables=$(./get_matching_table_names.py $db "$question_verb" "$syns")
	log "\n\tgefundene Tabellen: $tables\n\n"

	if [ -z "$tables" ]; then
		log "Sorry, I don't know the answer." with_echo
		return
	fi


	./print_matches_in_tables.py $db $question_relation_file "$tables" $answer_file
	result_print_matches_in_tables=$?

	if [ $result_print_matches_in_tables -eq 4 ]; then
		log "Please be more specific. Your question was too vague." with_echo	
		return
	elif [ $result_print_matches_in_tables -ne 0 ]; then
		log "\tFehler in print_matches_in_tables ... (Rückgabewert war $result_print_matches_in_tables)\n"
	fi

	if [[ -z "$(cat $answer_file)" ]]; then
		log "Unfortunately I can't find information about your question." with_echo
	else
		sed 's/_/ /g' $answer_file > tmp
		rm $answer_file
		mv tmp $answer_file
		answers=$(cat $answer_file)
		rm $answer_file
		echo $answers
		answers_formatted=$(printf "\n$answers" | tr '\n' '#' | sed -E $'s/#/\\\n- /g')
		log "\n\ngefundene Antworten:\n$answers_formatted\n\n"
	fi
}








qasystem "$@"
result=$?

if [[ $result -eq 1 ]]; then
	all_questions_file="$2"
	dbready="$1"

	log "\n\n**Start einer Batchverarbeitung mit Datei:** <code>$all_questions_file</code>\n\n"

	#Sonst wird evtl die letzte Zeile weggelassen
	printf "\n" >> $all_questions_file

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