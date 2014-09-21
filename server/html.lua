-- Lua HTML parser

-- function constructor

local html = {}

local prettyprint = require "prettyprint"

function err(msg)
	prettyprint.write("htmlparse", "error", msg)
end

html.buffer = "" -- string to write to.

-- not implemented
html.tagdata = {
	a = {
			close = true;
		}
	img = {
			close = false;
	}


}

function write(str)
	html.buffer = html.buffer .. str 
end 

local fcontext = {
	__call = function(tab,...)
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
		newf()
	end
}

function fcontext.__newindex(tab, index, value)
	if type(value) == "function" then 
		return setmetatable({call = value}, fcontext)
	end
end

local function newf(name, location, options)
	if not name then 
		err("Name not provided")
		return 
	end
	local o = {}
	o.Name = nameof
	o.Parent = location
	if options and type(options) == "table" then 
		for i,v in pairs(options) do 
			o[i] = v
		end 
	end
	setmetatable(o, fcontext)
	location[name] = o
end

setmetatable(html, fcontext)

return html
