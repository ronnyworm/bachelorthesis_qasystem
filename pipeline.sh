#!/bin/bash

java -Xmx512m -jar ReVerb/reverb-latest.jar corpora/OpenAL_1_ausschnitt.txt > output.txt
echo "filename;sentence number;arg1;rel;arg2;arg1 start;arg1 end;rel start;rel end;arg2 start;arg2 end;conf;sentence words;sentence pos tags;sentence chunk tags;arg1 normalized;rel normalized;arg2 normalized" > output.csv
sed 's/	/;/g' output.txt >> output.csv
rm output.txt

./relation_extract.py output.csv relations.db
./process_question.sh
question_verb="$(awk 'NR == 2' question_normalised.txt)"
syns=$(./get_synonyms.py "$question_verb" 2)
./get_matching_table_names.py relations.db "$question_verb" "$syns"


rm question_normalised.txt

# next: Synonyme zur question finden und Ähnlichkeit zu Tabellennamen herausfinden