#!/bin/bash

# Aufruf:
# cat test_questions.txt | xargs -I % ./stanford-test.sh "%"

if [ -z "$1" ]; then
	read s
else
	s="$1"
fi

if [[ "$s" == _* ]]; then
	exit
fi

echo "$s"
echo "$s" > file.txt
./process_question_stanford.sh file.txt question_relation.txt
rm file.txt

cat question_relation.txt