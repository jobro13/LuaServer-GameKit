local db = require "webutils/database"

db.create("test", {"id", "post", "test"}, "post")

print(db.insert({
	id = 10, 
	post = "Hello",
	test = true,
	},"test"))