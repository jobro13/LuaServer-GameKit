local socket = require "socket"
local copas = require "copas"

local database = {}

database.host = "127.0.0.1"
database.port = 3391

-- returns a new tcp socket to write on
function database.connect()
	local sock = socket.tcp()
	sock:settimeout(1)
	print(sock:connect(database.host, database.port))
	-- put auth shit here
	return sock
end 


-- sends string what on socket
function database.send(socket, what)
	copas.send(socket,what)
end 

-- evaluates stuff
-- returns in awesome format
function database.evaluateanswer(socket)

end 

function database.create(name, rows, mainrow)
	if not (name and rows and mainrow) then 
		return false, "Some parameters were not provided"
	end 
	local conn = database.connect()
	local str = "create " .. name .. " collinfo: "
	str = str .. table.concat(rows, ",")
	str = str:sub(1,str:len()) -- without last ,
	local found 
	for i,v in pairs(rows) do 
		if v == mainrow then 
			found = true 
			break 
		end 
	end 
	if not found then
		conn:close()
		return false, "Mainrow is not in rows"
	end 
	str = str .. " main: " .. mainrow .. ";\n"
	database.send(conn, str)
end 

function database.insert(data, dbname)
	if not data or not dbname then 
		return false, "Could not insert because not enough parameters supplied"
	end 
	local str = "insert " 
	for i,v in pairs(data) do 
		str  = str .. i .. " = [" .. (tostring(v):len()) .. "] " .. tostring(v) .. ", "
	end 
	str = str .. "in "..dbname..";\n"
	print(str)
	local conn = database.connect()
	database.send(conn, str)
end 

return database
