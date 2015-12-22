#!/usr/bin/env python

import nltk
from nltk.corpus import wordnet as wn

ss = wn.synset('get.v.01')

similarities = [str(ss.path_similarity(synset)) + ":" + str(synset) for synset in wn.synsets('get') if ss.path_similarity(synset) != 1.0]


print str(sorted(similarities, reverse=True)).replace(', ', '\n')


#for w in words:
	#	if w not in stop_words:
	#		filtered_sentence.append(w)

	#filtered_sentence = [w for w in words if not w in stop_words]