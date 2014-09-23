local ret = {}

-- pageutils are basically plugins!
-- plugins should be written as objects with method;
-- the page environment is loaded into the function environment
-- (via ... haxy ways)


local root = "./webutils"

local function add(name, location)
	ret[name] = require(location or (root .. "/"..name))
end 

add("cookie")

return ret 