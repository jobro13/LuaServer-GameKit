s = require "libsetting"
t = s.GetSettingHandler "settings.txt"
for i,v in pairs(t) do print(i,v) end

