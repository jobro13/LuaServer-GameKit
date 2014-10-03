local login = {}

function login:write()
div.open {class="loginbox"}
h3.full {content = "Login to Full Moon"}
fieldset.open()
legend.open()
content "form"
legend.close()
label.open()
content "Username"
input {type = "text", name = "username"}
label.close()
label.open()
content "Password"
input.open {type = "text", name = "password"}
label.close()
fieldset.close()
div.close()
end

login.forcereload = true 

return login

--