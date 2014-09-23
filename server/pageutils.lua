local ret = {}

-- pageutils are basically plugins!
-- plugins should be written as objects with method;
-- via self you can get into the environment of the page!

local root = "./webutils"

local function add(name, location)
	o = require(location or (root .. "/"..name))
end 

add("cookie")

return ret 