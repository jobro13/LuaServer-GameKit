Lua Database Documentation
==========================

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

`use <dbname>`
 Notifies LDBS that we want to use the dbname. This can be a path, seen from root. (we just io.open it)
 Using any database manipulations without specifiying a database will result in an error.

`create <dbname>`
Creates a new database. If it exists, do nothing. dbname can be a path.

`

