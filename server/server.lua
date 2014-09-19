local server = {}

local copas = require "copas"
local socket = require "socket"
local prettyprint = require "prettyprint"
local http = require "http"
local lfs = require "lfs"
local event = require "event"
local libsetting = require "settings/libsetting"

settings = libsetting.GetSettingHandler("settings/settings.txt")

local lhtml = require "lhtml"

-- I heard you didnt like PHP
-- So we use lau

server.IP = settings:get "bind_ip"
server.Port = tonumber(settings.get "bind_port")

server.RQs = 0

server.webdir = settings:get "webdir"

server.home = settings:get "page_404"
server["404"] = settings:get "page_home"

function server:new()
	return setmetatable({}, {__index=self})
end 

function server:Initialize()

	self.socket = socket.tcp()
	prettyprint.write("server", "info", "Starting server on " .. self.IP .. ":" .. self.Port)
	local ok, err = self.socket:bind(self.IP, self.Port)
	if ok then 
		prettyprint.write("server", "info", "OK: Server has bound to ip and port!")
	else 
		prettyprint.write("server", "error", "Server not online, error: "..tostring(err))
		os.exit()
	end 
	local listen = self.socket:listen()
	if listen then 
		prettyprint.write("server", "info", "OK: Server is online.")
	end 
	copas.addserver(self.socket, function(...) self.handle(self, ...) end)
end

function server:Start()
	prettyprint.write("server", "info", "Waiting for a connection ... ")
	while true do
		copas.step()
	end 
end

-- SERVER HANDLE IS A THREAD IT CLOSES LE CONNECTION ONCE IT RETURNS
-- oh yes copas 
-- oh yes

function server:getpage(page, ...)
	local i,err = io.open(self.webdir .. page, "r")
	prettyprint.write("server", "info", page .. " open: " .. tostring(i))
	if not i then 
		prettyprint.write("server", "error", "File open error: " .. err)
		return nil
	end
	if page:match("%.lua$") then 

		local content, headers = loadfile(self.webdir .. page)() --loadstring(i:read("*a"))(...)
		local headers = headers or {}
		if not headers["Cache-Control"] then 
			headers["Cache-Control"] = "no-cache"
		end
		return lhtml.parse(content), headers
	else 
		return i:read("*all"), {["Cache-Control"] = "no-cache"}
	end
end

server.handle = function(self,conn, efc, tr)
	self.RQs = self.RQs + 1
	local id = self.RQs 
	prettyprint.write("server", "info", "New connection, id: "..self.RQs)
	local request = copas.receive(conn, "*l")
	local METHOD, PAGE, VERSION 
	local cname = "Client " .. id .. " "
	if request then 
		local method, page, version = http.getrequest(request)
		if method and page and version then 
			prettyprint.write("server", "info", cname .. method .. " request on page: " .. page .. " (HTTP: "..version..")")
			--local cl = http.getclen(conn, copas.receive)
			local options = http.getremheader(conn, copas.receive)
			local cl = options["Content-Length"]
			if cl then 
				prettyprint.write("server", "info", cname.. " Content Length: ".. tostring(cl) )
			end
			local rq
			if page:match("^%.") or page:match("^//") then
				prettyprint.write("server", "error", "Malicious page request, end." ) 
				-- oh really...
				rq = http.response(404, nil, self:getpage(self["404"]))
			elseif page == "/" then 
				prettyprint.write("server", "info", "Redirect to homepage .." ) 
				rq = http.response(302, {["Location"] = "/index.lua"}, "")
			else
				local content, headers = self:getpage(page) 
				local headers = headers or {}
				local headers = nil
				if content then 
					prettyprint.write("server", "info", "Content, sending ... " ) 
					rq = http.response(200, headers, self:getpage(page) )
				else 
					rq = http.response(404, nil, self:getpage(self["404"]))
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