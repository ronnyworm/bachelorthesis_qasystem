#!/usr/bin/env python
#coding=UTF-8

from __future__ import print_function
import nltk
import sys
from nltk.corpus import wordnet as wn

debug_level = 0

def warning(*objs):
	if debug_level > 0:
		print("WARNING: ", *objs, file=sys.stderr)

if len(sys.argv) < 3 or len(sys.argv) > 5:
	warning("Es muss ein Wort als erster Parameter übergeben werden.")
	warning("Wenn als zweiter Parameter ein Dateiname übergeben wird, wird das Ergebnis in diese Datei gespeichert. Ansonsten wird es auf der Standardausgabe angezeigt und der Parameter muss stdout lauten.")
	warning("Es kann als dritter Parameter übergeben werden, nach welchen Worten gesucht werden soll (v ist Verb (Standard), n ist Substantiv).")
	warning("Es kann als vierter Parameter übergeben werden (dann ist der zweite obligatorisch), wie locker nach Synonymen gesucht werden soll:")
	warning("1 ist streng (Standard), 2 ist locker")
	warning("Es kann sein, dass das Skript keine Ausgabe hat. Das bedeutet, dass kein Synonym gefunden wurde.")
	warning("Das hier wurde übergeben: " + str(sys.argv))
	sys.exit(1)

# Beispiel für ein Wort, bei dem für die verschiedenen Suchen (severe_level 1 bzw 2) andere Ergebnisse kommen:
# part

severe_level = 1
if len(sys.argv) == 5:
	severe_level = int(sys.argv[4])

if severe_level > 1:
	similarity_threshold = 0.15
	max_filtered_synset_index = 2
else:
	similarity_threshold = 0.2
	max_filtered_synset_index = 0

word = sys.argv[1].replace(" ", "_")
outfile = sys.argv[2]


word_class = "v"
if len(sys.argv) > 3:
	word_class = sys.argv[3]
	if word_class != 'v' and word_class != 'n':
		warning("Die Wortart " + word_class + " wird nicht unterstützt ...")
		sys.exit(3)


try:
	found_synset = wn.synset(word + "." + word_class + ".01")
except Exception, e:
	warning("Das Wort " + word + " wurde nicht gefunden ...")
	sys.exit(2)

#similar_synsets = [str(found_synset.path_similarity(synset)) + ":" + str(synset.name()) for synset in wn.synsets(word) if found_synset.path_similarity(synset) != 1.0 and found_synset.path_similarity(synset) > 0.2]
similar_synsets = []
for synset in wn.synsets(word):
	if debug_level > 1:
		print(str(found_synset.path_similarity(synset)) + " - " + str(synset.name()) + ": " + str(synset.lemma_names()))

	if found_synset.path_similarity(synset) != 1.0 and found_synset.path_similarity(synset) > similarity_threshold:
		similar_synsets += [ str(found_synset.path_similarity(synset)) + ":" + str(synset.name()) ]

#print(str(similar_synsets))

synonyms = [s for s in found_synset.lemma_names() if s != word]

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
	result = str(synonyms).replace("u\'", "").replace("\'", "").replace("[", "").replace("]", "")

	if outfile == "stdout":
		print(result)
	else:
		with open (outfile, "w") as f:
			f.write(result + "\n")