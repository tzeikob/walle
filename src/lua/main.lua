-- Main lua file of the conky config file

-- Global constants
PKG_NAME = "#PKG_NAME"
USER_HOME = "/home/#USER"
WALLPAPERS_DIR = USER_HOME .. "/pictures/wallpapers"
BASE_DIR = USER_HOME .. "/.config/" .. PKG_NAME
CONFIG_DIR = BASE_DIR .. "/config.yml"

DAYS = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
MONTHS = {
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"
}

-- Global variables
status = "init"
wallpapers = {}
vars = {}

-- Add base directory to lua package path
package.path = package.path .. ";" .. BASE_DIR .. "/?.lua"

-- Load third-party dependencies
lfs = require "lfs"
yaml = require "yaml"
ui = require "ui"
util = require "util"

-- Load the config file
file = io.open (CONFIG_DIR, "r")
cfg = yaml.load (file:read ("*a"))
file:close ()

-- Logs a message if logging level is on debug mode
function log (message)
  if cfg["system"]["debug"] == "enabled" then
    print (message)
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

-- Resolves the interpolation vars within the given scopes
function resolve (...)
  for _, scope in ipairs ({...}) do
    -- Set the current date and time text variables
    if scope == "datetime" or scope == "all" then
      local date = util.split (os.date ("%H %w %m"), " ")

      local time_p = "pm"
      if tonumber (date[1]) < 12 then
        time_p = "am"
      end

      vars["time_p"] = time_p
      vars["time_p_up"] = time_p:upper ()

      vars["day_name"] = DAYS[tonumber (date[2])]
      vars["month_name"] = MONTHS[tonumber (date[3])]

      log ("Date and time variables have been resolved")
    end

    -- Set the system's release and user variables
    if scope == "release" or scope == "all" then
      local lsb_release = "lsb_release --short -icr"
      local parts = util.split (util.exec (lsb_release), "\n")

      vars["rls_name"] = parts[1]
      vars["rls_version"] = parts[2]
      vars["rls_codename"] = parts[3]

      local uname = "uname -p | sed -z '$ s/\\n$//'"
      vars["rls_arch"] = util.exec (uname)

      log ("Release and system variables have been resolved")
    end

    -- Set the currnet network variables
    if scope == "network" or scope == "all" then
      local route = "ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}'"
      local parts = util.split (util.exec (route), ",")

      if parts[1] ~= nil and parts[1] ~= "" then
        vars["net_name"] = parts[1]
        vars["net_ip"] = parts[2]

        log ("Network variables resolved to '" .. vars["net_name"] .. "'")
      else
        vars["net_name"] = ""
        vars["net_ip"] = ""

        log ("Unable to resolve network variables")
      end
    end

    -- Set the next random wallpaper
    if scope == "wallpaper" or scope == "all" then
      local len = table.getn (wallpapers)

      if len > 0 then
        local index = math.random (1, len)
        vars["wallpaper"] = wallpapers[index]

        log ("Next wallpaper resolve to '" .. vars["wallpaper"] .. "'")
      end
    end
  end
end

-- Resolves the given scope only at the given number of cycles
function resolveAt (cycles, scope)
  local updates = tonumber (conky_parse ("${updates}"))
  local timer = (updates % cycles)

  if timer == 0 or status == "init" then
    resolve (scope)

    return true
  else
    return false
  end
end

-- Main lua function called by conky
function conky_main ()
  if conky_window == nil then
    return
  end

  resolve ("datetime")
  resolveAt (10, "network")

  local secs = tonumber (cfg["theme"]["wallpaper"])
  if secs > 0 then
    if resolveAt (secs, "wallpaper") then
      ui.updateWallpaper (vars["wallpaper"])
      ui.updateLockScreen (vars["wallpaper"])
    end
  end

  -- Mark conky as running in subsequent cycles
  if status == "init" then
    status = "running"
  end
end

-- Returns the text to be rendered by the conky
function conky_text ()
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

  text = util.trim (text)

  return text
end

-- Collect all the paths of images in the wallpapers dir
for file in lfs.dir (WALLPAPERS_DIR) do
  if util.matches(file, "jpeg$", "jpg$", "png$") then
    path = WALLPAPERS_DIR .. "/" .. file
    table.insert (wallpapers, path)

    log ("Found image '" .. path .. "'")
  end
end

-- Resolve immediately any interoplation variables
resolve ("all")