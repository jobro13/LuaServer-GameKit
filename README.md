LuaServer 
=========

What is LuaServer?
---------

LuaServer aims to be a complete packet to create everything a server needs - database management, preprocessing and even routing. This is done in Lua where possible, but if significant improvements can be made there will be switched in certain places to other languages.

LuaServer currently has the following features:

* (Crude) HTML preprocessing
* Page routing
* [WIP] database management

The most important files
------------------------

To start the server, run:

	sudo lua start_server.lua

start_server.lua is located in ./server

In start_server.lua there arent a lot of things that happen - even while the code is short. The routing of the page is setup - this can be done in any way as the routing is smart. It will route to the most specific page provided. Patterns will be converted; the input /home/* pattern is converted to the Lua /home/.+ pattern. (In other words, the * is a joker)

Routing can be placed anywhere!

The coolest part of the whole server is that it allows Lua to preprocess our pages. This is done dynamically: if you change any page on the server, it will be published live (.. duh). You can use this to create dynamic pages. (A la PHP, but now in Lua - thus more awesome).

The .lua files are invoked with the url (ex /index.lua), the headers (in a table, headers["Content-Type"] is the Content Type for example.), the method (GET/POST) and the http version (1.1) - doubt that you will ever need the last.

Libs are loaded in the environment.

What is the goal?
--------------------------

LuaServer should be used in a simple way, where everyone can mix their favorite scripting language (Lua) with web development. This server will come with a proxy (to safely redirect a connection to a secure environment, but using extern port 80 and a non-superuser-blocked port internally) and a Lua Database Management server.

To prove that it works, the game "Werewolves of Miller Estate" (or Mafia, which has similiar gameplay) will be created on this server and will be up and running. It's going to be very, very fun. Hop on!



