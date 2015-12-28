#!/usr/bin/env python
#coding=UTF-8

from __future__ import print_function
import nltk
import sys
import sqlite3
from nltk.corpus import wordnet as wn
from nltk.corpus import stopwords
import os.path
from subprocess import check_output
import en

def warning(*objs):
	print("WARNING: ", *objs, file=sys.stderr)

# http://stackoverflow.com/questions/3247183/variable-table-name-in-sqlite
def scrub(table_name):
	return ''.join( chr for chr in table_name if chr.isalnum() or chr == '_' or chr == ' ' )

if len(sys.argv) < 4:
	warning("Als erster Parameter muss der Name der SQLite-Datenbank übergeben werden.")
	warning("Als zweiter Parameter muss der Dateiname der Datei mit der normalisierten Frage übergeben werden.")
	warning("Als dritter Parameter müssen die Tabellen übergeben werden, in denen nach der Antwort gesucht werden soll (mit Komma und Leerzeichen voneinander getrennt.)")
	warning("Das hier wurde übergeben: " + str(sys.argv) + " (" + str(len(sys.argv)) + ")")
	sys.exit(1)

debug = False

dbname = sys.argv[1]
if not os.path.isfile(dbname):
	print("Die Datei %s existiert nicht" % dbname)
	sys.exit(2)

if debug:
	print("db: " + dbname)

qfilename = sys.argv[2]
if not os.path.isfile(qfilename):
	print("Die Datei %s existiert nicht" % dbname)
	sys.exit(3)

if debug:
	print("qf: " + qfilename)

tables = sys.argv[3].split(", ")

if debug:
	print("tables: " + str(tables))

# subject und object aus Fragefile holen
f = open(qfilename, 'r')
subj = nltk.word_tokenize(f.readline().strip())
subj = [word for word in subj if word not in stopwords.words('english')]
f.readline()
obj = nltk.word_tokenize(f.readline().strip())
obj = [word for word in obj if word not in stopwords.words('english')]

relevant_in_question = []
relevant_in_question += subj + obj
with_synonyms = []
with_synonyms += list(relevant_in_question)

# Synonyme finden
scriptpath = os.path.dirname(os.path.abspath(__file__))
for word in relevant_in_question:
	res = ""
	try:
		res = check_output(["./get_synonyms.py", word, "n"]).strip().replace("_", " ").split(", ")
		if res != ['']:
			with_synonyms += res
	except Exception, e:
		pass

conn = sqlite3.connect(dbname)
c = conn.cursor()

answer_sents = []

for table in tables:
	for syn in with_synonyms:
		if debug:
			print("q: " + 'SELECT * FROM ' + scrub(table) + ' WHERE subject like "%' + scrub(syn) + '%" or object like "%' + scrub(syn) + '%"')
		for row in c.execute('SELECT * FROM ' + scrub(table) + ' WHERE subject like "%' + scrub(syn) + '%" or object like "%' + scrub(syn) + '%"'):

			first = row[0][:1].upper() + row[0][1:]

			if table.endswith("_by"):
				v = en.verb.past_participle(table.split("_")[0])
				answer_sents += [ "%s is %s by %s." % (first, v, row[1]) ]
			else:
				answer_sents += [ "%s %ss %s." % (first, table, row[1]) ]

conn.close()

answer_sents = set(answer_sents)

for s in answer_sents:
	print(s)