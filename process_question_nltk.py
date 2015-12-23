#!/usr/bin/env python
#coding=UTF-8

from __future__ import print_function
import nltk
import sys
import re
from nltk.stem.wordnet import WordNetLemmatizer

def warning(*objs):
	print("WARNING: ", *objs, file=sys.stderr)

if len(sys.argv) != 2:
	warning("Als erster Parameter muss eine Frage übergeben werden.")
	warning("Das Ergebnis wird in question_normalised.txt abgespeichert.")
	warning("Das hier wurde übergeben: " + str(sys.argv) + " (" + str(len(sys.argv)) + ")")
	sys.exit(1)

q = sys.argv[1]
words = nltk.word_tokenize(q)
pos_tagged = nltk.pos_tag(words)

def chunk(grammar, pos_tagged_sentence):
	chunkparser = nltk.RegexpParser(grammar)
	result = chunkparser.parse(pos_tagged_sentence)

	return result

chunks = chunk("NP: {<DT>?<JJ.*>*<NN.*>+}", pos_tagged)

print(chunks)
sys.exit(0)

pattern = re.compile("^VB.*$")
lemmatizer = WordNetLemmatizer()
for w in pos_tagged:
	if pattern.match(w[1]) != None:
		# Infinitiv rausholen
		print(lemmatizer.lemmatize(w[0].lower(), 'v'))