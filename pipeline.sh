#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Construct database ..."
	java -Xmx512m -jar ReVerb/reverb-latest.jar corpora/OpenAL_1_ausschnitt.txt > output.txt 2> /dev/null
	echo "filename;sentence number;arg1;rel;arg2;arg1 start;arg1 end;rel start;rel end;arg2 start;arg2 end;conf;sentence words;sentence pos tags;sentence chunk tags;arg1 normalized;rel normalized;arg2 normalized" > output.csv
	sed 's/	/;/g' output.txt >> output.csv
	rm output.txt
else
	echo "Database already constructed."
fi

db="relations.db"
qfile="question_normalised.txt"

./relation_extract.py output.csv $db

#q="Is he one of a kind?"
#q="Is it true that he built this house?" -> ein Ergebnis bei den Tabellen
#q="Where has he found the truth?"	# -> drei Ergebnisse bei den Tabellen
q="Did he ever find the error?"
#./process_question.sh "How many tables are in this room?"
./process_question.sh "$q"
res=$?

if [ $res -eq 1 ]; then
	exit
fi

question_verb="$(awk 'NR == 2' $qfile)"
syns=$(./get_synonyms.py "$question_verb" v 2)
#echo "syns: $syns"
tables=$(./get_matching_table_names.py $db "$question_verb" "$syns")

./print_matches_in_tables.py $db $qfile "$tables"