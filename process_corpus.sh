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

java -Xmx512m -jar ReVerb/reverb-latest.jar "$corpus" > $reverbout.txt 2> /dev/null
echo "filename;sentence number;arg1;rel;arg2;arg1 start;arg1 end;rel start;rel end;arg2 start;arg2 end;conf;sentence words;sentence pos tags;sentence chunk tags;arg1 normalized;rel normalized;arg2 normalized" > $reverbout.csv
sed 's/	/;/g' $reverbout.txt >> $reverbout.csv
rm $reverbout.txt



./relation_extract.py $reverbout.csv $db