#!/bin/bash

debug=0
db="relations.db"
corpus="corpora/OpenAL_1_ausschnitt.txt"
qfile="question_normalised.txt"

#q="Is he one of a kind?"
#q="Is it true that he built this house?" -> ein Ergebnis bei den Tabellen
#q="Where has he found the truth?"	# -> drei Ergebnisse bei den Tabellen
#q="Did he ever find the error?" # -> gesamte pipeline
#q="How many tables are in this room?" # -> keine Tabellen


if [ $# -eq 0 ]; then
	cat << EOF
Frage-Antwort-System - Prototyp

Als erster Parameter kann dbready übergeben werden, wenn die Datenbank bereits erzeugt wurde, ansonsten wird sie neu erstellt.
Als zweiter Parameter kann eine Frage übergeben werden, ansonsten wird die Frage zur Laufzeit aufgenommen.

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


if [[ $# -ne 2 || -z "$2" ]]; then
    echo -n "Ask a question about the document(s) in '$corpus': "
    read q
else
	q="$2"
fi
./process_question.sh "$q"
res=$?
if [ $res -eq 1 ]; then
	echo "Your question could not be processed, sorry."
	# Hier könnte ich nochmal versuchen, die Frage weiterzuverarbeiten - vll mit dem Stanford-Parser
	exit
fi

question_verb="$(awk 'NR == 2' $qfile)"
syns=$(./get_synonyms.py "$question_verb" v 2)

wait

tables=$(./get_matching_table_names.py $db "$question_verb" "$syns")

if [ ! -z "$tables" ]; then
	answers=$(./print_matches_in_tables.py $db $qfile "$tables")
	if [ -z "$answers" ]; then
		echo "Unfortunately there is no information about your question."	
	else
		echo "$answers"
	fi
else
	echo "Sorry, I don't know the answer."
fi