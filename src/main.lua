-- Main lua file of the conky config file

-- Initialize global variables
user_home_dir = "/home/USER"
working_dir = user_home_dir .. "/.config/PKG_NAME"
langs_dir = working_dir .. "/langs"
wallpapers_dir = user_home_dir .. "/pictures/wallpapers"
config_file = working_dir .. "/.wallerc"

status = "init"
debug_mode = "disabled"
lang = "en"
theme = "light"
i18n = {}
wallpaper = "static"
wallpapers = {}
release = { name = "", version = "", codename = "" }
network = { interface = "", ip = "", proxy = "" }
fonts = { clock = "", date = "", text = "" }

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
  -- Initialize configuration properties
  debug_mode = config (".debug", "disabled")
  lang = config ('.lang', "en")
  theme = config (".theme", "light")
  wallpaper = config (".wallpaper", "static")
  fonts["clock"] = config (".clock", "")
  fonts["date"] = config (".date", "")
  fonts["text"] = config (".text", "")

  -- Initialize some os release information
  local lsb_release = "lsb_release --short -icr"
  local output = lsb_release:exec ()
  local keys = output:split("\n")

  release["name"] = keys[1]
  release["version"] = keys[2]
  release["codename"] = keys[3]

  -- Load the i18n texts correspond to the choosen lang
  local lines = io.lines (langs_dir .. "/" .. lang .. ".dict")

  for line in lines do
    if line:matches ("^[a-zA-Z0-9-_][a-zA-Z0-9-_\.]* *=.*") then
      local items = line:split ("=", true)
      local key, value = items[1]:trim (), items[2]:trim ()
      i18n[key] = value
    end
  end

  -- Load the file path of any wallpaper
  local re = ".*.\\(jpe?g\\|png\\)$"
  local find = 'find ' .. wallpapers_dir .. ' -type f -regex "' .. re .. '" 2> /dev/null || echo ""'
  local output = find:exec ()

  -- Split raw output
  local paths = output:split ('\n')

  -- Filter out empty paths
  local index = 1
  for i=1,table.getn (paths) do
    local path = paths[i]

    if path ~= "" then
      log ("Found image '" .. path .. "'")

      wallpapers[index] = path
      index = index + 1
    end
  end

  log ("Found " .. table.getn (wallpapers) .. " images under " .. wallpapers_dir)
end

-- Resolves the current network interface and ip
function resolveConnection ()
  local route = "ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}'"
  local output = route:exec ()
  output = output:split (',')

  network["interface"] = output[1]
  network["ip"] = output[2]

  if network["interface"] ~= nil and network["interface"] ~= "" then
    log ("Network resolved to '" .. network["interface"] .. "' and ip '" .. network["ip"] .. "'")
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

  if wallpaper == "slide" then
    interval (60, updates, updateWallpaper)
  end

  -- Mark conky as running in subsequent cycles
  if status == "init" then
    status = "running"
  end
end

-- Expose information to the conky config file
function conky_theme ()
  if theme == "light" then
    return "${color white}"
  elseif theme == "dark" then
    return "${color black}"
  else
    return "${color white}"
  end
end

function conky_upspeed ()
  return "${upspeedf " .. network["interface"] .. "}KiB"
end

function conky_downspeed ()
  return "${downspeedf " .. network["interface"] .. "}KiB"
end

function conky_connection ()
  local interface = network["interface"]

  if interface ~= nil and interface ~= "" then
    return "Connected " .. network["ip"]
  else
    return "Offline"
  end
end

function conky_font (section)
  if section == "clock" then
    return "${font " .. fonts["clock"] .. "}"
  elseif section == "date" then
    return "${font " .. fonts["date"] .. "}"
  elseif section == "text" then
    return "${font " .. fonts["text"] .. "}"
  else
    return ""
  end
end

init ()