#!/bin/bash

#corpora=( SEM CloudComputing )
corpora=( CloudComputing )

for corpus in "${corpora[@]}"; do
    echo $corpus
    ./pipeline.sh corpora/$corpus.txt corpora/test_questions_$corpus.txt

    # Nach der Ausführung wird im Logfile ab der letzten Zeile gesucht, in der Batch steht
    start_line_in_log=$(grep -n Batch pipeline_log.md | cut -f1 -d: | tail -n 1)
	tail -n+$start_line_in_log pipeline_log.md > current_batch.txt

    # Dann werden alle "q:" gesucht
    # Davon werden die Zeilennummern gefunden und dann wird wieder ab dem hinteren Teil gesucht, damit nur die Antworten der aktuellen Frage in eine eigene Datei kommen
	IFS=' ' read -r -a question_boundaries <<< "$(cat current_batch.txt | grep -n q: | cut -f1 -d: | tr '\n' ' ')"


    question_count=$(sed '/^$/d' corpora/test_questions_$corpus.txt | wc -l | xargs)

    if [[ $question_count -ne ${#question_boundaries[@]} ]]; then
        echo "Die Anzahl der gefundenen Fragen im Logfile (${#question_boundaries[@]}) muss mit der Anzahl der Fragen im Fragedokument ($question_count) übereinstimmen"
        exit
    fi

    scores=""
    counts=""

	next_index=1
    question_index=1
	for start_line in "${question_boundaries[@]}" ; do
        question=$(awk -v line=$question_index 'NR==line' corpora/test_questions_$corpus.txt)
		echo "$question: $start_line - ${question_boundaries[next_index]}"

        if [[ ! -z ${question_boundaries[next_index]} ]]; then
            difference=$((${question_boundaries[next_index]}-$start_line))
            tail -n+$start_line current_batch.txt | head -n $difference > current_question_section.txt

        else
            tail -n+$start_line current_batch.txt > current_question_section.txt
        fi

        grep -A 50 "gefundene Antworten:" current_question_section.txt | tail -n+2 > current_answer_section.txt

        score=0
        count=0
        if [[ ! -z $(cat current_answer_section.txt) ]]; then
            # Antworten greppen nach einzelnen Wörtern
            # Wenn zwei von drei gefunden werden macht das einen Score von 0,666
            answer_words=$(awk -v line=$question_index 'NR==line' corpora/test_answers_$corpus.csv)

            echo "$answer_words" | tr ";" "\n" | xargs -I % echo "%" > word_file.txt
            while read word; do
                found=$(grep "$word" current_answer_section.txt)
                if [[ ! -z "$found" ]]; then
                    score=$(($score+1))
                fi
                count=$(($count+1))
            done <word_file.txt
        fi
        
        if [[ $question_index -eq 1 ]]; then
            scores="$score"
            counts="$count"
        else
            scores="$scores+$score"
            counts="$counts+$count"
        fi

        printf "$score/$count\n"


        next_index=$(($next_index+1))
		question_index=$(($question_index+1))
	done

    # Nullen am Ende entfernen mit sed
    ratio=$(bc -l <<< "($scores)/($counts)" | sed -E 's/0+$//g')
    echo $ratio

done

rm word_file.txt
rm current_batch.txt
rm current_question_section.txt
rm current_answer_section.txt