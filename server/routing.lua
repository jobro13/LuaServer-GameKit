local routing = {}

function routing:new()
	return setmetatable({routes = {}}, {__index=self})
end

-- example request:
-- /home/profiles
--> does match pattern /*
--> does match pattern /home/*
--> the last one is the most specific: go for that route

-- add route
-- routename is the pattern
-- usagepage is the location of the script
-- as seen from our home directory (web)
function routing:add(routename, usagepage)

end





return routing