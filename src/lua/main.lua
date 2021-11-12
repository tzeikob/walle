-- Main lua file of the conky config file

-- Resolved base path at build time
BASE_DIR = "/home/#USER/.config/#PKG_NAME"

-- Add base directory to lua package path
package.path = package.path .. ";" .. BASE_DIR .. "/?.lua"

ui = require "ui"
util = require "util"
core = require "core"

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
      vars["head"] = config["head"]

      -- Set head line a random name if no head is given
      if vars["head"] == nil or vars["head"] == "" then
        vars["head"] = core.petname ()
      end

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

    -- Set the system's variables
    if scope == "system" or scope == "all" then
      local release = core.release ()

      vars["rls_name"] = util.cap (release["name"])
      vars["rls_version"] = release["version"]
      vars["rls_codename"] = util.cap (release["codename"])
      vars["rls_arch"] = release["arch"]

      vars["user"] = core.user ()
      vars["hostname"] = core.hostname ()

      vars["name"] = config["system"]["name"]

      local hw = core.hw ()

      vars["cpu_name"] = hw["cpu_name"]
      vars["cpu_cores"] = hw["cpu_cores"]
      vars["cpu_freq"] = hw["cpu_freq"]
      vars["mobo_name"] = hw["mobo_name"]
      vars["gpu_name"] = hw["gpu_name"]

      log ("System variables have been resolved")
    end

    -- Set the currnet network variables
    if scope == "network" or scope == "all" then
      local network = core.network ()

      vars["net_name"] = network["net_name"]
      vars["lan_ip"] = network["lan_ip"]
      vars["net_ip"] = network["net_ip"]
      vars["down_bytes"] = network["down_bytes"]
      vars["up_bytes"] = network["up_bytes"]

      log ("Network variables resolved to '" .. vars["net_name"] .. "'")
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