local md5 = require "md5"
local server = require "server"
local copas = require "copas"

local db = {}

-- every command should be raw sent using tcp or udp;
--> every newline denotes a new command
function db:parse(command, args)

end 

function db:new()
	local myserver = server:new()
	-- memfixes here
	function myserver:handle(conn, efc, tr)
		local data = copas.receive(conn, "*a")
		-- parse data

	end 
end 
