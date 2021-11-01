-- Main lua file of the conky config file

-- Load third-party dependencies
lfs = require "lfs"
yaml = require "yaml"

-- Global file and dir paths
pkg_name = "#PKG_NAME"
user_home = "/home/#USER"
wallpapers_dir = user_home .. "/pictures/wallpapers"
base_dir = user_home .. "/.config/" .. pkg_name
config_file = base_dir .. "/config.yml"

-- Load the config file
file = io.open (config_file, "r")
cfg = yaml.load (file:read ("*a"))
file:close ()

-- Global variables
status = "init"
wallpapers = {}
vars = {}

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
  if cfg["system"]["debug"] == "enabled" then
    print (message)
  end
end

-- Executes an operation after the given cycles have passed
function interval (cycles, updates, operation)
  local timer = (updates % cycles)

  if timer == 0 or status == "init" then
    operation ()
  end
end

-- Interpolates all matches with vars into the given line
function string:interpolate ()
  for key, value in pairs (vars) do
    if value == nil or value == "" then
      value = "..."
    end

    self = self:gsub ("$_" .. key, value)
  end

  return self
end

-- Resolves all extra interpolation variables
function resolve ()
  -- Resolve the date and time vars
  local date = os.date ("%H %M %A %d %B %Y")
  local parts = date:split (" ")
  local time_p = tonumber (parts[1]) < 12 and "am" or "pm"
  vars["time_p"] = time_p
  vars["time_p_up"] = time_p:upper ()
  vars["hour"] = parts[1]
  vars["minute"] = parts[2]
  vars["day_name"] = parts[3]
  vars["day"] = parts[4]
  vars["month_name"] = parts[5]
  vars["year"] = parts[6]

  -- Resolve release and system vars
  local lsb_release = "lsb_release --short -icr"
  local output = lsb_release:exec ()
  local parts = output:split ("\n")
  vars["rls_name"] = parts[1]
  vars["rls_version"] = parts[2]
  vars["rls_codename"] = parts[3]

  local uname = "uname -p | sed -z '$ s/\\n$//'"
  vars["rls_arch"] = uname:exec ()
end

-- Resolves the current network interface and ip
function resolveConnection ()
  local route = "ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}'"
  local output = route:exec ()
  local parts = output:split (',')

  -- Update the network dynamic interpolation variables
  if parts[1] ~= nil and parts[1] ~= "" then
    vars["net_name"] = parts[1]
    vars["net_ip"] = parts[2]

    log ("Network resolved to '" .. vars["net_name"] .. "'")
  else
    vars["net_name"] = ""
    vars["net_ip"] = ""

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

    log ("Wallpaper has been changed to '" .. pic .. "'")
  end
end

-- Main lua function called by conky
function conky_main ()
  -- Abort if the conky window is not rendered
  if conky_window == nil then
    return
  end

  -- Read the number of conky updates so far
  local updates = tonumber (conky_parse ("${updates}"))

  interval (10, updates, resolveConnection)

  local secs = tonumber (cfg["theme"]["wallpaper"])
  if secs > 0 then
    interval (secs, updates, updateWallpaper)
  end

  -- Mark conky as running in subsequent cycles
  if status == "init" then
    status = "running"
  end
end

-- Returns the text to be rendered by the conky
function conky_text ()
  -- Resolve interpolation variables
  resolve ()
  resolveConnection ()

  local text = ""

  -- Build mode line
  local modeLine = "${color white}"
  if cfg["theme"]["mode"] == "dark" then
    modeLine = "${color black}"
  end

  text = text .. modeLine .. "\n"

  -- Build head line
  local headFont = cfg['theme']['fonts']['head']
  local head = cfg['text']['head']:interpolate ()
  local headLine = "${font " .. headFont .. "}" .. "$alignr " .. head .. "${font}"

  text = text .. headLine .. "\n"

  -- Build sub-head line
  local subheadFont = cfg['theme']['fonts']['subhead']
  local subhead = cfg['text']['subhead']:interpolate ()
  local subheadLine = "${font " .. subheadFont .. "}" .. "$alignr " .. subhead .. "${font}"
  
    text = text .. subheadLine .. "\n"

  -- Build body lines
  local bodyFont = cfg['theme']['fonts']['body']
  for _, bodyLine in ipairs (cfg["text"]["body"]) do
    bodyLine = bodyLine:interpolate ()
    bodyLine = "${font " .. bodyFont .. "}" .. "$alignr " .. bodyLine .. "${font}"

    text = text .. bodyLine .. "\n"
  end

  text:trim ()

  return text
end

-- Collect all the images in the wallpapers directory
for file in lfs.dir (wallpapers_dir) do
  if file:matches("jpeg$") or file:matches("jpg$") or file:matches("png$") then
    path = wallpapers_dir .. "/" .. file
    table.insert (wallpapers, path)

    log ("Found image '" .. path .. "'")
  end
end