-- Main lua file of the conky config file

-- Resolved base path at build time
BASE_DIR = "/home/#USER/.config/#PKG_NAME"

-- Add base directory to lua package path
package.path = package.path .. ";" .. BASE_DIR .. "/?.lua"

ui = require "ui"
util = require "util"

-- Load configuration into a dict object
config = util.yaml (BASE_DIR .. "/config.yml")

-- Load the file paths of any wallpapers
path = config["theme"]["wallpapers"]["path"]

if path == nil or path == "" then
  path = BASE_DIR .. "/wallpapers"
end

wallpapers = util.list (path, "jpeg$", "jpg$", "png$")

-- Initialize global variables
status = "init"
vars = {}

-- Logs a message if logging level is on debug mode
function log (message)
  if config["system"]["debug"] == "enabled" then
    print (message)
  end
end

-- Resolves the interpolation vars within the given scopes
function resolve (...)
  for _, scope in ipairs ({...}) do
    -- Set the theme variables
    if scope == "theme" or scope == "all" then
      vars["mode"] = "white"

      if config["theme"]["mode"] == "dark" then
        vars["mode"] = "black"
      end

      vars["head"] = config["theme"]["fonts"]["head"]
      vars["subhead"] = config["theme"]["fonts"]["subhead"]
      vars["body"] = config["theme"]["fonts"]["body"]
    end

    -- Set the current date and time text variables
    if scope == "datetime" or scope == "all" then
      local date = util.split (os.date ("%H %w %m"), " ")

      local time_p = "pm"
      if tonumber (date[1]) < 12 then
        time_p = "am"
      end

      vars["time_p"] = time_p
      vars["time_p_up"] = time_p:upper ()

      vars["day_name"] = util.day (tonumber (date[2]))
      vars["month_name"] = util.month (tonumber (date[3]))

      log ("Date and time variables have been resolved")
    end

    -- Set the system's release and user variables
    if scope == "release" or scope == "all" then
      local lsb_release = "lsb_release --short -icr"
      lsb_release = util.split (util.exec (lsb_release), "\n")

      vars["rls_name"] = util.cap (lsb_release[1])
      vars["rls_version"] = lsb_release[2]
      vars["rls_codename"] = util.cap (lsb_release[3])

      local uname = "uname -p | sed -z '$ s/\\n$//'"
      vars["rls_arch"] = util.exec (uname)

      log ("Release and system variables have been resolved")
    end

    -- Set the currnet network variables
    if scope == "network" or scope == "all" then
      local route = "ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}'"
      route = util.split (util.exec (route), ",")

      if route[1] ~= nil and route[1] ~= "" then
        vars["net_name"] = route[1]
        vars["net_ip"] = route[2]

        log ("Network variables resolved to '" .. vars["net_name"] .. "'")
      else
        vars["net_name"] = ""
        vars["net_ip"] = ""

        log ("Unable to resolve network variables")
      end

      local dig = "dig +short myip.opendns.com @resolver1.opendns.com"
      local public_ip = util.trim (util.exec (dig))

      if public_ip ~= nil and public_ip ~= "" then
        vars["public_ip"] = public_ip
      end
    end

    -- Set the next random wallpaper
    if scope == "wallpaper" or scope == "all" then
      local len = table.getn (wallpapers)

      if len > 0 then
        local index = math.random (1, len)
        vars["wallpaper"] = wallpapers[index]

        log ("Next wallpaper resolved to '" .. vars["wallpaper"] .. "'")
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

  resolveAt (10, "datetime")
  resolveAt (10, "network")

  local secs = tonumber (config["theme"]["wallpapers"]['interval'])
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

-- Returns the value of the var mapped by the given key
function conky_var (key)
  local value = vars[key]

  if value == nil then
    return key
  end

  return value
end

-- Returns the evaluated conkyrc object along with any vars
function conky_eval (object, ...)
  local text = "${" .. object

  for _, key in ipairs ({...}) do
    local value = vars[key]

    if value == nil then
      value = key
    end

    text = text .. " " .. value
  end

  text = text .. "}"

  return conky_parse(text)
end

-- Resolve immediately all interoplation variables
resolve ("all")