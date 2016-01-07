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
	echo "No Open IE Extraction"
	#Keine Extraktionen ...

	lexparser.sh "$qfile" 2> /dev/null > result.txt

	grep -A 1 -B 1 -e VBD -e VBZ result.txt > tmp_relation.txt

	object_line=$(awk 'NR==3' tmp_relation.txt)
	if [[ "$object_line" != *NN* ]]; then
		grep -A 10 -B 1 -e VBD -e VBZ result.txt > tmp_relation.txt
		awk 'NR>2{if(index($0, "NN") > 0){printf $0" ";exit;}else{printf $0}}' tmp_relation.txt > tmp_relation2.txt
		./clean_parsing.sh nogrep tmp_relation2.txt | sed -E 's/ +/ /g' > tmp_relation3.txt
		./clean_parsing.sh nogrep tmp_relation.txt | head -n 2 > $resultfile
		cat tmp_relation3.txt >> $resultfile

		rm tmp_relation2.txt
		rm tmp_relation3.txt
	fi

	rm tmp_relation.txt
	rm result.txt

#	if [[ -z "$(cat tmp_relation.txt)" ]]; then
#		# nach VB suchen
#		grep -A 10 -B 1 -e VB[[:space:]] result.txt > tmptmp.txt
#		cat tmptmp.txt | head -n $(grep -n NN tmptmp.txt | cut -f1 -d:) > tmptmptmp.txt
#		./clean_parsing.sh nogrep tmptmptmp.txt
#	fi
#
#	#kein object direkt eine Zeile nach dem Prädikat gefunden im Parsing-Ergebnis
#	if [[ -z "$(awk 'NR == 3' tmp_relation.txt)" ]]; then
#		./clean_parsing.sh 1 "-e VBD -e VBZ" | awk 'NR != 3' > tmp_relation.txt
#	fi
	#cat tmp_relation.txt

	if [[ -z "$(cat $resultfile)" ]]; then
		echo "Aaaahh"
		exit 1
	fi
fi