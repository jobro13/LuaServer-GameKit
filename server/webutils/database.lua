local socket = require "socket"

local database = {}

database.host = "127.0.0.1"
database.port = 3391

-- returns a new tcp socket to write on
function database.connect()
	local sock = socket.tcp()
	sock:settimeout(0.1)
	sock:connect(database.host, database.port)
	-- put auth shit here
	return sock
end 

