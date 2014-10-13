local db = require "webutils/database"

print(db.insert({
	id = 10, 
	post = "Hello",
	test = true,
	},"test10"))