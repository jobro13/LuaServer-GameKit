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

local fcontext = {
	__call = function(tab,...)
		print("call " .. tab.Name, rawget(tab, "call"))
		for i,v in pairs(tab) do print(i,v) end
		if rawget(tab, "call") then 
			tab.call(...)
			return 
		end
		--local write = rawget(getfenv(), "write")
		if tab.Name == "close" then 
			-- add closing tags..
			local upname = tab.Parent.Name 
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

function fcontext.__newindex(tab, index, value)
	if type(value) == "function" then 
		return setmetatable({call = value}, fcontext)
	end
end

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
function html.doctype.call(dtype)
	print("ES")
	write("<!DOCTYPE " ..dtype ..">")
end
print ".."
print(html.doctype == doctype)
for i,v in pairs(html.doctype) do print(i,v) end
setmetatable(html, fcontext)

return html
