local login = {}

function login:write()
form.open {class="loginform", method = "post", action = "/processlogin.lua"}
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

login.forcereload = true -- < specify that this require must be
-- reloaded EVERY time it is required
-- so you can use it as sub-page
-- otherwise you need to restart the server
-- always 

return login

--