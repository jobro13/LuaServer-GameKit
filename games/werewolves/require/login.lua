local login = {}

function login:write()
form.open {class="loginform"}
fieldset.open {class = "loginvalues"}
label.open()
content "Username"
input {type = "text", name = "username"}
label.close()
label.open()
content "Password"
input.open {type = "password", name = "password"}
label.close()
fieldset.close()
fieldset.open {class = "loginactions"}
input.open { class="btn floatl", type="submit", name="submit", value="Login"}

a{href = "/register.lua"} 
content "Register"
a.close()

form.close()
end

login.forcereload = true 

return login

--