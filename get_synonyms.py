#!/usr/bin/env python
#coding=UTF-8

from __future__ import print_function
import nltk
import sys
from nltk.corpus import wordnet as wn

def warning(*objs):
	print("WARNING: ", *objs, file=sys.stderr)

if len(sys.argv) != 2:
	warning("Es muss ein Wort (am besten ein Verb) übergeben werden! Das hier wurde übergeben: " + str(sys.argv))
	warning("Es kann sein, dass das Skript keine Ausgabe hat. Das bedeutet, dass kein Synonym gefunden wurde.")
	sys.exit(1)

word = sys.argv[1]
try:
	ss = wn.synset(word + ".v.01")
except Exception, e:
	warning("Das Wort " + word + " ist kein Verb ...")
	sys.exit(2)

similar_synsets = [str(ss.path_similarity(synset)) + ":" + str(synset.name()) for synset in wn.synsets(word) if ss.path_similarity(synset) != 1.0 and ss.path_similarity(synset) > 0.2]

synonyms = [s for s in ss.lemma_names() if s != word]

if len(similar_synsets) > 0:
	lemmas_other = wn.synset(sorted(similar_synsets, reverse=True)[0].split(":")[1]).lemma_names()
	more_synonyms = [s for s in lemmas_other if s != word]
	synonyms += more_synonyms

if len(synonyms) > 0:
	print(str(synonyms).replace("u\'", "").replace("\'", "").replace("[", "").replace("]", ""))