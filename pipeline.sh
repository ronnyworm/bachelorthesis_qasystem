#!/bin/bash

debug=0
db="relations.db"
qfile="question_normalised.txt"
reverbout="output"
corpus="corpora/OpenAL_1_ausschnitt.txt"

#q="Is he one of a kind?"
#q="Is it true that he built this house?" -> ein Ergebnis bei den Tabellen
#q="Where has he found the truth?"	# -> drei Ergebnisse bei den Tabellen
#q="Did he ever find the error?" # -> gesamte pipeline
#q="How many tables are in this room?" # -> keine Tabellen

process_corpus(){
	java -Xmx512m -jar ReVerb/reverb-latest.jar "$corpus" > $reverbout.txt 2> /dev/null
	echo "filename;sentence number;arg1;rel;arg2;arg1 start;arg1 end;rel start;rel end;arg2 start;arg2 end;conf;sentence words;sentence pos tags;sentence chunk tags;arg1 normalized;rel normalized;arg2 normalized" > $reverbout.csv
	sed 's/	/;/g' $reverbout.txt >> $reverbout.csv
	rm $reverbout.txt

	./relation_extract.py $reverbout.csv $db
	echo "done pc"
}


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

	echo "start pc"
	process_corpus &
fi	

if [ $# -eq 2 ]; then
	q="$2"
fi




if [ -z "$q" ]; then
    echo -n "Ask a question about the document(s) in '$corpus': "
    read q
fi
echo "start pq"
./process_question.sh "$q"
res=$?
if [ $res -eq 1 ]; then
	exit
fi

question_verb="$(awk 'NR == 2' $qfile)"
echo "start gs"
syns=$(./get_synonyms.py "$question_verb" v 2)

echo "wait"

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