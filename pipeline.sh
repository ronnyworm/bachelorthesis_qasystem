#!/bin/bash

debug=0
db="relations.db"
corpus="corpora/CloudComputing.txt"
question_relation_file="question_relation.txt"

if [[ -f pipeline_log.md ]]; then
	printf "# Pipeline Log\n\n## Inhalt\n\n## Ausführungen" > pipeline_log.md
fi

printf "\n\n### $(date +"%Y-%m-%d %H:%M")\n" >> pipeline_log.md

#q="Is he one of a kind?"
#q="Is it true that he built this house?" -> ein Ergebnis bei den Tabellen
#q="Where has he found the truth?"	# -> drei Ergebnisse bei den Tabellen
#q="Did he ever find the error?" # -> gesamte pipeline
#q="How many tables are in this room?" # -> keine Tabellen


# Parameterhandling
if [ $# -eq 0 ]; then
	cat << EOF
Frage-Antwort-System - Prototyp

Als erster Parameter kann dbready übergeben werden, wenn die Datenbank bereits erzeugt wurde, ansonsten wird sie neu erstellt.
Als zweiter Parameter kann eine erste Frage übergeben werden, ansonsten wird die erste Frage zur Laufzeit aufgenommen.
Als dritter Parameter kann justonce übergeben werden, damit nur eine einzige Frage bearbeitet wird.

EOF
fi



if [[ $1 == "dbready" ]]; then
	if [ $debug -eq 1 ]; then
		echo "Database already constructed."
	fi
else
	if [ $debug -eq 1 ]; then
		echo "Construct database ..."
	fi

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

	printf "q: $q ($(date +"%H:%M"))\n\n" >> pipeline_log.md

	qfile="question.txt"
	echo "$q" > $qfile

	./process_question.sh $qfile $question_relation_file
	result_process_question=$?

	if [ $result_process_question -eq 1 ]; then
		./process_question_stanford.sh $qfile $question_relation_file
		result_process_question_stanford=$?

		if [ $result_process_question_stanford -eq 1 ]; then
			echo "I do not understand your question, sorry."
			return
		fi
	elif [ $result_process_question -eq 2 ]; then
		echo "Internal Error 1"
		exit
	else
		printf "\tExtraktion mit ReVerb erfolgreich\n" >> pipeline_log.md
	fi

	rm question.txt

	if [[ $(wc -l $question_relation_file | xargs | cut -f1 -d\ ) -gt 3 ]]; then
		echo "Internal error 2"
		if [ $debug -eq 1 ]; then
			printf "\t\$question_relation_file hat mehr als drei Zeilen ... Abbruch dieser Frage\n----\n" >> pipeline_log.md
		fi
		return
	fi

	question_verb="$(awk 'NR == 2' $question_relation_file)"
	syns=$(./get_synonyms.py "$question_verb" v 2)
	printf "\tgefundene Synonyme zum question verb ($question_verb): $syns\n" >> pipeline_log.md

	# Warte auf process_corpus
	if [[ $1 != "dbready" ]]; then
		wait %1
		process_corpus_result=$?
		if [ $process_corpus_result -eq 1 ]; then
			echo "I could not find the document. I must terminate this session, sorry."
			printf "\tprocess_corpus hat den Korpus nicht gefunden ... Abbruch komplett\n----\n" >> pipeline_log.md
			exit
		fi
	fi

	printf "\n\t$question_relation_file:\n" >> pipeline_log.md
	awk '{printf "\t"$0"\n";}' $question_relation_file >> pipeline_log.md

	tables=$(./get_matching_table_names.py $db "$question_verb" "$syns")
	printf "\tgefundene Tabellen: $tables\n" >> pipeline_log.md

	if [ ! -z "$tables" ]; then
		answers=$(./print_matches_in_tables.py $db $question_relation_file "$tables")
		if [ -z "$answers" ]; then
			echo "Unfortunately I can't find information about your question."	
			printf "\tkeine Antwort gefunden\n\n" >> pipeline_log.md
		else
			echo "$answers"
			printf "\n\ngefundene Antworten: $answers\n\n" >> pipeline_log.md
		fi
	else
		echo "Sorry, I don't know the answer."
	fi
}


qasystem "$@"
if [ -z "$justonce" ]; then
	while [ 1 ]; do
	   qasystem
	done
fi