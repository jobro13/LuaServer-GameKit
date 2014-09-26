
server_o = require "server"
local server = server_o:new();

copas = require "copas"

server.routing:add("/*", "/index.lua", "../games/werewolves/web")
server.routing:add("/main.css", "/main.css", "../games/werewolves/web")
-- > routing to /main.css

-- new require path for werewolves
package.path = package.path .. ";../games/werewolves/require/?.lua"

server:Initialize()
server:Start()


