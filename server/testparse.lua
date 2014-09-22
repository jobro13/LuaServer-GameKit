page = require "page"

print(page.generate ( "/index.lua", "web/index.lua", {}, "GET", 1.1))

