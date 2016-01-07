#!/bin/bash

debug=0


if [ $# -ne 2 ]; then
    cat << EOF
Als erster Parameter muss die Datei mit der Frage übergeben werden.
Als zweiter Parameter die Datei, in der die Fragerelation abgelegt werden soll.
EOF
    exit
fi

qfile="$1"
resultfile="$2"

if [ ! -f "$qfile" ]; then
	>&2 echo "Das Dokument $qfile existiert nicht!"
	exit 2
fi

cd "Stanford OpenIE"
#Es wird nur die erste Extraktion betrachtet (NR==1)
java -mx1g -cp stanford-openie.jar:stanford-openie-models.jar:slf4j.jar edu.stanford.nlp.naturalli.OpenIE "../$qfile" 2> /dev/null | awk -v FS="\t" 'NR==1{printf("%s\n%s\n%s\n", $2, $3, $4)}' > "../$resultfile"
#rm ../$resultfile
cd ..


if [[ -z "$(cat $resultfile)" ]]; then
	printf "\tVersuch Extraktion mit Stanford Parser\n" >> pipeline_log.md
	#Dollarzeichen der Annotationen von Possesivprononmen entfernen mit sed
	lexparser.sh "$qfile" 2> /dev/null | sed -E 's/\$//g' > result.txt

	# head: bei mehreren Funden nur den ersten betrachten
	grep -A 1 -B 1 -e VBD -e VBZ -e VBN -e VBP result.txt | head -n 3 > tmp_relation.txt

	if [[ ! -z "$(cat tmp_relation.txt)" ]]; then
		object_line=$(awk 'NR==3' tmp_relation.txt)
		# Steht in der dritten Zeile kein Substantiv?
		if [[ "$object_line" != *NN* ]]; then
			# Wenn nicht, sollen die Zeilen danach konkateniert werden bis eines da ist (Brechstange)
			grep -A 10 -B 1 -e VBD -e VBZ -e VBN -e VBP result.txt > tmp_relation.txt
			awk 'NR>2{if(index($0, "NN") > 0){printf $0" ";exit;}else{printf $0}} !NF{exit}' tmp_relation.txt > tmp_relation2.txt
			# der xargs Aufruf ist hier eingefügt, um leading und trailing whitespace zu entfernen
			./clean_parsing.sh nogrep tmp_relation2.txt | sed -E 's/ +/ /g' | xargs > tmp_relation3.txt
			./clean_parsing.sh nogrep tmp_relation.txt | head -n 2 > $resultfile
			cat tmp_relation3.txt >> $resultfile

			rm tmp_relation2.txt
			rm tmp_relation3.txt
		else
			./clean_parsing.sh nogrep tmp_relation.txt > $resultfile
		fi

		subject_line=$(awk 'NR==1' tmp_relation.txt)
		# Steht in der ersten Zeile kein Substantiv?
		if [[ "$subject_line" != *NN* ]]; then
			# Wenn nicht, soll die Zeile davor konkateniert werden (Brechstange)
			# im Gegensatz zum Vorgehen beim Objekt weiter oben wird hier nicht überprüft, ob die neue
			# Zeile ein Substantiv enthält - wenn es noch eine Zeile weiter oben ist, ist das eben so
			grep -A 1 -B 2 -e VBD -e VBZ -e VBN -e VBP result.txt > tmp_relation.txt
			# Ist denn jetzt ein Substantiv in der ersten Zeile?
			if [[ "$(head -n 1 tmp_relation.txt)" == *NN* ]]; then
				awk 'NR!=1{printf $0" ";exit;} NR==1{printf $0}' tmp_relation.txt > tmp_relation2.txt
				./clean_parsing.sh nogrep tmp_relation2.txt | sed -E 's/ +/ /g' > tmp_relation3.txt
				# tmp_relation2.txt können wir hier überschreiben
				mv $resultfile tmp_relation2.txt
				cat tmp_relation2.txt | tail -n 2 >> tmp_relation3.txt
				mv tmp_relation3.txt $resultfile

				rm tmp_relation2.txt
			fi
		fi
	else
		./clean_parsing.sh 1 "-e VB[[:space:]]" > $resultfile
	fi


	printf "\ttmp_relation.txt:\n" >> pipeline_log.md
	awk '{printf "\t"$0"\n";}' tmp_relation.txt >> pipeline_log.md
	printf "\n\tresult.txt:\n" >> pipeline_log.md
	awk '{printf "\t"$0"\n";}' result.txt >> pipeline_log.md

	if [[ -z "$(cat $resultfile)" ]]; then
		printf "\tKeine Extraktion möglich\n" >> pipeline_log.md
		exit 1
	else
		printf "\tExtraktion mit Stanford Parser erfolgreich\n" >> pipeline_log.md
	fi


	rm tmp_relation.txt
	rm result.txt
else
	printf "\tExtraktion mit Stanford Open IE erfolgreich\n" >> pipeline_log.md
fi


predicate=$(awk 'NR==2' $resultfile)
word_count=$(echo $predicate | wc -w | xargs)

if [[ $word_count -gt 1 ]]; then
	# Falls ein zweites Nicht-Stoppwort herauskommt, oder noch mehr, werden diese ignoriert
	predicate=$(./get_without_stopwords.py "$predicate" | cut -f1 -d\ )
fi

infinitive=$(./get_infinitive.py "$predicate")
sed "2s/.*/$infinitive/" $resultfile > tmpfile
rm $resultfile
mv tmpfile $resultfile