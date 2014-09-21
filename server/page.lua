-- Page Generator module

local html = require "html"
local css = require "css"
local prettyprint = require "prettyprint"

local page_parser = {}

for index, value in pairs(html) do 
	if type(value) == "function" then 
		-- assume this is a generator function!
		page_parser[index] = value 
	end 
end 

-- DETECT COLLISSIONS ON TABLE!!!!!!!!

-- generate for url; (/index.lua); headers ([User-Agent] = bla)
-- method: GET/POST/ etc
-- version: 1.1 (http version)
function page.generate(url, headers, method, version)
	local env = {
		location = url;
		headers = headers;
		method = method;
		version = version;
		content = ""
	}
	
end