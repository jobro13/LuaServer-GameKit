urlencoding.parseurl()

local h = require "header"

doctype "html"
html.open()
head.open()
title.full "Full Moon"
link.open {rel = "stylesheet", href = "/main.css", type = "text/css"}

link.open {rel = "stylesheet", href='http://fonts.googleapis.com/css?family=Lato:100,300,400', type = 'text/css'}
head.close()
body.open()
h:write()

-- Start Register Form

form.open {class = "loginform", method = "post", action = "/processregister.lua"}
fieldset.open {class = "loginvalues"}
label.open()
content "Username"
input {type = "text", name = "username"}
label.close()
label.open()
content "Password"
input {type = "password", name = "password"}
div.open {class = "lowfont"}

p.full {content = "Do not choose any password you use on another site. This site is in deep alpha and is not known to be secure. Creating an account on this site is at your own risk!"}

div.close()
label.close()
label.open()
content "E-mail adress (valid!)"
div.open {class = "lowfont"}

p.full {content = "You need a valid email to play this game. Additional game info is sent to this email, so make sure it is valid!"}

div.close()
input {type = "email", name = "email"}
label.close()
label.open()

fieldset.close()
fieldset.open({class = "loginactions"})

input.open { class="btn floatl fullwidth", type="submit", name="submit", value="Register"}



form.close()

body.close()
html.close()