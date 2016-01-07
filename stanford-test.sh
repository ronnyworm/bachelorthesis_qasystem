#!/bin/bash

# Aufruf:
# cat test_questions.txt | xargs -I % ./stanford-test.sh "%"

if [ -z "$1" ]; then
	read q
else
	q="$1"
fi

if [[ "$q" == _* ]]; then
	exit
fi

echo "$q"
echo "$q" > file.txt
printf "\n\nq: $q ($(date +"%H:%M"))\n\n" >> pipeline_log.md
./process_question_stanford.sh file.txt question_relation.txt
printf "\n\tquestion_relation.txt:\n" >> pipeline_log.md
awk '{printf "\t"$0"\n";}' question_relation.txt >> pipeline_log.md
rm file.txt


cat question_relation.txt