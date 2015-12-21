#!/usr/bin/env python

import sqlite3

def init_and_insert_one():
	conn = sqlite3.connect('example.db')

	# You can also supply the special name :memory: to create a database in RAM.
	# Once you have a Connection, you can create a Cursor object and call its execute() method to perform SQL commands:

	c = conn.cursor()

	# Create table
	c.execute('''CREATE TABLE stocks
	             (date text, trans text, symbol text, qty real, price real)''')

	# Insert a row of data
	c.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")

	# Save (commit) the changes
	conn.commit()

	# We can also close the connection if we are done with it.
	# Just be sure any changes have been committed or they will be lost.
	conn.close()


def insert():
	conn = sqlite3.connect('example.db')
	c = conn.cursor()

	# Larger example that inserts many records at a time
	purchases = [('2006-03-28', 'BUY', 'IBM', 1000, 45.00),
	             ('2006-04-05', 'BUY', 'MSFT', 1000, 72.00),
	             ('2006-04-06', 'SELL', 'IBM', 500, 53.00)]
	c.executemany('INSERT INTO stocks VALUES (?,?,?,?,?)', purchases)

	conn.close()


def print_contents():
	conn = sqlite3.connect('example.db')
	c = conn.cursor()

	example = ('RHAT',)
	c.execute('SELECT * FROM stocks WHERE symbol=?', example)
	print c.fetchone()

	for row in c.execute('SELECT * FROM stocks ORDER BY price'):
		print row

	conn.close()

	
init_and_insert_one()
insert()
print_contents()