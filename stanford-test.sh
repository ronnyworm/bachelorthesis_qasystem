#!/bin/bash

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
./process_question_stanford.sh file.txt
rm file.txt