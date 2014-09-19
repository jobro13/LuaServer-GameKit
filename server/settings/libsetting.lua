local settings = {}

function settings:get(key)
	return tostring(self[key])
end

-- Returns a SettingHandler object
-- Only works if filename exists! 
-- so just provide a name instead of a file hmm
function settings.GetSettingHandler(filename)
	local f , err = io.open(filename)
	if not f then 
		prettyprint.write("libsetting", "error", "Could not open " .. filename .. " because: " .. err)
		return nil 
	end 
	local o = {}
	setmetatable(o, 
		{__index = settings})
	for line in io.lines(filename) do 
		print(line)
		if not line:sub(1,1) == "%" then 
			print "ok"
			local sname, svalue = line:match("([^=]*)=%s*(.*)%s*%%?")
			print(sname, svalue)
			o[sname] = svalue 
		end
	end
	return o
end

return settings