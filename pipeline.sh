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

./relation_extract.py output.csv relations.db

q="Is he one of a kind?"
#./process_question.sh "How many tables are in this room?"
./process_question.sh "$q"
res=$?

if [ $res -eq 1 ]; then
	./process_question_nltk.py "$q"
	exit
fi

question_verb="$(awk 'NR == 2' question_normalised.txt)"
syns=$(./get_synonyms.py "$question_verb" 2)
echo "syns: $syns"
./get_matching_table_names.py relations.db "$question_verb" "$syns"

# find matches in tables

# compose_answers

rm question_normalised.txt