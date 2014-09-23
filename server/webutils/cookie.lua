local cookies = {}

local prettyprint = require "prettyprint"

-- Extract cookies from "headers" table
--> returns a table with a list of cookies
--> Additionally, cookies[cookiename] is true if the cookie exists
--> In other words: use ipairs to traverse all cookies.
function cookies:extract(headers)
	local cookies = {}
	if headers["Cookie"] then 
		for match in string.gmatch(headers["Cookie"], "([^;]+)") do 
			table.insert(cookies, match)
			cookies[match] = true
		end
	end
	return cookies
end

-- when called with two args;
-- cookies.set(cookiename, headers)
-- else include options
-- ALWAYS INCLUDE HEADERS!!!!!!s
function cookies:set(cookiename, options, headers)
	local headers = headers
	if not cookiename or not headers then 
		if options.__data then 
			headers = options
		else 
			prettyprint.write("cookiegen", "error" "cookiename or headers missing")
		end
	end
	local headern = "Set-Cookie"
	local headerv = cookiename
	for i,v in pairs(options or {}) do 
		-- stuff
		local value = v 
		if cookies.optparse[i] then
			value = cookies.optparse[i](v)
		end
		local add = i .. "=" .. v
		headerv  = headerv .. "; " .. add
	end
	headers[headern] = headerv
end

function cookies:remove(cookiename, headers)
	if not headers then 
		prettyprint.write("cookiegen", "error" "headers missing")
	end
	cookies.set(cookiename, {expires = os.date("%c", 0)}, headers)
end

return cookies