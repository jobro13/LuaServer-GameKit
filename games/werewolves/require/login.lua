local login = {}

function login:write()
div.open {class="loginbox"}
h3.full {content = "Login or Register"}
div.open {class = "button green left", content = "Login"}
div.close()
div.open {class = "button blue right", content = "Register"}
div.close()
end

return login