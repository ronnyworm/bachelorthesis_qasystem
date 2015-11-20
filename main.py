#!/usr/bin/env python

import nltk

def read_document(filename):
	with open (filename, "r") as f:
	    result = f.read().replace('\\n', '\n')
	return result

# von Seite 263
def ie_preprocess(document):
	sentences = nltk.sent_tokenize(document)
	sentences = [nltk.word_tokenize(sent) for sent in sentences]
	sentences = [nltk.pos_tag(sent) for sent in sentences]

	return sentences

# von seite 265
def chunk(grammar, pos_tagged_sentence):
	chunkparser = nltk.RegexpParser(grammar)
	result = chunkparser.parse(pos_tagged_sentence)

	return result


#pos_tagged = ie_preprocess(read_document("corpora/OpenAL_1_ausschnitt.txt"))
#print pos_tagged

test_sent = [('OpenAL', 'NNP'), ('detects', 'VBZ'), ('only', 'RB'), ('a', 'DT'), ('subset', 'NN'), ('of', 'IN'), ('those', 'DT'), ('conditions', 'NNS'), ('that', 'IN'), ('could', 'MD'), ('be', 'VB'), ('considered', 'VBN'), ('errors', 'NNS'), ('.', '.')]
chunks = chunk("NP: {<DT>?<JJ>*<NN>}", test_sent)
chunks.draw()