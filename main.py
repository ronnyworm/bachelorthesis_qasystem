#!/usr/bin/env python

import nltk

def read_document(filename):
	with open (filename, "r") as f:
	    result = f.read().replace('\\n', '\n')
	return result

# von Seite 263 im NLTK-Buch
def ie_preprocess(document):
	sentences = nltk.sent_tokenize(document)
	sentences = [nltk.word_tokenize(sent) for sent in sentences]
	sentences = [nltk.pos_tag(sent) for sent in sentences]

	print sentences

ie_preprocess(read_document("corpora/OpenAL_1_ausschnitt.txt"))