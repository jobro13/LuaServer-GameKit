term={ 
        output=io.write, 
        clear = function () term.output("\027[2J") end, 
        cleareol = function () term.output("\027[K") end, 
        goto = function (l,c) term.output("\027[",l,";",c,"H") end, 
        goup = function (n) term.output("\027[",n or 1,";","A") end, 
        godown = function (n) term.output("\027[",n or 1,";","B") end, 
        goright = function (n) term.output("\027[",n or 1,";","C") end, 
        goleft = function (n) term.output("\027[",n or 1,";","D") end, 
        color = function (f,b) term.output("\027[",f,";",b,"m") end, 
        save = function () term.output("\027[s") end, 
        restore = function () term.output("\027[u") end, 
} 

-- ANSI

local function isWindows()
  return type(package) == 'table' and type(package.config) == 'string' and package.config:sub(1,1) == '\\'
end

local supported = not isWindows()
if isWindows() then supported = os.getenv("ANSICON") end

local keys = {
  -- reset
  reset =      0,

  -- misc
  bright     = 1,
  dim        = 2,
  underline  = 4,
  blink      = 5,
  reverse    = 7,
  hidden     = 8,

  -- foreground colors
  black     = 30,
  red       = 31,
  green     = 32,
  yellow    = 33,
  blue      = 34,
  magenta   = 35,
  cyan      = 36,
  white     = 37,

  -- background colors
  blackbg   = 40,
  redbg     = 41,
  greenbg   = 42,
  yellowbg  = 43,
  bluebg    = 44,
  magentabg = 45,
  cyanbg    = 46,
  whitebg   = 47
}

local escapeString = string.char(27) .. '[%dm'
local function escapeNumber(number)
  return escapeString:format(number)
end

local function escapeKeys(str)

  if not supported then return "" end

  local buffer = {}
  local number
  for word in str:gmatch("%w+") do
    number = keys[word]
    assert(number, "Unknown key: " .. word)
    table.insert(buffer, escapeNumber(number) )
  end

  return table.concat(buffer)
end

local function replaceCodes(str)
  str = string.gsub(str,"(%%{(.-)})", function(_, str) return escapeKeys(str) end )
  return str
end

-- public

local function ansicolors( str )
  str = tostring(str or '')

  return replaceCodes('%{reset}' .. str .. '%{reset}')
end


color = setmetatable({noReset = replaceCodes, reset = function() io.write( ansicolors() ) end}, {__call = function (_, str) io.write( replaceCodes (str) ) end})

return color 