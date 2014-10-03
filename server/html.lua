-- Lua HTML parser

-- function constructor

local html = {}

local prettyprint = require "prettyprint"

function err(msg)
	prettyprint.write("htmlparse", "error", msg)
end

html.buffer = "" -- string to write to.


function html:clearbuffer()
	self.buffer = ""
end

-- not implemented
html.tagdata = {
	a = {
			close = true;
		},
	img = {
			close = false;
	}


}

function html:write(str)
	local root = self.__bufferlocation
	root.buffer = root.buffer .. str 
end 

-- optlist; list of things to do
-- ex {href = "wot"}
-- parent is the parent object
-- it is possible to traverse parent objects too yay
--  Name is the object name

function html:optparse(optlist,Parent,Name, bufo)
	-- this has to be done in order.
	-- so we cant use pairs 

	-- REMOVE ENTRIES FROM TABLE?
	local opened = false
	local wrotespace = false
	if optlist.open then -- also include an open tag
		self:write("<"..Name)
		opened = true 
	end
	local got = {
		content = true;
		open = true;
		close = true;
		fclose = true;
	}	
	-- okay now we are done!
	--print(Name)
	local partbuff = ""
	for i,v in pairs(optlist) do 
		if not got[i] then 
			if not opened then 
				opened = true 
				self:write("<"..Name.." ")
				wrotespace = true
			end
			if not wrotespace then 
				self:write(" ")
				wrotespace = true
			end
			partbuff = partbuff .. i .. "=\""..v.."\""
		end
	end
	if partbuff ~= "" or optlist.open then 
		partbuff = partbuff .. ">"
		self:write(partbuff)
	end
	if optlist.content then 
		self:write(optlist.content)
	end

	if optlist.close then 
		self:write("</"..Name..">")
	elseif optlist.fclose then 
		self:write("</"..Name..">")
	end
end

local fcontext = {
	__call = function(tab,...)
	--	print("call " .. tab.Name, rawget(tab, "call"))
		local args = {...}
		local o = tab.objectroot
		local options = args[1]
		--print "call"
		if type(options) == "string" then
			options = {content = options}
		end

	
		if rawget(tab, "call") then 
			args = {...}
			args[#args+1] = o.objectroot
			tab.call(o,unpack(args))
			return 
		end
		--local write = rawget(getfenv(), "write")
		if tab.Name == "close" then 
			-- add closing tags..
			local upname = tab.Parent
			if type(options) == "table" then 
				-- force close.
				options.fclose = true
			
				o:optparse(options, upname.Parent, upname.Name)
			else 
				o:optparse({fclose = true}, upname.Parent, upname.Name)
			end
		elseif tab.Name == "full" then 
			local options = options or {}
			options.open = true
			tab.Parent.close(options)
		elseif tab.Name == "open" then
			local options = options or {} 
			options.open=true
			o:optparse(options, tab.Parent.Parent, tab.Parent.Name)
		else
			o:optparse(options or {}, tab.Parent, tab.Name)
		end
	end,
	-- environment variable can be "hacked in" via getmetatable
	-- this is to pass the "right" buffer to the explicit object
	__index = function(tab, val, environment)
		


 		local origval = rawget(getfenv(), val) 
	--	print(origval)



		if tab == getfenv() or tab == rawget(tab, "objectroot") and origval then 
			return origval
		end
		--if rawget(tab, "__isroot") then 
			if rawget(html, val) then 
				return html[val]
			end
	
	--	print("I want a new index name " .. val )
		--local newf = rawget(getfenv(), "newf")


		return html.newf(tab,val,tab)
	
	end,
	__newindex = function(tab,ind,val)
		rawset(tab,ind,val)
	end
}

--[[function fcontext.__newindex(tab, index, value)
	if type(value) == "function" then 
		return setmetatable({call = value}, fcontext)
	end
end--]]

function html:newf(name, location, options, isexplicit)
	--print("Creating new O: " .. name)
	if not name then 
		err("Name not provided")
		return 
	end
	local o = {}
	o.Name = name
	o.Parent = location
	o.objectroot = self
	o.__bufferlocation = self.__bufferlocation
	o.__isexplicit = (isexplicit == true or nil)
	if options and type(options) == "table" then 
		for i,v in pairs(options) do 
			o[i] = v
		end 
	end
	setmetatable(o, fcontext)
	location[name] = o
	return o
end



local content = html:newf("content", html, nil, true)
function content:call(c, root)

	root:write(c)

end

local doctype = html:newf("doctype", html, nil, true)
function doctype:call(dtype)
	self.objectroot:write("<!DOCTYPE " ..dtype ..">")
end

html.objectroot=html
html.__bufferlocation = html

function html:new()
	local o = {buffer = ""}
	o.objectroot = o
	o.__isroot = true
	o.__bufferlocation = o
	return setmetatable(o, 
		fcontext
	)
end

setmetatable(html, fcontext)


return html
