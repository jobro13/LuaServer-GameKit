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
function funcproxy.__call(tab, ...)
	local tocall = tab.__functroot 
	local myenv = tab.__env
	local env = {}
	local glob = getfenv()
	setmetatable(env, {__index = function(tab, ind) return rawget(myenv, ind) or glob[ind] end})
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
			setmetatable(obj, funcproxy)
			rawset(tab,ind,obj)
			return obj
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
		originalurl = originalurl or url;
		returnheaders = http.getnewheader();
		status = 200;
	}

	local meta = {
		__index = function(tab,ind)
		if utils[ind] then 
			local proxy = {}
			proxy.__env = env 
			proxy.__root = utils[ind]
			local myproxy = setmetatable(proxy, utilproxy)
			rawset(tab,ind,myproxy)
			return myproxy
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
		headers = env.returnheaders
		status = env.status
	end
	
	return html.buffer, headers, status
end

function page.tryroute(server,url,root,headers,method,version)
			local routing = server.routing
			local route, newroot = routing:findroute(url)
			
			if route or newroot then 
				return page.get(server, route or url, newroot or root, headers, method, version, true, url)
			end

end

function page.get(server, url, root, headers, method, version, blockrecurse, originalurl)
	-- pagegen detector stuff here
	local file_location = root .. url
	local typeof = file_location:match("(%.%w+)$")
	local content, rheaders, status

	if typeof == ".lua" then 
		local func,err = loadfile(file_location)
		if err then 
			prettyprint.write("pagegen", "error", err)
		else 
			content, rheaders, status = page.generate(url, func, headers, method, version, originalurl)
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
		content,rheaders,status, typeof = page.tryroute(server,url,root,headers,method,version)
	end

 	return content, rheaders, status, typeof
end

return page