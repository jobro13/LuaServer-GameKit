local md5 = require "md5"
local server = require "server"
local copas = require "copas"
local lfs = require "lfs"

local db = {}

db.root = "./database"
db.IP = "127.0.0.1"
db.Port = 3391

-- basic commands:
-- use <tablename>; (seeks in this table)
-- find <condition>
--> this condition has its own syntax (YAY)

-- every command should be raw sent using tcp or udp;
--> every newline denotes a new command
function db:parse(command, args)

end 

function db:new()
	local myserver = server:new()
	-- memfixes here
	function myserver:handle(conn, efc, tr)
		local data 
		repeat 
			if data and data ~= "" then 
				self:parse(data)
			end
			data = copas.receive(conn, "*l")
			-- parse data
			print("lol", data)
		until not data
	end 

	local o = {}
	o.server = myserver 
	server.IP = self.IP
	server.Port = self.Port
	setmetatable(o, {__index= function(tab,ind) return db[ind] or myserver[ind] end})
	server:Initialize()
	copas.addserver(myserver.socket, function(...) myserver.handle(self, ...) end)
	return o
end 

return db