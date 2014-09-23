-- Page Generator module

-- Calls .lua files with:
-- url (this is the "routed" URL, so this may not be the source)
-- headers (all headers from the client in a table.)


local http = require "http" -- to get empty header table
local html = require "html"
local css = require "css"
local prettyprint = require "prettyprint"
local utils = require "pageutils"

local page = {}

for index, value in pairs(html) do 
	if type(value) == "function" then 
		-- assume this is a generator function!
		page[index] = value 
	end 
end 

local funcproxy = {}
function funcproxy.call(tab, ...)
	local tocall = tab.__functroot 
	local myenv = tab.__env
	local env = {}
	setmetatable(env, {__index = function(tab, ind) return rawget(myenv, ind) end})
	setfenv(tocall, env)
	return tocall(...)
end 


local utilproxy = {
	__index = function(tab,ind)
		local val = rawget(tab, "__root")
		if val and type(val[ind]) == "function" then 
			local obj = {}
			obj.__functroot = val[ind]
			obj.__env = rawget(tab, "__env")
			return setmetatable(obj, funcproxy)
		else 
			return (val and val[ind])
		end 
	end
}


-- DETECT COLLISSIONS ON TABLE!!!!!!!!

-- generate for url; (/index.lua); headers ([User-Agent] = bla)
-- file = already opened file
-- method: GET/POST/ etc
-- version: 1.1 (http version)
function page.generate(url, func, headers, method, version, originalurl)
	html.clearbuffer()
	local env = {
		url = url;
		headers = headers;
		method = method;
		version = version;
		originalurl = originalurl;
		returnheaders = http.getnewheader();
	}

	local meta = {
		__index = function(tab,ind)
		if utils[ind] then 
			local proxy = {}
			proxy.__env = env 
			proxy.__root = utils[ind]
			return setmetatable(proxy, utilproxy)
		end
			return html[ind]
	end
	}
	setmetatable(env, meta)
	--local wr = getfenv(func)
	--wr.newf = html.newf
	--setmetatable(wr, meta)
	setfenv(func,env)

	-- make headers read only

	local newh = {}
	for option, values in pairs(headers) do 
		if #values == 1 then 
			newh[option] = values[1]
		else 
			newh[option] = values
		end
	end


	local rets = {pcall(function() return func(url, newh, method, version, env) end)}
	local ok = rets[1]
	local err = rets[2]
	local headers, status
	if not ok and err then 
		prettyprint.write("pagegen", "error", "error parsing " .. url .. ": " .. err)
		return ""
	else 
		headers = rets[2]
		status = rets[3]
	end
	
	--print(html.buffer)
	return html.buffer, headers, status
end

function page.tryroute(server,url,root,headers,method,version)
			local routing = server.routing
			local route, newroot = routing:findroute(url)
			if route then 
				return page.get(server, route, newroot or root, headers, method, version, true, url)
			end

end

function page.get(server, url, root, headers, method, version, blockrecurse, originalurl)
	-- pagegen detector stuff here
	local file_location = root .. url
	print(file_location)
	local typeof = file_location:match("(%.%w+)$")
	local content, headers, status
	if typeof == ".lua" then 
		local func,err = loadfile(file_location)
		if err then 

		else 
			content, headers, status = page.generate(url, func, headers, method, version, originalurl)
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