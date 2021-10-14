-- Main lua file for the conky config file

-- Global variables
config_file = "~/.config/PKG_NAME/.wallerc"
wallpapers_dir = "~/pictures/wallpapers/"
conky_on_start = true

-- Logs a debug message if debug is enabled
function log_debug (message)
  if debug == "enabled" then
    print (message)
  end
end

-- Splits the given string by the given delimiter
function string:split (delimiter)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find (self, delimiter, from)

  while delim_from do
    table.insert (result, string.sub (self, from , delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = string.find (self, delimiter, from)
  end

  table.insert ( result, string.sub (self, from))

  return result
end

-- Reads the configuration property with the given json path
function config (path, default)
  local cmd = "jq --raw-output " .. path .. " " .. config_file .. " | sed -z '$ s/\\n$//'"
  local file = io.popen (cmd)
  local value = file:read ("*a")
  file:close ()

  -- Return default if not found
  if value ~= "null" then
    return value
  else
    return default
  end
end

-- Executes an operation after the given cycles have passed
function executeEvery (cycles, updates, operation)
  local timer = (updates % cycles)

  if timer == 0 or conky_on_start then
    operation ()
  end
end

-- Initialize configuration properties
theme = config (".theme", "light")
wallpaper = config (".wallpaper", "static")
clock_font = config(".clock", "")
date_font = config(".date", "")
text_font = config(".text", "")
debug = config (".debug", "disabled")
wallpapers = {}
interface = ""
ip = ""

-- Loads the list of images under the ~/pictures/wallpapers folder
function loadWallpapers ()
  local re = ".*.\\(jpe?g\\|png\\)$"
  local file = io.popen ('find ' .. wallpapers_dir .. ' -type f -regex "' .. re .. '" 2> /dev/null || echo ""')
  local output = file:read ("*a")
  file:close ()

  -- Split raw output
  local items = string.split (output, '\n')

  -- Filter only non-empty items
  local index = 1
  for i=1,table.getn(items) do
    local item = items[i]

    if item ~= "" then
      log_debug ("Found image '" .. item .. "'")

      wallpapers[index] = item
      index = index + 1
    end
  end

  log_debug ("Found " .. table.getn(wallpapers) .. " images under " .. wallpapers_dir)
end

-- Resolves the current network interface and IP
function resolveConnection ()
  local file = io.popen ("ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}'")
  local output = file:read ("*a")
  file:close ()
  
  output = string.split (output, ',')

  interface = output[1]
  ip = output[2]

  if interface ~= nil and interface ~= "" then
    log_debug ("Network resolved to '" .. interface .. "' and ip '" .. ip .. "'")
  else
    log_debug ("Unable to resolve network seems your are offline")
  end
end

-- Updates the background and screensaver wallpaper
function updateWallpaper ()
  local len = table.getn(wallpapers)

  if len > 0 then
    local index = math.random(1, len)
    local pic = wallpapers[index]

    -- Set the background picture
    local file = io.popen ('gsettings set org.gnome.desktop.background picture-uri "file://' .. pic .. '"')
    file:close ()

    -- Set the screensaver picture
    file = io.popen ('gsettings set org.gnome.desktop.screensaver picture-uri "file://' .. pic .. '"')
    file:close ()

    log_debug ('Wallpaper has been set to ' .. pic)
  end
end

function conky_main ()
  -- Abort if the conky window is not rendered
  if conky_window == nil then
    return
  end

  -- Read the number of conky updates so far
  local updates = tonumber (conky_parse ("${updates}"))

  executeEvery (10, updates, resolveConnection)

  if wallpaper == "slide" then
    executeEvery (3600, updates, updateWallpaper)
  end

  -- Mark conky as started in the subsequent cycles
  if conky_on_start then
    loadWallpapers ()
    conky_on_start = false
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
  return "${upspeedf " .. interface .. "}KiB"
end

function conky_downspeed ()
  return "${downspeedf " .. interface .. "}KiB"
end

function conky_connection ()
  if interface ~= nil and interface ~= "" then
    return "Connected " .. ip
  else
    return "Offline"
  end
end

function conky_font (section)
  if section == "clock" then
    return "${font " .. clock_font .. "}"
  elseif section == "date" then
    return "${font " .. date_font .. "}"
  elseif section == "text" then
    return "${font " .. text_font .. "}"
  else
    return ""
  end
end