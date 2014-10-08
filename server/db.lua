local md5 = require "md5"
local server = require "server"
local copas = require "copas"
local lfs = require "lfs"

local db = {}

local root = lfs.currentdir()

db.root = lfs.currentdir() .. "/database"
db.IP = "127.0.0.1"
db.Port = 3391

local function argsplit(argstr)
	local out = {}
	if not argstr then 
		return out 
	end 
	for match in string.gmatch(argstr, "%s(%S+)") do 
		table.insert(out,match)
	end 
	return out 
end

db.commands = {}

function db.commands:insert(rest)
	local gotdb 
	local dbname
	local data = {} 
	for i,v in pairs(rest) do 
		print(v)
		if v == "in" then 
			dbname = rest[i+1]
			if dbname then 
				gotdb = true 
			end 
		elseif v == "=" then 
			local rowname = rest[i-1]
			local datalen = rest[i+1]
			local writedata = rest[i+2]
			if not rowname or not datalen or not data then 
				return false, "Wrong data supplied"
			elseif writedata:sub(writedata:len(), writedata:len()) == "," then 
				writedata = writedata:sub(1,writedata:len()-1)
			else 
				return false, "Wrong data supplied"
			end 
			table.insert(data, {rowname, datalen, writedata})
		end
	end 
	for i,v in pairs(data) do 
		print(v[1], v[2], v[3])
	end 
	if not gotdb then 
		return false, "Specify database name"
	end 
end 

function db.commands:create(rest)
	lfs.chdir(self.root)
	local collumns = {}
	local colldata, maincoll
	local name = rest[1] 
	if not name then 
		return "Specify a database name"
	end 

	for i,v in pairs(rest) do 
		if v:match("collinfo:") then 
			colldata = rest[i+1]
		elseif v:match("main:") then 
			maincoll = rest[i+1]
		end 
	end 

	-- start splitting 
	local collumndata = {}
	for match in string.gmatch(colldata, "(%w+)") do 
		table.insert(collumndata, match)
	end 

	if #collumndata == 0 then 
		return false, "Error parsing collumn data: did not find any data"
	end 

	if not colldata then 
		return false, "Did not find any collumn data"
	end 


	local file = io.open(name..".ldb", "w") -- lua db
	file:write("Collumn specification:\n")
	file:write("Collumns: " .. #collumndata .."\n")
	if maincoll then 
		local found = false 
		for i,v in pairs(collumndata) do 
			if v == maincoll then 
				found = true 
				break 
			end 
		end 
		if not found then
			return false, "Specified main collumn, but this doesnt exist in the collumn info list!"
		end 
		file:write("Main: "..main)
	end 
	for i,v in pairs(collumndata) do 
		file:write(v.."\n")
	end 

	file:write("Collspec end\n")
	file:flush()
	file:close()

	return true, "Database created succesfully"
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

function db:parse(command, remstr)
	if not command then 
		return 
	end 


	if remstr then remstr = " " .. remstr  end

	local args = argsplit(remstr)


	if self.commands[command] then 
		print(self.commands[command](self, args))
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
				for cmd, rem in data:gmatch("(%w+)([^;]-);") do
					if cmd then 
						self:parse(cmd,rem)
					end
				end
			end
			data = copas.receive(conn, "*l")
		until not data
	end 

	local o = {}
	o.server = myserver 
	server.IP = self.IP
	server.Port = self.Port
	setmetatable(o, {__index= function(tab,ind) print(ind, db[ind]) return db[ind] or myserver[ind] end})
	server:Initialize()
	copas.addserver(myserver.socket, function(...) myserver.handle(self, ...) end)
	return o
end 

return db