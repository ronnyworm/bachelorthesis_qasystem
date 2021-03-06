#!/bin/bash

reverbout="output"

if [ $# -lt 2 ]; then
    cat << EOF
Als erster Parameter muss der Pfad für das zu verarbeitende Dokument angegeben werden.
Als zweiter Parameter muss der Dateiname der Datenbank übergeben werden, in die die Informationen gespeichert werden sollen.

EOF
    exit
fi

corpus="$1"
db="$2"

if [ ! -f "$corpus" ]; then
	printf "\tprocess_corpus hat den Korpus $corpus nicht gefunden ... Abbruch komplett\n\n" >> pipeline_log.md

	exit 1
fi



java -Xmx512m -jar ReVerb/reverb-latest.jar "$corpus" > $reverbout.txt 2> /dev/null
echo "filename;sentence number;arg1;rel;arg2;arg1 start;arg1 end;rel start;rel end;arg2 start;arg2 end;conf;sentence words;sentence pos tags;sentence chunk tags;arg1 normalized;rel normalized;arg2 normalized" > $reverbout.csv
sed -E -e 's/	/;/g' -e 's/"//g' $reverbout.txt >> $reverbout.csv

printf "\n\nparallel: $(wc -l $reverbout.txt | xargs | cut -f1 -d\ ) Relationen von ReVerb aus dem Korpus $corpus extrahiert.\n\n" >> pipeline_log.md
rm $reverbout.txt




./relation_extract.py $reverbout.csv $db 2> rel_extract_errors.txt
result_relation_extract=$?

if [[ ! -z "$(cat rel_extract_errors.txt)" ]]; then
	printf "parallel: es gab Fehler in relation_extract:\n<blockquote class='warning'>" >> pipeline_log.md
	cat rel_extract_errors.txt >> pipeline_log.md
	printf "</blockquote>\n\n" >> pipeline_log.md
fi
rm rel_extract_errors.txt

if [ $result_relation_extract -ne 0 ]; then
	printf "parallel: relation_extract hat einen Fehler verursacht ... Abbruch komplett, sobald Frage verarbeitet wurde\n\n" >> pipeline_log.md

	exit 2
fi