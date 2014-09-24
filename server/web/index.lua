c = cookie.extract()

print(originalurl, "URL")

cookie.set("testcookie", 
	{path = "/",expires =  (os.date("%a, %d-%b-%Y %H:%M:%S GMT", os.time() + 3600))})



doctype "html"
html.open()
head.open()
title.full "Full Moon"
link.open {rel = "stylesheet", href = "/main.css", type = "text/css"}

link.open {rel = "stylesheet", href='http://fonts.googleapis.com/css?family=Lato:100,400', type = 'text/css'}

head.close()
body.open()
header.open()
div.open({class="logo"})
--div.open()
div.open({class = "pagetitlebox"})
h1.full {content = "Full Moon", class = "pagetitle"} 
h2.full {content = "The most deadly game on the net", class = "pageundertitle"}
div.close()

nav.open()
a.full {href = "/index.lua", content = "Home", class = "nvlink"}
a.full {href = "/index.lua", content = "Profile", class = "nvlink"}
a.full {href = "/index.lua", content = "News", class = "nvlink"}
a.full {href = "/index.lua", content = "Town", class = "nvlink"}
a.full {href = "/index.lua", content = "Chat", class = "nvlink"}
nav.close()

div.open {class = "ghnoticebox"}
p.open {content = "by Jochem Brouwer", class = "ghnotice"}
br.open()
a.full {href = "https://github.com/jobro13/LuaServer-GameKit", content = "Fork me on GitHub!" }
p.close()
div.close()

--div.close()
div.close()
div.full{class="clearboth"}


header.close()
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