-- Lua HTML parser -- 

-- The idea is as following:
-- We can either add "tables" of elements to our environment
-- Or we can use functions for it;

-- element {}


local lhtml = {}

local objects = {
	["a"] = {
		"href"

	}


}

function lhtml.parse(data)
	return data
end 

function lhtml.gettag(what, fdata)

end



return lhtml