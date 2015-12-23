#!/usr/bin/env python
#coding=UTF-8

from __future__ import print_function
import nltk
import sys
from nltk.corpus import wordnet as wn

def warning(*objs):
	print("WARNING: ", *objs, file=sys.stderr)

if len(sys.argv) < 2 or len(sys.argv) > 3:
	warning("Es muss ein Wort (am besten ein Verb) übergeben werden! Das hier wurde übergeben: " + str(sys.argv))
	warning("Es kann als zweiter Parameter übergeben werden, wie locker nach Synonymen gesucht werden soll:")
	warning("1 ist streng (Standard), 2 ist locker")
	warning("Es kann sein, dass das Skript keine Ausgabe hat. Das bedeutet, dass kein Synonym gefunden wurde.")
	sys.exit(1)

if len(sys.argv) == 3:
	severe_level = int(sys.argv[2])
else:
	severe_level = 1

if severe_level > 1:
	similarity_threshold = 0.15
	max_filtered_synset_index = 2
else:
	similarity_threshold = 0.2
	max_filtered_synset_index = 0

word = sys.argv[1].replace(" ", "_")

try:
	ss = wn.synset(word + ".v.01")
except Exception, e:
	warning("Das Wort " + word + " ist kein Verb ...")
	sys.exit(2)

#similar_synsets = [str(ss.path_similarity(synset)) + ":" + str(synset.name()) for synset in wn.synsets(word) if ss.path_similarity(synset) != 1.0 and ss.path_similarity(synset) > 0.2]
similar_synsets = []
for synset in wn.synsets(word):
	#print(str(ss.path_similarity(synset)) + " - " + str(synset.name()) + ": " + str(synset.lemma_names()))
	if ss.path_similarity(synset) != 1.0 and ss.path_similarity(synset) > similarity_threshold:
		similar_synsets += [ str(ss.path_similarity(synset)) + ":" + str(synset.name()) ]

#print(str(similar_synsets))

synonyms = [s for s in ss.lemma_names() if s != word]

if len(similar_synsets) > 0:
	sorted_similar_synsets = sorted(similar_synsets, reverse=True)

	#print(sorted_similar_synsets)
	
	for idx in list(range(0, max_filtered_synset_index + 1)):
		if idx == len(sorted_similar_synsets):
			break
		lemmas_other = wn.synset(sorted_similar_synsets[idx].split(":")[1]).lemma_names()
		more_synonyms = [s for s in lemmas_other if s != word]
		synonyms += more_synonyms

if len(synonyms) > 0:
	print(str(synonyms).replace("u\'", "").replace("\'", "").replace("[", "").replace("]", ""))