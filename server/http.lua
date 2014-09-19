-- HTTP module

local http = {}

-- returns strings only

http.httpversion = "1.1" -- orly

http.statuscodes = {
	[200] = "OK",
	[302] = "Found",
	[404] = "NOT FOUND"
}

-- returns a http response
-- status: status code
-- headers: table; indices = header value; values = their values
-- content = http content field
-- conn: the LuaSocket connection
-- writef: the write function (provided by copas, or use your own)
function http.response(status,headers,content, conn, writef)
	local out = ""
	out = "HTTP/"..http.httpversion.." "..status.." ".. (http.statuscodes[tonumber(status) or ""] or "WAT") .."\r\n"
	local headers = headers or {}
	for i,v in pairs(headers) do 
		out = out .. i .. ": "..v .. "\r\n"
	end 
	out = out .. "Content-Type: text/html\r\n"
	out = out .. "Content-Length: ".. (content:len())  .. "\r\n\r\n"
	out = out .. content 

	return out
end

-- returns all header options into a table
function http.getremheader(conn, readf)
	local line = " "
	local out = {}

	while line and line ~= "" and line ~= "\r\n" do 
		line = readf(conn, "*l")
		local option, value = line:match("([^:]*) (.*)")
		if option and value then 
			out[option] = value 
		end 
	end 
	return out 
end


-- reads from conn with provided read function
-- until content length is found; that is returned as number
function http.getclen(conn, readf)
	local pat = "Content-Length: (%d+)\r\n"
	local this 
	local line = ""
	while (not this) and line ~= "" and line ~= "\r\n" do 
		line = readf(conn, "*l")
		this = line:match(pat)
	end 
	return this 
end

-- returns method; page; version
function http.getrequest(line)
	local method, page, version = line:match("(%w+) ([%S]*) HTTP/(%d+%.?%d*)")
	return method,page,version
end 


return http 