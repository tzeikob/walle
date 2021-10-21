-- Main lua file of the conky config file

-- Global file and dir paths
user_home_dir = "/home/#USER"
working_dir = user_home_dir .. "/.config/#PKG_NAME"
langs_dir = working_dir .. "/langs"
wallpapers_dir = user_home_dir .. "/pictures/wallpapers"
config_file = working_dir .. "/.wallerc"

-- Global configuration properties
status = "init"
debug_mode = "disabled"
lang = "en"
theme = "light"
wallpaperInterval = 0
wallpapers = {}
fonts = { clock = "", date = "", text = "" }
i18n = {}

-- Extra conky variables interpolated at init
statics = {
  rls_name = "",
  rls_version = "", 
  rls_codename = "",
  rls_arch = ""
}

-- Extra conky variables interpolated at interval
vars = {
  time_p = "",
  time_P = "",
  month_name = "",
  day_name = "",
  net_name = "",
  net_ip = ""
}

-- Splits the string by the given delimiter
function string:split (delimiter, lazy)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find (self, delimiter, from)

  while delim_from do
    table.insert (result, string.sub (self, from , delim_from - 1))
    from = delim_to + 1

    -- Split only by the first occurence if lazy is given
    if lazy then
      break
    end

    delim_from, delim_to = string.find (self, delimiter, from)
  end

  table.insert (result, string.sub (self, from))

  return result
end

-- Checks if the string matches the given pattern
function string:matches (pattern)
  if self ~= nil then
    return string.find (self, pattern)
  end

  return self
end

-- Trims any whitespace of the string
function string:trim ()
  if self ~= nil then
    return self:gsub ("^%s*(.-)%s*$", "%1")
  end

  return self
end

-- Executes a native system command given as string
function string:exec ()
  local file = io.popen (self)
  local output = file:read ("*a")
  file:close ()

  return output
end

-- Logs a message if logging level is on debug mode
function log (message)
  if debug_mode == "enabled" then
    print (message)
  end
end

-- Reads the configuration property down to the given json path
function config (path, default)
  local jq = "jq --raw-output " .. path .. " " .. config_file .. " | sed -z '$ s/\\n$//'"
  local value = jq:exec ()

  -- Return default if not found
  if value == "null" then
    return default
  end

  return value
end

-- Executes an operation after the given cycles have passed
function interval (cycles, updates, operation)
  local timer = (updates % cycles)

  if timer == 0 or status == "init" then
    operation ()
  end
end

function init ()
  -- Initialize global properties from the config file
  debug_mode = config (".debug", "disabled")
  lang = config ('.lang', "en")
  theme = config (".theme", "light")
  wallpaperInterval = tonumber (config (".wallpaper", "0"))
  fonts["clock"] = config (".clock", "")
  fonts["date"] = config (".date", "")
  fonts["text"] = config (".text", "")

  -- Initialize release static interpolation variables
  local lsb_release = "lsb_release --short -icr"
  local output = lsb_release:exec ()
  local parts = output:split("\n")

  statics["rls_name"] = parts[1]
  statics["rls_version"] = parts[2]
  statics["rls_codename"] = parts[3]

  local uname = "uname -p | sed -z '$ s/\\n$//'"
  local output = uname:exec ()

  statics["rls_arch"] = output

  -- Load the i18n texts corresponding to the choosen lang
  local lines = io.lines (langs_dir .. "/" .. lang .. ".dict")

  for line in lines do
    if line:matches ("^[a-zA-Z0-9-_][a-zA-Z0-9-_\.]* *=.*") then
      local parts = line:split ("=", true)
      local key, value = parts[1]:trim (), parts[2]:trim ()

      -- Interpolate any given static variables
      for varKey, varValue in pairs (statics) do
        value = value:gsub ("$_" .. varKey, varValue)
      end

      i18n[key] = value
    end
  end

  -- Collect the file path of any image file found in the wallpapers dir
  local re = ".*.\\(jpe?g\\|png\\)$"
  local find = 'find ' .. wallpapers_dir .. ' -type f -regex "' .. re .. '" 2> /dev/null || echo ""'
  local output = find:exec ()
  local paths = output:split ('\n')

  -- Filter out empty paths
  for _, path in ipairs (paths) do
    if path ~= "" then
      table.insert (wallpapers, path)
      log ("Found image '" .. path .. "'")
    end
  end

  log ("Found " .. table.getn (wallpapers) .. " images under " .. wallpapers_dir)
end

-- Resolves the current network interface and ip
function resolveConnection ()
  local route = "ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}'"
  local output = route:exec ()
  local parts = output:split (',')

  -- Update the network dynamic interpolation variables
  vars["net_name"] = parts[1]
  vars["net_ip"] = parts[2]

  if vars["net_name"] ~= nil and vars["net_name"] ~= "" then
    log ("Network resolved to '" .. vars["net_name"])
  else
    log ("Unable to resolve network")
  end
end

-- Updates the background and screensaver wallpaper
function updateWallpaper ()
  local len = table.getn (wallpapers)

  if len > 0 then
    local index = math.random (1, len)
    local pic = wallpapers[index]

    -- Set the background and screensaver pictures
    local background = 'gsettings set org.gnome.desktop.background picture-uri "file://' .. pic .. '"'
    background:exec ()

    local screensaver = 'gsettings set org.gnome.desktop.screensaver picture-uri "file://' .. pic .. '"'
    screensaver:exec ()

    log ("Wallpaper has been updated to '" .. pic .. "'")
  end
end

function conky_main ()
  -- Abort if the conky window is not rendered
  if conky_window == nil then
    return
  end

  -- Read the number of conky updates so far
  local updates = tonumber (conky_parse ("${updates}"))

  interval (10, updates, resolveConnection)

  if wallpaperInterval > 0 then
    interval (wallpaperInterval, updates, updateWallpaper)
  end

  -- Mark conky as running in subsequent cycles
  if status == "init" then
    status = "running"
  end
end

-- Returns a left aligned conky text line
function text (line, font, interpolate)
  -- Resolve instantly date and time literals
  local time_p = tonumber (os.date("%H")) < 12 and "am" or "pm"
  vars["time_p"] = i18n["date.time." .. time_p]
  vars["time_P"] = i18n["date.time." .. time_p:upper ()]
  vars["day_name"] = i18n["date.day." .. os.date("%w")]
  vars["month_name"] = i18n["date.month." .. os.date("%m")]

  -- Interpolate any given dynamic variables
  if interpolate then
    for varKey, varValue in pairs(vars) do
      line = line:gsub ("$_" .. varKey, varValue)
    end
  end

  if font ~= nil then
    return "${font " .. font .. "}" .. "$alignr " .. line .. "$font"
  end

  return "$alignr " .. line
end

-- Resolves the theme color to conky
function conky_theme ()
  if theme == "dark" then
    return "${color black}"
  end

  return "${color white}"
end

-- Exposes the clock time to conky
function conky_clock ()
  return text (i18n["text.line.clock"], fonts["clock"], true)
end

-- Exposes the date to conky
function conky_date ()
  return text (i18n["text.line.date"], fonts["date"], true)
end

-- Exposes the user line to conky
function conky_user ()
  return text (i18n["text.line.user"], fonts["text"], true)
end

-- Exposes the running system info to the conky
function conky_system ()
  return text (i18n["text.line.system"], fonts["text"], true)
end

-- Exposes the loads and sensors data to the conky
function conky_loads ()
  return text (i18n["text.line.loads"], fonts["text"], true)
end

-- Exposes the network speeds to the conky
function conky_network ()
  return text (i18n["text.line.network"], fonts["text"], true)
end

-- Exposes the connection status to the conky
function conky_connection ()
  local line = i18n["text.line.connection.online"]

  if vars["net_ip"] == nil or vars["net_ip"] == "" then
    line = i18n["text.line.connection.offline"]
  end

  return text (line, fonts["text"], true)
end

-- Exposes the uptime to the conky
function conky_uptime ()
  return text (i18n["text.line.uptime"], fonts["text"], true)
end

init ()