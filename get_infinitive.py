#!/usr/bin/env python
#coding=UTF-8

from __future__ import print_function
import nltk
import sys
from nltk.stem.wordnet import WordNetLemmatizer

def warning(*objs):
	print("WARNING: ", *objs, file=sys.stderr)

if len(sys.argv) != 2:
	warning("Als erster Parameter muss ein Verb übergeben werden.")
	warning("Das hier wurde übergeben: " + str(sys.argv) + " (" + str(len(sys.argv)) + ")")
	sys.exit(1)

verb = sys.argv[1]

lemmatizer = WordNetLemmatizer()
print(lemmatizer.lemmatize(verb.lower(), 'v'))