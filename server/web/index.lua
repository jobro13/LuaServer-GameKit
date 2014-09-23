c = cookie.extract()
for i,v in ipairs(c) do 
	print("Cookie! Yum. " ..  v)
end

print "data"

cookie.set("testcookie", {expires = (os.date("%c", os.time() + 3600))})

doctype "html"
html.open()
head.open()
title.full "Sample page"
head.close()
body.open()
b.full "Welcome to a sample page"
p.open()
b.full ("URL is " .. (originalurl))
p.close()
p.open()
b.full ("local time is " .. os.date() )
p.close()

-- OMG EPIC

for i,v in ipairs(c) do 
	p.open()
	content("Yummeh cookies: " .. v)
	p.close()
end


body.close()
html.close()