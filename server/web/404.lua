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



doctype "html"
html.open()
head.open()
title.open()
content "Not Found"
title.close()
head.close()
body.open()
b.close {content = "Page not found ...", open = true} -- add elements, then close.
a.close {href = "/index.lua"; content = "Return home", open=true}
body.close()
html.close()

-- eof!