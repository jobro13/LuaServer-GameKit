local server = {}

local copas = require "copas"
local socket = require "socket"
local prettyprint = require "prettyprint"
local page = require "page"
local lfs = require "lfs"
local event = require "event"
local libsetting = require "settings/libsetting"
local http = require "http"
local routing = require "routing"

settings = libsetting.GetSettingHandler("settings/settings.txt")

--local html = require "html"

-- I heard you didnt like PHP
-- So we use lau

server.IP = settings:get "bind_ip"
server.Port = tonumber(settings:get "bind_port")

server.RQs = 0

server.webdir = settings:get "webdir"

server.home = settings:get "page_home"
server["404"] = settings:get "page_404"

-- a small function which returns a styled color info message
-- like [OK], [404]
local function getcstr(msg, color)
	return "[%{" .. color .. "}" .. msg .. "%{reset}]"
end


function server:new()
	local o = {}
	o.routing = routing:new()
	return setmetatable(o, {__index=self})
end 

function server:Initialize()

	self.socket = socket.tcp()
	prettyprint.write("server", "info", "Starting server on " .. self.IP .. ":" .. self.Port)
	local ok, err = self.socket:bind(self.IP, self.Port)
	if ok then 
		prettyprint.write("server", "info", "OK: Server has bound to ip and port!")
	else 
		prettyprint.write("server", "error", "Server not online, error: "..tostring(err))
		print("Do you want to specify another port or?")
		if io.read():sub(1,1):lower() == "y" then 
			print("Specify port.")
			server.Port = io.read("*n")
			server:Initialize()
		else 
			os.exit()
		end
	end 
	local listen = self.socket:listen()
	if listen then 
		prettyprint.write("server", "info", "OK: Server is online.")
	end 
	copas.addserver(self.socket, function(...) self.handle(self, ...) end)
end

function server:Start()
	while true do
		copas.step()
	end 
end

-- SERVER HANDLE IS A THREAD IT CLOSES LE CONNECTION ONCE IT RETURNS
-- oh yes copas 
-- oh yes

-- sample http request is;
-- GET / HTTP/1.1
--> page = /
--> method = GET
--> version = 1.1
--> ClientHeaders are all remaining headers!
--> like User-Agent

-- bah. we need to use metatables to have more same-key header values.
local chmeta = {
	__newindex = function(tab,ind,val)
		local target = tab.__data
		if target[ind] then 
			table.insert(target[ind], val)
		else 
			target[ind] = {val}
		end
	end,
	__index = function(tab,ind)
		return tab.__data[ind]
	end
}

function server:getpage(url, clientheaders, method, version)
	-- god dammit
--	local newh = {__data = {}}
--	setmetatable(newh, chmeta)

	print(clientheaders, "CLIENTHEADERS")
	local content, headers, status = page.get(self, url, self.webdir, clientheaders, method, version)
	if headers and not headers["Cache-Control"] then 
		headers["Cache-Control"] = "no-cache"
	end
	return content, headers, status
--[[


	local i,err = io.open(self.webdir .. url, "r")
	prettyprint.write("server", "info", url .. " open: " .. tostring(i))
	if not i then 
		prettyprint.write("server", "error", "File open error: " .. err)
		return nil
	end
	-- Maybe this should move into another module?
	local page_context =
		{
			filetype = url:match("%.(%w+)$")
		}

	print("file type " .. (page_context.filetype or "wot"))
	if page_context.filetype == "lua" then 
		local content, headers = page.generate(url, self.webdir..url, clientheaders, method, version)
		--loadstring(i:read("*a"))(...)
		local headers = headers or {}
		if not headers["Cache-Control"] then 
			headers["Cache-Control"] = "no-cache"
		end
		return content, headers
	elseif page_context.filetype == "blasf" then 
	else 
		return i:read("*all"), {["Cache-Control"] = "no-cache"}
	end--]]
end

server.handle = function(self,conn, efc, tr)
	self.RQs = self.RQs + 1
	local clock = os.clock()
	local id = self.RQs 
	local request = copas.receive(conn, "*l")
	local METHOD, PAGE, VERSION 
	local cname = "Client " .. id .. " "
	if request then 
		local method, page, version = http.getrequest(request)
		if method and page and version then 
			--local cl = http.getclen(conn, copas.receive)
			local options = http.getremheader(conn, copas.receive)

			local rq
			-- to prevent we start opening files we dont want to open; 
			-- we prevent peeps to perform malicious page requests
			-- these are only symbols at the start!
			if page:match("^%.") or page:match("^//") or page:match("^~") then
				prettyprint.write("server", "error", "Malicious page request, end." ) 
				-- oh really... 
				rq = http.response(404, nil, self:getpage(self["404"], method, page, version), method, page, version, clock)
			--[[elseif page == "/" then 
				prettyprint.write("server", "info", "Redirect to homepage .." ) 
				rq = http.response(302, {["Location"] = "/index.lua"}, "")--]]
			else
				local content, headers,status = self:getpage(page, options, method, version, clock) 
				local headers = headers or {}
	
				if content then 
					rq = http.response(status, headers, content, method, page, version, clock)
				else 
					local content, headers = self:getpage(self["404"], options, method, version, clock) 
					rq = http.response(404,headers,content, method, page, version, clock)
				end
			end
			if rq then 

				copas.send(conn, rq)

			end
		end

	end
end 

--[[copas.addserver(server, handle)
copas.loop()

--]]


return server 