local hlib = {}

function hlib:write()
print(header)
header.open()
div.open({class="logo"})
--div.open()
div.open({class = "pagetitlebox"})
h1.full {content = "Full Moon", class = "pagetitle"} 
h2.full {content = "The most deadly game on the net", class = "pageundertitle"}
div.close()

nav.open()
a.full {href = "/home.lua", content = "Home", class = "nvlink"}
a.full {href = "/profile.lua", content = "Profile", class = "nvlink"}
a.full {href = "/news.lua", content = "News", class = "nvlink"}
a.full {href = "/town.lua", content = "Town", class = "nvlink"}
a.full {href = "/chat.lua", content = "Chat", class = "nvlink"}
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

end

return hlib