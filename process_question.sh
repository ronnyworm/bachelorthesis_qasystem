#!/bin/bash

debug=0


if [ $# -eq 0 ]; then
    cat << EOF
Als erster Parameter muss die Frage übergeben werden.
EOF
    exit
fi

q="$1"
echo "$q" > question.txt

if [ $debug -eq 1 ]; then
	echo "Process question ..."
fi
java -Xmx512m -jar ReVerb/reverb-latest.jar question.txt 2> /dev/null | awk -v FS="\t" '{printf("%s\n%s\n%s\n", $16, $17, $18)}' > question_relation.txt 
rm question.txt

#vll lieber mit $() ?
file_size_kb=`du -k "question_relation.txt" | cut -f1`


if [ $file_size_kb -eq 0 ]; then
	exit 1
else
	if [ $debug -eq 1 ]; then
		cat question_relation.txt
	fi
	exit 0
fi