#!/bin/bash

if [ $# -eq 0 ]; then
    echo -n "Ask a question about OpenAL: "
    read q
else
	q="$1"
fi

echo "$q" > question.txt

echo "Process question ..."
java -Xmx512m -jar ReVerb/reverb-latest.jar question.txt 2> /dev/null | awk -v FS="\t" '{printf("%s\n%s\n%s\n", $16, $17, $18)}' > question_normalised.txt 
rm question.txt

file_size_kb=`du -k "question_normalised.txt" | cut -f1`


if [ $file_size_kb -eq 0 ]; then
	echo "Your question could not be processed, sorry."
	exit 1
else
	#cat question_normalised.txt
	exit 0
fi
