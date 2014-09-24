c = cookie.extract()

print(originalurl, "URL")

cookie.set("testcookie", 
	{path = "/",expires =  (os.date("%a, %d-%b-%Y %H:%M:%S GMT", os.time() + 3600))})



doctype "html"
html.open()
head.open()
title.full "Sample page"
link.open {rel = "stylesheet", href = "/main.css", type = "text/css"}
head.close()
body.open()
header.open()
div.open()
h1.full("Page Title")
div.close()
header.close()
nav.open()

nav.close()

section.open()
b.full "Welcome to a sample page"
p.open()
b.full ("URL is " .. (originalurl))
p.close()
p.open()
b.full ("local time is " .. os.date("%a, %d-%b-%Y %H:%M:%S GMT") )
p.close()

-- OMG EPIC

for i,v in ipairs(c) do 
	p.open()
	content("Yummeh cookies: " .. v)
	p.close()
end

section.close()

footer.open()

footer.close()


body.close()
html.close()