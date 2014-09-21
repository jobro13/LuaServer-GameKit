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
function page.generate(url, file_location, headers, method, version)
	html.clearbuffer()
	local env = {
		location = url;
		headers = headers;
		method = method;
		version = version;
		content = ""
	}
	local func = loadfile(file_location)
	local meta = getmetatable(html)
	local wr = getfenv(func)
	wr.newf = html.newf
	setmetatable(wr, meta)
	func(url, headers, method, version)
	return html.buffer
end

return page