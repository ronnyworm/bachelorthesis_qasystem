#!/bin/bash


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
	printf "\tin process_question_reverb: Eigentlich unmöglich: Das Dokument $qfile existiert nicht!\n" >> pipeline_log.md

	exit 2
fi

#NR==1 heißt, es wird nur die erste extrahierte Relation weiterverarbeitet
java -Xmx512m -jar ReVerb/reverb-latest.jar "$qfile" 2> /dev/null | awk -v FS="\t" 'NR==1{printf("%s\n%s\n%s\n", $16, $17, $18)}' | sed 's/#//g' > "$resultfile"

# Hat ReVerb etwas extrahieren können?
if [[ -z "$(cat $resultfile)" ]]; then
	# nein ...
	exit 1
fi