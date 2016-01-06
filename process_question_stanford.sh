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

	rest_of_grep_call=" -B 1 -e VBD -e VBZ result.txt"

	grep -A 1 $rest_of_grep_call | sed -E -e 's/^[ \t]*//' -e 's/\([A-Z]{2,} ?//g' -e 's/)//g' > tmp_relation.txt

	#kein object direkt eine Zeile nach dem Prädikat gefunden im Parsing-Ergebnis
	if [[ -z "$(awk 'NR == 3' tmp_relation.txt)" ]]; then
		grep -A 2 $rest_of_grep_call | awk 'NR != 3' | sed -E -e 's/^[ \t]*//' -e 's/\([A-Z]{2,} ?//g' -e 's/)//g' > tmp_relation.txt
	fi
else
	cat result.txt
fi

cat tmp_relation.txt