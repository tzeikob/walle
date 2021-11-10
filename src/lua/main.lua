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
path = config["system"]["wallpapers"]["path"]

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

      vars["font_name"] = "DejaVu Sans Mono"
      vars["font_bold"] = false
      vars["font_italic"] = false
      vars["font_size"] = 12

      local font = config["theme"]["font"]
      local parts = util.split (font, ":")

      for _, part in ipairs (parts) do
        if util.matches (part, "bold") then
          vars["font_bold"] = true
        elseif util.matches (part, "italic") then
          vars["font_italic"] = true
        elseif util.matches (part, "size=.+") then
          local size = util.split (part, "=")[2]
          vars["font_size"] = tonumber (size)
        elseif part ~= "" then
          vars["font_name"] = part
        end
      end
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

      vars["name"] = config["system"]["name"]
      vars["user"] = util.trim (util.exec ("echo $(whoami)"))
      vars["host"] = util.trim (util.exec ("echo $(hostname)"))

      log ("Release and system variables have been resolved")
    end

    -- Set the currnet network variables
    if scope == "network" or scope == "all" then
      local route = "ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}'"
      route = util.split (util.exec (route), ",")

      if route[1] ~= nil and route[1] ~= "" then
        vars["net_name"] = route[1]
        vars["lan_ip"] = route[2]

        local dig = "dig +short myip.opendns.com @resolver1.opendns.com"
        local net_ip = util.trim (util.exec (dig))

        if net_ip ~= nil and net_ip ~= "" then
          vars["net_ip"] = net_ip

          log ("Public IP address resolved to '" .. vars["net_ip"] .. "'")
        else
          vars["net_ip"] = "x.x.x.x"

          log ("Unable to resolve the public IP address")
        end

        local net_proc = "cat /proc/net/dev | awk '/" .. vars["net_name"] .. "/ {printf \"%s %s\",  $2, $10}'"
        local bytes = util.split (util.trim (util.exec (net_proc)), " ")

        vars["down_bytes"] = util.round (tonumber (bytes[1]) / (1024 * 1024 * 1024), 1)
        vars["up_bytes"] = util.round (tonumber (bytes[2]) / (1024 * 1024 * 1024), 1)

        log ("Network variables resolved to '" .. vars["net_name"] .. "'")
      else
        vars["net_name"] = ""
        vars["lan_ip"] = "x.x.x.x"
        vars["net_ip"] = "x.x.x.x"
        vars["down_bytes"] = 0
        vars["up_bytes"] = 0

        log ("Unable to resolve network variables")
      end
    end

    -- Set the current system load values
    if scope == "load" or scope == "all" then
      -- Todo: read load data
      vars["cpu_load"] = "cpu_load"
      vars["mem_load"] = "mem_load"
      vars["disk_load"] = "disk_load"
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

  resolveAt (10, "load")
  resolveAt (10, "network")

  local secs = tonumber (config["system"]["wallpapers"]['interval'])
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

-- Parses the given text subjects into conky at the given scale
function text (scale, ...)
  local ctx = "${alignr}"

  ctx = ctx .. "${font " .. vars["font_name"]

  if vars["font_bold"] then
    ctx = ctx .. ":bold"
  end

  if vars["font_italic"] then
    ctx = ctx .. ":italic"
  end

  local size = vars["font_size"]

  if scale > 1 then
    size = size * scale
  end

  ctx = ctx .. ":size=" .. size .. "}"

  -- Interpolate each var in every given subject
  for _, subject in ipairs ({...}) do
    local prefix, key, postfix = subject:match ("'(.*)${([a-z_]+)}(.*)'")

    local value = vars[key]
    if value == nil then
      value = key
    end

    ctx = ctx .. " " .. prefix .. value .. postfix
  end

  ctx = ctx .. "${font}"

  return conky_parse (ctx)
end

-- Returns the conky parsed text of a head line
function conky_head (...)
  return text (1.45, ...)
end

-- Returns the conky parsed text of a line
function conky_line (...)
  return text (1, ...)
end

-- Resolve immediately all interoplation variables
resolve ("all")