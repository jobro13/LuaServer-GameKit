-- Lua HTML parser

-- function constructor

local html = {}

local prettyprint = require "prettyprint"

function err(msg)
	prettyprint.write("htmlparse", "error", msg)
end

html.buffer = "" -- string to write to.

function html.clearbuffer()
	html.buffer = ""
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

function write(str)
	html.buffer = html.buffer .. str 
end 

-- optlist; list of things to do
-- ex {href = "wot"}
-- parent is the parent object
-- it is possible to traverse parent objects too yay
--  Name is the object name

function optparse(optlist,Parent,Name)
	-- this has to be done in order.
	-- so we cant use pairs 

	-- REMOVE ENTRIES FROM TABLE?
	local opened = false
	local wrotespace = false
	if optlist.open then -- also include an open tag
		write("<"..Name)
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
				write("<"..Name.." ")
				wrotespace = true
			end
			if not wrotespace then 
				write(" ")
				wrotespace = true
			end
			partbuff = partbuff .. i .. "=\""..v.."\""
		end
	end
	if partbuff ~= "" or optlist.open then 
		partbuff = partbuff .. ">"
		write(partbuff)
	end
	if optlist.content then 
		write(optlist.content)
	end

	if optlist.close then 
		write("</"..Name..">")
	elseif optlist.fclose then 
		write("</"..Name..">")
	end
end

local fcontext = {
	__call = function(tab,...)
	--	print("call " .. tab.Name, rawget(tab, "call"))
		local args = {...}
		local options = args[1]
		if type(options) == "string" then
			options = {content = options}
		end
	
		if rawget(tab, "call") then 
			tab.call(...)
			return 
		end
		--local write = rawget(getfenv(), "write")
		if tab.Name == "close" then 
			-- add closing tags..
			local upname = tab.Parent
			if type(options) == "table" then 
				-- force close.
				options.fclose = true
			
				optparse(options, upname.Parent, upname.Name)
			else 
				optparse({fclose = true}, upname.Parent, upname.Name)
			end
		elseif tab.Name == "full" then 
			local options = options or {}
			options.open = true
			tab.Parent.close(options)
		elseif tab.Name == "open" then 
			optparse({open = true}, tab.Parent.Parent, tab.Parent.Name)
		else
			optparse(options or {}, tab.Parent, tab.Name)
		end
	end,
	__index = function(tab, val)
		local origval = rawget(getfenv(), val) 
	--	print(origval)
		if tab == getfenv() or tab == html and origval then 
			return origval
		end
	--	print("I want a new index name " .. val )
		--local newf = rawget(getfenv(), "newf")
		return html.newf(val, tab)
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

function html.newf(name, location, options)
	if not name then 
		err("Name not provided")
		return 
	end
	local o = {}
	o.Name = name
	o.Parent = location
	if options and type(options) == "table" then 
		for i,v in pairs(options) do 
			o[i] = v
		end 
	end
	setmetatable(o, fcontext)
	location[name] = o
	return o
end

local newf = html.newf

local content = newf("content", html)
function content.call(c)
	write(c)
end

local doctype = newf("doctype", html)
function doctype.call(dtype)
	write("<!DOCTYPE " ..dtype ..">")
end

setmetatable(html, fcontext)

return html
