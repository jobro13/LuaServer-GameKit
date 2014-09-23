local args = {...}

print(args[1])

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
body.close()
html.close()

print(cookie)
print(cookie.testenv)
print("HUHWOT")
cookie.testenv()
print(cookies.testenv.__functroot)
print(wot.fasdf.ffdlfjjs.sdf.f.fd.e)