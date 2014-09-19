local Event = {}

function Event:Call()
	self:fire()
end

function Event:Constructor()
	self.List = {}
end

function Event:connect(func)
	table.insert(self.List, func)
	local ret = {}
	function ret:disconnect()
		for i,v in pairs(self.List) do
			if v == func then
				self.List[i] = nil
				break
			end
		end
	end
	return ret
end

function Event:fire(...)
	local args = {...}
	for i,v in pairs(self.List) do 
		delay(0, function() v(unpack(args)) end)
	end
end

function Event:wait()
	-- well well well HOW IN THE WORLD ARE WE GOING TO DO THIS!?
	--> BUSY WAIT!? (no?)
	--> any kind of awesome coroutine hack?
end

function Event:new()
	return setmetatable({}, {__index=self})
end

return Event