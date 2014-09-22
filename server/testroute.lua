local route = require "routing"
local prettyprint = require "prettyprint"
local ser = require "serialize"

local my = route:new()

my:add("/home/*", "home")
my:add("/home/page/*", "home page")
my:add("/*", "root")
my:add("/home/test/*", "home test")
prettyprint.rwrite(ser.tabletostring(my.routes))

print(my:findroute("/home/profile")) --> "home"
print(my:findroute("/slf")) --> root
print(my:findroute("/home/test/my")) --> home test
print(my:findroute("/home/page/something")) --> home page
