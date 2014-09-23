local cookie = {}

--local prettyprint = require "prettyprint"

-- Extract cookies from "headers" table
--> returns a table with a list of cookies
--> Additionally, cookies[cookiename] is true if the cookie exists
--> In other words: use ipairs to traverse all cookies.

function cookie.extract()
	local cookies = {}
	if headers["Cookie"] then 
		for i,v in pairs(headers["Cookie"]) do 
			for match in string.gmatch(v, "([^;]+)") do 
				table.insert(cookies, match)
				cookies[match] = true
			end
		end
	end
	return cookies
end

-- when called with two args;
-- cookies.set(cookiename, headers)
-- else include options
-- ALWAYS INCLUDE HEADERS!!!!!!s
function cookie.set(cookiename, options)
	if not cookiename then 
		prettyprint.write("cookiegen", "error", "name missing")
	end
	local headern = "Set-Cookie"
	local headerv = cookiename
	for i,v in pairs(options or {}) do 
		-- stuff
		local value = v 
		if cookie.optparse[i] then
			value = cookie.optparse[i](v)
		end
		local add = i .. "=" .. v
		headerv  = headerv .. "; " .. add
	end
	returnheaders[headern] = headerv
	print(headern, headerv)
end

function cookie.remove(cookiename)
	cookies.set(cookiename, {expires = os.date("%c", 0)})
end

cookie.optparse = {}

return cookie