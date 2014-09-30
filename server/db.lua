local md5 = require "md5"
local server = require "server"
local copas = require "copas"

local db = {}

db.root = "./database"
db.IP = "127.0.0.1"
db.Port = 3391

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
			if data then 
				self:parse(data)
			end
			data = copas.receive(conn, "*l")
			-- parse data
		until not data
	end 

	local o = {}
	o.server = myserver 
	server.IP = self.IP
	server.Port = self.Port
	setmetatable(o, {__index=db})
	server:Initialize()
	return o
end 

return db