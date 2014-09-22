sample = [=[<html>
<head>
<title>Not found</title>
</head>
<body>
<b>Page not found ...</b>
<a href="/index.lua">Return home</a>
</body>
</html>
]=]

-- The naive approach would work with tables.
-- This is a reasonable approach... However, there are a lot of problems;
-- Following the HTML structure in a table: if there
-- are two "div" blocks on the same level, and one indexes div,
-- the how is it supposed to know which div it means?
-- passing an extra number is just stupid
-- We will just use functions for this

for i,v in pairs(getfenv()) do print(i,v,7) end
print(doctype,'HI')
doctype "html"
html()
head()
title()
content "Not Found"
title.close()
head.close()
body()
b.close {content = "Page not found ..."} -- add elements, then close.
a.close {href = "/index.lua"; content = "Return home"}
body.close()
html.close()

-- eof!