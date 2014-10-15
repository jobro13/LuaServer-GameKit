Lua Database Documentation
==========================

Warning: flat type database. If you hate this, close your eyes.

Omg. Why.
Because Lua, that's why. No, it won't be the fastest. I don't know. Maybe this is just to prove what Lua is capable of.

It's like the story of the turtle and the bunny. The bunny is fast, but isn't smart - the turtle isn't fast, but is smart... (Interpret this your own way)

So what can we do?
==================

LDB manager has basically two services:
-> The server (You won't touch this a lot)
-> The client (Yeah you will touch this a lot)

The client can send requests to the LDB server. LDB is another process, so we can create secure environments for the database. We don't want it to get stolen, right? 
I will provide a plugin so queries can be sent while preprocessing HTML. 

Query Syntax
============

NOTE: These queries are going to be put in a "database" plugin for web pages.
Usage for that will be provided.
In most case the function to call is the plugin method of that function name, plus arguments. This builds a buffer for our database which is released upon request. New requests are created via a function which also has to be called first.

`create <dbname> <collinfo>`
Creates a new database. If it exists, do nothing. dbname can be a path.
Collinfo is in the following format:

create test collinfo: id,name,score main: id;
NO SPACES!
If main: is not preset, choses first specified collumn as main row. This is used as key to find the data.

`insert <insdata> in <database name>`
inserts data into the database 
insdata is as following:
rowname = [datalen] data, rowname=[datalen]data ..

--> first open in w to create
--> then open in r+ to set pos and update
---> THIS DOES NOT INSERT, but overwrites raw bytes.



