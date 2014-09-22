
server_o = require "server"
local server = server_o:new();

copas = require "copas"

server.routing:add("/*", "/index.lua")

server:Initialize()
server:Start()


