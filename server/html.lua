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

function optparse(optlist,Parent,Name)
	-- this has to be done in order.
	-- so we cant use pairs 

	-- REMOVE ENTRIES FROM TABLE?
	if oplist.open then -- also include an open tag
		write("<"..Name..">")
	end
	local got = {
		content = true;
		open = true;
	}	
	-- okay now we are done!
	local wrotehead = false 
	local partbuff = ""
	for i,v in pairs(optlist) do 
		if not got[i] then 
			if not wrotehead then 
				wrotehead = true 
				partbuff = partbuff .. "<" .. Name .. " "
			end
			partbuff = partbuff .. i .. "=\""..v.."\""
		end
	end
	partbuff = partbuff .. ">"
	write(partbuff)
	if optlist.content then 
		write(optlist.content)
	end

end

local fcontext = {
	__call = function(tab,...)
		print("call " .. tab.Name, rawget(tab, "call"))
		local args = {...}
		for i,v in pairs(tab) do print(i,v) end
		if rawget(tab, "call") then 
			tab.call(...)
			return 
		end
		--local write = rawget(getfenv(), "write")
		if tab.Name == "close" then 
			-- add closing tags..
			local upname = tab.Parent.Name 
			local options = args[1]
			if type(options) == "table" then 
				optparse(options, upname, tab.Name)
			end
			write("</"..upname..">")
		else
			local name = tab.Name
			write("<"..name..">")
		end
	end,
	__index = function(tab, val)
		local origval = rawget(getfenv(), val) 
		print(origval)
		if tab == getfenv() or tab == html and origval then 
			return origval
		end
		print("I want a new index name " .. val )
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
	print("yes, content")
	write(c)
end

local doctype = newf("doctype", html)
function doctype.call(dtype)
	print("ES")
	write("<!DOCTYPE " ..dtype ..">")
end
print("..")
print(rawget(html.doctype,"call"), "call")
setmetatable(html, fcontext)

return html
