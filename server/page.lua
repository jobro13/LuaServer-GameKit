-- Page Generator module

local html = require "html"
local css = require "css"
local prettyprint = require "prettyprint"

local page = {}

for index, value in pairs(html) do 
	if type(value) == "function" then 
		-- assume this is a generator function!
		page[index] = value 
	end 
end 

-- DETECT COLLISSIONS ON TABLE!!!!!!!!

-- generate for url; (/index.lua); headers ([User-Agent] = bla)
-- file = already opened file
-- method: GET/POST/ etc
-- version: 1.1 (http version)
function page.generate(url, func, headers, method, version)
	html.clearbuffer()
	local env = {
		location = url;
		headers = headers;
		method = method;
		version = version;
		content = ""
	}

	local meta = getmetatable(html)
	--local wr = getfenv(func)
	--wr.newf = html.newf
	--setmetatable(wr, meta)
	setfenv(func,html)
	func(url, headers, method, version)
	--print(html.buffer)
	return html.buffer
end

function page.tryroute(server,url,root,headers,method,version)
			local routing = server.routing
			local route = routing:findroute(url)
			print(route)
			if route then 
				return page.get(server, route, root, headers, method, version, true)
			end

end

function page.get(server, url, root, headers, method, version, blockrecurse)
	-- pagegen detector stuff here
	local file_location = root .. url
	print(file_location)
	local typeof = file_location:match("(%.%w+)$")
	local content, headers, status
	if typeof == ".lua" then 
		local func,err = loadfile(file_location)
		if err then 

		else 
			content, headers, status = page.generate(url, func, headers, method, version)
		end
	elseif typeof == ".luacss" then 
		-- really
	else
		content = io.open(file_location, "r")
		if not content then 
			-- do nothing
		else
			content = content:read("*a")
			status = 200
		end
	end
	if not content and not blockrecurse then
		print(server.routing)
		content,headers,status = page.tryroute(server,url,root,headers,method,version)
	end
 	return content, headers, status
end

return page