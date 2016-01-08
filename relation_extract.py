#!/usr/bin/env python
#coding=UTF-8

import sqlite3
import os
import os.path
import sys
import nltk
from nltk.corpus import stopwords

debug = False

# http://stackoverflow.com/questions/3247183/variable-table-name-in-sqlite
def scrub(sent):
	return ''.join( chr for chr in sent if chr.isalnum() or chr == '_' or chr == ' ' )

if len(sys.argv) != 3:
	print("Es muss als erster Parameter die Datei angegeben werden, in der die Ausgabe von Reverb mit Semikola statt Tab getrennt steht (und in der ersten Zeile sind nur Spaltenüberschriften).")
	print("Als zweiter Parameter der Name der SQLite-Datenbank, in die die Relationen gespeichert werden sollen.")
	print("Das hier wurde übergeben: " + str(sys.argv))
	sys.exit(1)

reverb_modified_outputfile = sys.argv[1]
if not os.path.isfile(reverb_modified_outputfile):
	print("Die Datei %s existiert nicht" % reverb_modified_outputfile)
	sys.exit(2)

dbname = sys.argv[2]
if os.path.isfile(dbname):
	os.remove(dbname)


def read_reverb_relations(filename):
	subjects = []
	verbs = []
	objects = []
	containing_sentences = []

	with open (filename, "r") as f:
		content = f.read()
		
		index = 0
		for line in content.split("\n"):
			splitted = line.split(";")
			if len(splitted) == 18 and index > 0:
				subjects += [ line.split(";")[15] ]
				verbs += [ line.split(";")[16].replace(" ", "_") ]
				objects += [ line.split(";")[17] ]
				containing_sentences += [ line.split(";")[12] ]

			index += 1

	return [ subjects, verbs, objects, containing_sentences ]

def filter_stopwords(string):
	result = ""

	words = nltk.word_tokenize(string)

	for word in words:
		if word.lower() not in stopwords.words('english'):
			result += str(word) + " "
	result = result.strip()

	return result

def create_extraction_tables(relations):
	conn = sqlite3.connect(dbname)
	c = conn.cursor()

	existing_tables = set();

	c.execute("CREATE TABLE relation_nouns (noun text, sentence text)") 

	index = 0
	for table in relations[1]:
		sentence_scrubbed = scrub(relations[3][index])
		subj_scrubbed = scrub(relations[0][index])
		obj_scrubbed = scrub(relations[2][index])
		subj_without_stopwords = filter_stopwords(subj_scrubbed)
		obj_without_stopwords = filter_stopwords(obj_scrubbed)


		if subj_without_stopwords != "":
			c.execute("INSERT INTO relation_nouns VALUES ('%s','%s')" % (subj_without_stopwords, sentence_scrubbed))
		if obj_without_stopwords != "":
			c.execute("INSERT INTO relation_nouns VALUES ('%s','%s')" % (obj_without_stopwords, sentence_scrubbed))


		table_scrubbed = scrub(table)

		# create kann nicht als Name einer Tabelle verwendet werden, weil es ein Schlüsselwort in SQL ist
		if table_scrubbed == "create":
			table_scrubbed = "create_a"

		if table_scrubbed not in existing_tables:
			c.execute("CREATE TABLE %s (subject text, object text)" % str(table_scrubbed)) 
		c.execute("INSERT INTO %s VALUES ('%s','%s')" % (table_scrubbed, subj_scrubbed, obj_scrubbed))

		existing_tables.add(table_scrubbed)

		index += 1	

	conn.close()

rels = read_reverb_relations(reverb_modified_outputfile)
create_extraction_tables(rels)

sys.exit(0)