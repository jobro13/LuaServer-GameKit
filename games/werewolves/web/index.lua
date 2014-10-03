c = cookie.extract()

cookie.set("testbla", 
	{path = "/",expires =  (os.date("%a, %d-%b-%Y %H:%M:%S GMT", os.time() + 3600))})

local h = require "header"
local login = require "login"

doctype "html"
html.open()
head.open()
title.full "Full Moon"
link.open {rel = "stylesheet", href = "/main.css", type = "text/css"}

link.open {rel = "stylesheet", href='http://fonts.googleapis.com/css?family=Lato:100,400', type = 'text/css'}
head.close()
body.open()
h:write()

-- if not logged in then
section.open()
login:write()
section.close()



--[[section.open()
b.full "Welcome to full moon"

-- OMG EPIC

for i,v in ipairs(c) do 
	p.open()
	content("Yummeh cookies: " .. v)
	p.close()
end

section.close()

footer.open()

footer.close()--]]


body.close()
html.close()