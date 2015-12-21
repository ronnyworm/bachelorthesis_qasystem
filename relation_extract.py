#!/usr/bin/env python

def read_reverb_relations(filename):

    with open (filename, "r") as f:
    	content = f.read()
        
        for line in content.split("\n"):
			print line.split(";")[15]
# replace('\\n', '\n')

read_reverb_relations("output.csv")