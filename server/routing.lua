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
-- optional: pageroot, to define a new page root.
-- this is handy for.. online games :) 
-- you can redirect /home/game/gamename/* to
-- a new root directory!
-- as seen from our home directory (web)
function routing:add(routename, usagepage, newroot)
	-- first check if this thing is more specific
	-- we create a tree like that
	-- .. hrm thats hard.

	-- FIRST: convert routename to a Lua pattern
	local pattern = routename
	pattern = pattern:gsub("[^%.]%*", ".*")

	--> new routename /
	--> check

	local deep, deeplevel = nil, 0
	local low, lowlevel = nil, math.huge
	local function scan(where, level)
		for rname, rdata in pairs(where) do 
			-- ex /page matches /.+
			if not (type(rname) == "number") then 
				if rname:match(pattern) then
					if level < lowlevel then 
						lowlevel = level 
						low = where 
					end
				end
			-- WOT
			-- ex /.+
				if pattern:match(rname) then 
					if level > deeplevel then
						deeplevel = level 
						deep = rdata
					end 
				end
				scan(rdata, level + 1)
			end
		end
	end
	scan(self.routes, 1)
	if deep then 
		if not deep.specific then 
			deep.specific = {[pattern] = {usagepage, newroot}}
		else
			deep.specific[pattern] = {usagepage, newroot}
		end
	end
	if low then 
		local my = {[pattern] = {usagepage, newroot,specific = {}}}
		for i,v in pairs(low) do 
			my[pattern].specific[i] = v
		end 
		self.routes = my
	end 
	if not low and not deep then 
		self.routes[pattern] = {usagepage}
	end
end

function routing:findroute(sign)
	local deep = nil
	local newroot = nil
	local dlevel = 0
	function scan(where, level)
		for rname, rdata in pairs(where) do 
			if not (type(rname) == "number") then 
				print(sign,rname)
				if sign:match(rname) then 
					if level > dlevel then 
						deep = rdata[1] -- usage file
						newroot = rdata[2]
						dlevel = level
					end
					-- if it does match, it can match specific patterns too!
					if rdata.specific then
						scan(rdata.specific, level + 1)
					end
				end
			end
		end
	end
	scan(self.routes, 1)
	return deep, newroot
end 



return routing