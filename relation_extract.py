#!/usr/bin/env python

import sqlite3

def read_reverb_relations(filename):
	result = []

	with open (filename, "r") as f:
		content = f.read()
		
		for line in content.split("\n"):
			splitted = line.split(";")
			if len(splitted) == 18:
				result += [ line.split(";")[16].replace(" ", "_") ]

	return result

def create_tables(relations):
	conn = sqlite3.connect('relations.db')
	c = conn.cursor()


	for rel in relations:
		c.execute("CREATE TABLE %s (subject text, object text)" % rel)

	conn.close()


rels = read_reverb_relations("output.csv")
create_tables(rels)