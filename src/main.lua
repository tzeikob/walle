-- Main lua file for the conky config file

-- Global variables
config_file = "~/.config/PKG_NAME/.wallerc"
pictures_dir = "~/pictures/wallpapers/"
conky_on_start = true

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
  local cmd = "jq --raw-output " .. path .. " " .. config_file .. " | awk -- '{printf \"%s\", $1}'"
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
pictures = {}
interface = ""
ip = ""

-- Loads the list of pictures stored under the ~/pictures/wallpapers folder
function loadPictures ()
  local re = ".*.\\(jpe?g\\|png\\)$"
  local file = io.popen ('find ' .. pictures_dir .. ' -type f -regex "' .. re .. '" 2> /dev/null || echo ""')
  local output = file:read ("*a")
  file:close ()

  -- Split raw output
  local items = string.split (output, '\n')

  -- Filter only non-empty items
  local index = 1
  for i=1,table.getn(items) do
    local item = items[i]

    if item ~= "" then
      pictures[index] = item
      index = index + 1
    end
  end

  print ("Found " .. table.getn(pictures) .. " pictures under " .. pictures_dir)
end

-- Resolves the current network interface and IP
function resolveConnection ()
  local file = io.popen ("ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}'")
  local output = file:read ("*a")
  file:close ()
  
  output = string.split (output, ',')

  interface = output[1]
  ip = output[2]

  print ("Network resolved to '" .. interface .. "' and ip '" .. ip .. "'")
end

-- Updates the background and screensaver wallpapers
function updateWallpapers ()
  local len = table.getn(pictures)

  if len > 0 then
    local index = math.random(1, len)
    local pic = pictures[index]

    -- Set the background picture
    local file = io.popen ('gsettings set org.gnome.desktop.background picture-uri "file://' .. pic .. '"')
    file:close ()

    -- Set the screensaver picture
    file = io.popen ('gsettings set org.gnome.desktop.screensaver picture-uri "file://' .. pic .. '"')
    file:close ()

    print ('Wallpapers have been set to ' .. pic)
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
    executeEvery (3600, updates, updateWallpapers)
  end

  -- Mark conky as started in the subsequent cycles
  if conky_on_start then
    loadPictures ()
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