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

lexparser.sh "$qfile"