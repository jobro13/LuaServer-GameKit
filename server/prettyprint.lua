-- Prettyprint module
-- Yay.

local color = require "color"

-- We want pretty output
-- some cool facilities yes

local plib = {}

plib.data = {
	default = {
		from = {
			addbe = "%{bright blue}[%{reset}",
			addaf = "%{bright blue} - %{reset}"
		},
		typemsg = {
			addbe = "",
			addaf = "%{bright blue}]%{reset}"
		},
		msgend = "%{reset}\n",
		msgstart = "%{reset}"
	},
	error = {
		from = {
			addbe = "%{bright red}[%{reset}",
			addaf = "%{bright red} - %{reset}%{blink}"
		},
		typemsg = {
			addbe = "",
			addaf = "%{reset}%{red}]%{reset}"
		},
		msgend = "%{reset}\n",
		msgstart = "%{bright red}"

	},
	warning = {
		from = {
			addbe = "%{underline yellow}[",
			addaf = "%{underline yellow} - "
		},
		typemsg = {
			addbe = "",
			addaf = "]%{reset}",
		},
		msgend = "%{reset}\n",
		msgstart = "%{bright yellow}"
	},
	info = {
		from = {
			addbe = "%{bright green}[%{white}",
			addaf = "%{bright green} - %{white}"
		},
		typemsg = {
			addbe = "",
			addaf = "%{bright green}]"
		},
		msgend = "%{reset}\n",
		msgstart = "%{white}"
	}
}

local reset = "%{reset}"
local hexpat = "0x"

local function mkcolor(color)
	return {addbe = "%{"..color.."}"}
end


plib.subs = {
	["function"] = {addbe = "%{magenta}", addaf = reset},
	["0x%x+"] = {addbe = "%{cyan}", addaf = reset},
	["table"] = {addbe = "%{blue}"},
	["number"] = mkcolor "yellow",
	["string"] = mkcolor "dim yellow",
	["userdata"] = mkcolor "dim red",
	

}

plib.out = color

function plib.constrmsg(from, msgtype, msg)
	local data = plib.data[msgtype] or plib.data.default 
	local out = ""
	out = out .. (data.from.addbe or "")
	out = out .. from .. (data.from.addaf or "")
	out = out .. (data.typemsg.addbe or "") .. msgtype .. (data.typemsg.addaf or "")

	local head = out:gsub("%%{[^}]*}", "")

	local headlen = head:len()

	out = out .. (reset) .. " " .. (data.msgstart or "") .. msg .. (data.msgend or "")
	for i,v in pairs(plib.subs) do 
		out = out:gsub(i, function(str) return (reset) .. (v.addbe or "") .. str .. (v.addaf or "") .. (reset) ..  (data.msgstart or "") end)
		if v.str then 
			out = out:gsub(v.str[1], (reset) .. v.str[2] .. (reset) .. (data.msgstart or ""))
		end

	end 

	local linecount = 0
	for match in string.gmatch(out, "\n") do 
		linecount = linecount + 1
	end 

	local line = 0

	out = out:gsub("\n", function() 
		line = line + 1 
		if line ~= linecount then  
			return "\n" .. string.rep(" ", headlen + 1) 
		else 
			return "\n"
		end
	end)

	return out 
end 

function plib.write(from, msgtype, ... )
	local a = " "
	for i,v in pairs{...} do 
		a = a .. tostring(v) .. "\t"
	end
	local msg = plib.constrmsg(from,msgtype,a)
	plib.out(msg)
end 

function plib.rwrite(...)
	local a = ""
	for i,v in pairs{...} do 
		a = a .. tostring(v) .. "\t"
	end
	
	plib.out(plib.constrmsg("plib raw", "info", a))
end

return plib

