#!/bin/bash

debug=0


if [ $# -eq 0 ]; then
    cat << EOF
Als erster Parameter muss die Datei mit der Frage übergeben werden.
Als zweiter Parameter die Datei, in der die Fragerelation abgelegt werden soll.
EOF
    exit
fi

qfile="$1"
resultfile="$2"

if [ ! -f "$qfile" ]; then
	>&2 echo "Das Dokument $qfile existiert nicht!"
	exit 2
fi

if [ $debug -eq 1 ]; then
	echo "Process question ..."
fi
java -Xmx512m -jar ReVerb/reverb-latest.jar "$qfile" 2> /dev/null | awk -v FS="\t" '{printf("%s\n%s\n%s\n", $16, $17, $18)}' > "$resultfile"


if [[ -z "$(cat $resultfile)" ]]; then
	exit 1
else
	if [ $debug -eq 1 ]; then
		cat "$resultfile"
	fi
	exit 0
fi