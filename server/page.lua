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
	local newbuf = html:new()
	--newbuf.objectroot = newbuf
	newbuf.buffer = ""
	newbuf.buffloc = newbuf
	local env = {
		url = url;
		headers = headers;
		method = method;
		version = version;
		originalurl = originalurl or url;
		returnheaders = http.getnewheader();
		status = 200;
		objectroot = newbuf;
	}	

	local thisenv = getfenv()

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
		return rawget(newbuf, ind) or getmetatable(newbuf).__index(newbuf,ind,env)
	end
	}
	setmetatable(env, meta)

	local funcwrapmeta = {__index=function(tab,ind)  return env[ind] or thisenv[ind] end}

	env.require = function(name)
		if package.loaded[name] and package.loaded[name].forcereload then 
			package.loaded[name] = nil 
		end 
		local data = {require(name)}

		if type(data[1]) == "function" then 
			setfenv(data[1], setmetatable({}, funcwrapmeta))
		elseif type(data[1]) == "table" then 
			-- make a proxy to track our indices.
			local prx = {}
			local prxmeta = {__index = function(tab, ind) 
				if data[1][ind] then 
					if type(data[1][ind]) == "function" then 
						setfenv(data[1][ind],setmetatable({}, funcwrapmeta))
						return data[1][ind]
					else 
						return data[1][ind]
					end
				end
			end}
			return	setmetatable(prx,prxmeta)
		end
		return data[1]
	end

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


	local rets = {xpcall(function() return func(url, newh, method, version, env) end, debug.traceback )}
	local ok = true -- rets[1]
	local err = rets[2]
	if err then 
		prettyprint.write("pagegen", "error", err)
	end

	local headers, status
	--[[if not ok and err then 
		prettyprint.write("pagegen", "error", "error parsing " .. url .. ": " .. err)
		return ""
	else --]]
		headers = env.returnheaders
		status = env.status
	--end

	return newbuf.buffer, headers, status
end

function page.tryroute(server,url,root,headers,method,version)
			local routing = server.routing
			local route, newroot, forced = routing:findroute(url)
			
			if route or newroot then 
				return page.get(server, route or url, newroot or root, headers, method, version, true, url, forced)
			end

end

function page.get(server, url, root, headers, method, version, blockrecurse, originalurl, dontcheckorig)
	-- pagegen detector stuff here
	local file_location = root .. url
	local typeof = file_location:match("(%.%w+)$")
	local content, rheaders, status
	
	if typeof == ".lua" then 
		local func, err 
		if not dontcheckorig and originalurl and originalurl:match("(%.%w+)$") == ".lua" then 
			func, err = loadfile(root .. originalurl)
			if not func then 
				func, err = loadfile(file_location)
			end
		else 
			func,err = loadfile(file_location)
		end
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