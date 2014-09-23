local args = {...}

print(args[1])

doctype "html"
html.open()
head.open()
title.full "Sample page"
head.close()
body.open()
b.full "Welcome to a sample page"
b.full ("URL is " .. (args[5].originalurl))
body.close()
html.close()
