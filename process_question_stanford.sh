#!/bin/bash

debug=0


if [ $# -eq 0 ]; then
    cat << EOF
Als erster Parameter muss die Datei mit der Frage übergeben werden.
EOF
    exit
fi

qfile="$1"

if [ ! -f "$qfile" ]; then
	>&2 echo "Das Dokument $qfile existiert nicht!"
	exit 2
fi

#java -Xmx512m -jar ReVerb/reverb-latest.jar "$qfile" 2> /dev/null > result.txt
#if [[ -z "$(cat result.txt)" ]]; then
if [[ 1 ]]; then
	lexparser.sh "$qfile" 2> /dev/null > result.txt


	./clean_parsing.sh 1 "-e VBD -e VBZ" > tmp_relation.txt

	if [[ -z "$(cat tmp_relation.txt)" ]]; then
		# nach VB suchen
		grep -A 10 -B 1 -e VB[[:space:]] result.txt > tmptmp.txt
		cat tmptmp.txt | head -n $(grep -n NN tmptmp.txt | cut -f1 -d:) > tmptmptmp.txt
		./clean_parsing.sh nogrep tmptmptmp.txt
	fi

	#kein object direkt eine Zeile nach dem Prädikat gefunden im Parsing-Ergebnis
	if [[ -z "$(awk 'NR == 3' tmp_relation.txt)" ]]; then
		./clean_parsing.sh 1 "-e VBD -e VBZ" | awk 'NR != 3' > tmp_relation.txt
	fi

	cat tmp_relation.txt
else
	cat result.txt
fi