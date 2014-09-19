-- Question library to answer questions in a quick way
-- Handles "wrong" answers, but asks if nearest answer is ok

local libq = {}

function libq.GetClosedAnswer(question)
	print(question.. "\ny/n?")
	return io.read():sub(1,1) == "y"
end 

function libq.GetAnswer(question, panswers, fread)
	while true do 
		print(question)
		local ans = (fread and fread()) or io.read()
		local pans = ans:lower()
		local panslist = {}
		for i,v in pairs(panswers) do 
			if v:lower():match("^"..pans) then 
				table.insert(panslist, {i,v})
			end 
		end 
		if #panslist == 1 then 
			return unpack(panslist[1])
		elseif #panslist > 1 then 
			for i = 1, #panslist do 
				if libq.GetClosedAnswer("Did you mean: "..panslist[i][2].."?") then 
					return unpack(panslist[i])
				end 
			end 
		else
			print("I could not interpret your answer... try again.")
		end
	end 
end

return libq