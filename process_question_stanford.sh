#!/bin/bash

debug=0


if [ $# -ne 2 ]; then
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

cd "Stanford OpenIE"
#Es wird nur die erste Extraktion betrachtet (NR==1)
java -mx1g -cp stanford-openie.jar:stanford-openie-models.jar:slf4j.jar edu.stanford.nlp.naturalli.OpenIE "../$qfile" 2> /dev/null | awk -v FS="\t" 'NR==1{printf("%s\n%s\n%s\n", $2, $3, $4)}' > "../$resultfile"
cd ..


if [[ -z "$(cat $resultfile)" ]]; then
	echo "Aaaahh"
	exit 1
fi