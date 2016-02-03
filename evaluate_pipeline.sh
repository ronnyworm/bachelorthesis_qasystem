#!/bin/bash

corpora=( Twenty_Years_of_South_African_Democracy application-for-a-u.s.-passport Introduction-to-Cloud-Computing )

for corpus in "${corpora[@]}"; do
    echo $corpus
    time ./pipeline.sh corpora/$corpus.txt corpora/test_questions_$corpus.txt
done