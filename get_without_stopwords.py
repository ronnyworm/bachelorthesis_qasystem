#!/usr/bin/env python
#coding=UTF-8

from __future__ import print_function
import nltk
import sys
import re
from nltk.corpus import stopwords

def warning(*objs):
	print("WARNING: ", *objs, file=sys.stderr)

if len(sys.argv) != 2:
	warning("Als erster Parameter muss eine Liste von Wörtern übergeben werden.")
	warning("Das hier wurde übergeben: " + str(sys.argv) + " (" + str(len(sys.argv)) + ")")
	sys.exit(1)

words = sys.argv[1]
words = nltk.word_tokenize(words.strip())

# Bevor auf Stoppwort getestet wird, wird das Wort noch kleingeschrieben
# Es wird aber wie übergeben zurückgegeben, wenn es kein Stoppwort ist (evtl auch großgeschrieben)
result = []
for word in words:
	if word.lower() not in stopwords.words('english'):
		result += [word]

print(str(result).replace("\'", "").replace("[", "").replace("]", "").replace(",", ""))