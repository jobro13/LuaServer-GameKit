local serialize = {}

serialize.midstr = " = "

function serialize.tabletostring(input, got_t, header, level)
	local data = {}
	local max = 0
	local tmax = 0

	local out = string.rep("\t", (level or 0)-1) .. (header or (not level and (tostring(input) .. " dump")) or "") .. "\n"
	local got_t = got_t or {}
	if not level then 
		got_t[input] = #got_t + 1
		table.insert(got_t, input)
	end
	local level = level or 0 
	
	
	local function line(str, type)
		
		if type ~= "table" then 
			out = out .. string.rep("\t", level) .. str .. "\n"
		end
	end 

	local function feed_data(fstr, estr, lstr, type, vtype)
		if type == "table" then 
			return 
		end
		table.insert(data, {string.rep("\t", level), fstr, estr, lstr.."\n"})
		if fstr:len() > max then 
			max = fstr:len()
		end

		if estr:len() > tmax and not (vtype == "table") then 
			tmax = estr:len()
		end
	end

	local function mkstr(i, fromindex, valtype)
		if type(i) == "table" then
			if got_t[i] then 
				return "loop_table "..(tostring(i):match("0x%x+") .. " ID: " .. got_t[i])
			end 
			got_t[i] = #got_t + 1
			table.insert(got_t, input)
			local str = serialize.tabletostring(i, got_t, (fromindex and ": table:"), level+1)
			return str:sub(1, str:len()-1) 
		else
			return tostring(i)
		end
	end 

	for i,v in pairs(input) do 

		feed_data(mkstr(i) .. (type(i) ~= "table" and " (" .. type(i) .. ")" or ""), mkstr(v, i), (type(v) ~= "table" and  " ("..type(v)..")" or ""), type(i), type(v))
	end 

	-- construct the string 

	for i, v in pairs(data) do 
		local len = v[2]:len()
		if len < max then 
			v[2] = v[2] .. string.rep(" ", (max-len))
		end
		if v[3]:len() < tmax then 
			v[3] = v[3] .. string.rep(" ", (tmax-v[3]:len())) 
		end
		out = out .. v[1] .. v[2] .. serialize.midstr .. v[3] .. v[4]
	end 


	return out 
end

return serialize