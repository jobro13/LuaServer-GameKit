local md5 = require "md5"
local server = require "server"
local copas = require "copas"
local lfs = require "lfs"

local db = {}

local root = lfs.currentdir()

db.root = lfs.currentdir() .. "/database"
db.IP = "127.0.0.1"
db.Port = 3391

db.commands = {}

function db.commands:create(name)
	lfs.chdir(self.root)
	io.open(name, "w")
end 

-- basic commands:
-- use <tablename>; (seeks in this table)
-- find <condition>
--> this condition has its own syntax (YAY)

-- every command should be raw sent using tcp or udp;
--> every newline denotes a new command

-- changes the root of the directory to where
-- looking from our root
function db:changedir(where, nonrelative)
	lfs.chdir(self.root.."/" .. where)
end 


function db:parse(command, args)
	if self.commands[command] then 
		self.commands[command](self, args)
	else 
		-- return error 
	end
end 

function db:new(root)
	local myserver = server:new()
	local dbroot = nil
	-- memfixes here
	function myserver:handle(conn, efc, tr)
		local data 
		repeat 
			if data and data ~= "" then 

				self:parse(data:match("(%S+)%s(.*)"))
			end
			data = copas.receive(conn, "*l")
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