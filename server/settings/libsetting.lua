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
	f = f:read("*all")
	for line in f:gmatch("[^\n]+") do 
		if not (line:sub(1,1) == "%") then 
			local sname, svalue = line:match("^%s*(.+)%s*=%s*(.+)")
			svalue = svalue:match("(.*)%%") or svalue 
			svalue = svalue:match("^(.*)[%s\t]+$") or svalue
			o[sname] = svalue 
		end
	end
	return o
end

return settings