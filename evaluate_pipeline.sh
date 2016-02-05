#!/bin/bash

corpora=( Introduction-to-Cloud-Computing Twenty_Years_of_South_African_Democracy application-for-a-u.s.-passport )

logfilename="$(date +"%Y-%m-%d_%H-%M")_questions_with_answers.md"

printf "# Fragen mit Antworten\n\n## Inhalt\n\n" > $logfilename

for corpus in "${corpora[@]}"; do
    printf "\n\n\n\n## Korpus $corpus\n" >> $logfilename
    ./pipeline.sh corpora/$corpus.txt corpora/test_questions_$corpus.txt > /dev/null

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


	next_index=1
    question_index=1
	for start_line in "${question_boundaries[@]}" ; do
        question=$(awk -v line=$question_index 'NR==line' corpora/test_questions_$corpus.txt)
		printf "\n\n<span class='big'>$question</span>\n\n" >> $logfilename

        if [[ ! -z ${question_boundaries[next_index]} ]]; then
            difference=$((${question_boundaries[next_index]}-$start_line))
            tail -n+$start_line current_batch.txt | head -n $difference > current_question_section.txt

        else
            tail -n+$start_line current_batch.txt > current_question_section.txt
        fi

        grep -A 50 "gefundene Antworten:" current_question_section.txt | tail -n+2 >> $logfilename

        cat bewertung.html_fragment >> $logfilename


        next_index=$(($next_index+1))
		question_index=$(($question_index+1))
	done

done

cat geschlecht.html_fragment >> $logfilename


rm current_batch.txt
rm current_question_section.txt