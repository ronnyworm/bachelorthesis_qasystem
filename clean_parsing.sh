#!/bin/bash



if [ $# -eq 0 ]; then
    cat << EOF
Als erster Parameter muss die Anzahl der Zeilen nach den Matches übergeben werden (wahrscheinlich 1 oder 2).
Als zweiter Parameter müssen die Patterns übergeben werden, nach denen gesucht werden soll (wahrscheinlich etwa so: -e VBD -e VBZ).
Als erster Parameter kann auch "nogrep" übergeben werden, dann wird direkt mit sed begonnen - dabei wird die Datei verarbeitet, die als zweiter Parameter übergeben wird.

EOF
    exit
fi

after="$1"
patterns="$2"

if [ "$1" == "nogrep" ]; then
	cat "$2" | sed -E -e 's/^[ \t]*//' -e 's/\([A-Z]{2,} ?//g' -e 's/)//g'
else
	grep -A $after -B 1 $patterns result.txt | sed -E -e 's/^[ \t]*//' -e 's/\([A-Z]{2,} ?//g' -e 's/)//g'
fi