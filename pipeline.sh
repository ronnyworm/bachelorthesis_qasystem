#!/bin/bash

java -Xmx512m -jar ReVerb/reverb-latest.jar corpora/OpenAL_1_ausschnitt.txt > output.txt
echo "filename;sentence number;arg1;rel;arg2;arg1 start;arg1 end;rel start;rel end;arg2 start;arg2 end;conf;sentence words;sentence pos tags;sentence chunk tags;arg1 normalized;rel normalized;arg2 normalized" > output.csv
sed 's/	/;/g' output.txt >> output.csv
rm output.txt

./relation_extract.py
./process_question.sh

# next: Synonyme zur question finden und Ähnlichkeit zu Tabellennamen herausfinden