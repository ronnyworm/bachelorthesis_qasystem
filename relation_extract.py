#!/usr/bin/env python
#coding=UTF-8

import sqlite3
import os
import os.path
import sys

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



def read_reverb_relations(filename):
	subjects = []
	verbs = []
	objects = []

	with open (filename, "r") as f:
		content = f.read()
		
		index = 0
		for line in content.split("\n"):
			splitted = line.split(";")
			if len(splitted) == 18 and index > 0:
				subjects += [ line.split(";")[15] ]
				verbs += [ line.split(";")[16].replace(" ", "_") ]
				objects += [ line.split(";")[17] ]

			index += 1

	return [ subjects, verbs, objects ]

def create_tables(relations):
	if os.path.isfile(dbname):
		os.remove(dbname)
	conn = sqlite3.connect(dbname)
	c = conn.cursor()

	existing_tables = set();

	index = 0
	for table in relations[1]:

		t = scrub(table)

		if t == "create":
			t = "create_a"

		if debug:
			print("tab: " + table)
			print("sub: " + relations[0][index])
			print("obj: " + relations[2][index])
			print("t: " + t)

		if t not in existing_tables:
			c.execute("CREATE TABLE %s (subject text, object text)" % str(t)) 
		c.execute("INSERT INTO %s VALUES ('%s','%s')" % (t, scrub(relations[0][index]), scrub(relations[2][index])))

		existing_tables.add(t)

		index += 1	

	conn.close()


rels = read_reverb_relations(reverb_modified_outputfile)
create_tables(rels)