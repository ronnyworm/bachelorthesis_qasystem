#!/usr/bin/env python

import sqlite3
import os

os.remove("relations.db")

def read_reverb_relations(filename):
	subjects = []
	verbs = []
	objects = []

	with open (filename, "r") as f:
		content = f.read()
		
		for line in content.split("\n"):
			splitted = line.split(";")
			if len(splitted) == 18:
				subjects += [ line.split(";")[15] ]
				verbs += [ line.split(";")[16].replace(" ", "_") ]
				objects += [ line.split(";")[17] ]

	return [ subjects, verbs, objects ]

def create_tables(relations):
	conn = sqlite3.connect('relations.db')
	c = conn.cursor()

	index = 0
	for table in relations[1]:

		c.execute("CREATE TABLE %s (subject text, object text)" % table) 
		c.execute("INSERT INTO %s VALUES ('%s','%s')" % (table, relations[0][index], relations[2][index]))

		index += 1	

	conn.close()


rels = read_reverb_relations("output.csv")
create_tables(rels)