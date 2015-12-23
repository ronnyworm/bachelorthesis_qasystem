#!/usr/bin/env python
#coding=UTF-8

import sqlite3
import os
import os.path
import sys



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

	index = 0
	for table in relations[1]:

		c.execute("CREATE TABLE %s (subject text, object text)" % table) 
		c.execute("INSERT INTO %s VALUES ('%s','%s')" % (table, relations[0][index], relations[2][index]))

		index += 1	

	conn.close()


rels = read_reverb_relations(reverb_modified_outputfile)
create_tables(rels)