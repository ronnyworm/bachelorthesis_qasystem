#!/bin/bash

# Aufruf:
# cat test_questions.txt | xargs -I % ./reverb-test.sh "%"

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

cd ReVerb
java -Xmx512m -jar reverb-latest.jar ../file.txt > question_relation.txt
cd ..

rm file.txt

cat question_relation.txt




