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

def log(s):
	with open ("pipeline_log.md", "a") as f:
		f.write("\t" + s + "\n")

if len(sys.argv) < 5:
	warning("Als erster Parameter muss der Name der SQLite-Datenbank übergeben werden.")
	warning("Als zweiter Parameter muss der Dateiname der Datei mit der normalisierten Frage übergeben werden.")
	warning("Als dritter Parameter müssen die Tabellen übergeben werden, in denen nach der Antwort gesucht werden soll (mit Komma und Leerzeichen voneinander getrennt.)")
	warning("Als vierter Parameter muss der Dateiname übergeben werden, in den die Antworten gespeichert werden sollen.")	
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

tables = sys.argv[3].split(", ")

answer_file = sys.argv[4]




# subject und object aus Fragefile holen
f = open(qfilename, 'r')
subj = nltk.word_tokenize(f.readline().lower().strip())
subj = [word for word in subj if word not in stopwords.words('english')]
predicate = f.readline().strip()
obj = nltk.word_tokenize(f.readline().lower().strip())
obj = [word for word in obj if word not in stopwords.words('english')]
f.close()

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

	# Hier wird ignoriert, wenn get_synonyms für ein Wort einen Fehler auslöst. Das wird gewertet als "kein Synonym gefunden"
	except Exception, e:
		pass

log("Synonyme für Subjekt und Objekt: " + str(with_synonyms))
if len(with_synonyms) == 0:
	log("Nach Entfernung der Stoppwörter ist nichts mehr übrig geblieben. Dann kann auch nicht gesucht werden. Frage zu ungenau.")
	sys.exit(4)


# Übereinstimmungen in der Datenbank suchen
conn = sqlite3.connect(dbname)
c = conn.cursor()

answer_sents_predicates = []
answer_sents_relation_nouns = []

for table in tables:
	for syn in with_synonyms:
		if debug:
			print("q: " + 'SELECT * FROM ' + scrub(table) + ' WHERE subject like "%' + scrub(syn) + '%" or object like "%' + scrub(syn) + '%"')
		for row in c.execute('SELECT * FROM ' + scrub(table) + ' WHERE subject like "%' + scrub(syn) + '%" or object like "%' + scrub(syn) + '%"'):
			# Ersten Buchstaben groß schreiben
			first = row[0][:1].upper() + row[0][1:]

			if table.endswith("_by"):
				v = en.verb.past_participle(table.split("_")[0])
				answer_sents_predicates += [ "%s is %s by %s." % (first, v, row[1]) ]
			else:
				answer_sents_predicates += [ "%s %ss %s." % (first, table, row[1]) ]
match_count = len(set(answer_sents_predicates))
log("Anzahl Funde in Prädikattabellen: " + str(match_count))


if match_count < 3 and (predicate == "do" or predicate == "be"):
	for syn in with_synonyms:
		for row in c.execute('SELECT * FROM relation_nouns WHERE noun like "%' + scrub(syn) + '%"'):
			first = row[1][:1].upper() + row[1][1:]
			answer_sents_relation_nouns += [ first ]
	log("Anzahl Funde in relation_nouns-Tabelle: " + str(len(set(answer_sents_relation_nouns))))

conn.close()

answer_sents = answer_sents_predicates + answer_sents_relation_nouns
answer_sents = set(answer_sents)

with open (answer_file, "w") as f:
	for s in answer_sents:
		f.write(s + "\n")