#!/usr/bin/env python
#coding=UTF-8

from __future__ import print_function
import nltk
import sys
import sqlite3
from nltk.corpus import wordnet as wn
import os.path

def warning(*objs):
	print("WARNING: ", *objs, file=sys.stderr)

if len(sys.argv) < 3 or len(sys.argv) > 4:
	warning("Als erster Parameter muss der Name der SQLite-Datenbank übergeben werden.")
	warning("Es muss mindestens ein Verb (als 2. Parameter) übergeben werden!")
	warning("Es kann außerdem eine Menge von Synonymen übergeben werden (3. Parameter")
	warning("Das hier wurde übergeben: " + str(sys.argv) + " (" + str(len(sys.argv)) + ")")
	sys.exit(1)

dbname = sys.argv[1]
if not os.path.isfile(dbname):
	print("Die Datei %s existiert nicht" % dbname)
	sys.exit(2)

word = sys.argv[2]
synonyms = sys.argv[3]

def get_table_names(dbfilename):
	conn = sqlite3.connect(dbfilename)
	c = conn.cursor()

	names = [row for row in c.execute('SELECT name FROM sqlite_master WHERE type = "table"')]

	conn.close()

	return names

def get_matching_tables(table_names, word, synonyms):
	result = []

	for name in names:
		if word in str(name):
			result += [ name ]

	if synonyms != "":
		for syn in synonyms.split(", "):
			for name in names:
				if syn in str(name):
					result += [ name ]

	return result

names = get_table_names(dbname)
print(get_matching_tables(names, word, synonyms))

