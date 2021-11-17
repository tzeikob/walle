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

if util.is_empty (path) then
  path = BASE_DIR .. "/wallpapers"
end

wallpapers = util.list (path, "jpeg$", "jpg$", "png$")

-- Initialize global variables
status = "init"
loop = 0
vars = {}

-- Logs a message if logging level is on debug mode
function log (message)
  if config["system"]["debug"] == "enabled" then
    print (message)
  end
end

-- Resolves the interpolation vars within the given scopes
function resolve (cycles, ...)
  if cycles > 0 then
    local timer = (loop % cycles)

    -- Break if not in given cycles or not at start up
    if timer ~= 0 and status ~= "init" then
      return false
    end
  end

  for _, scope in ipairs ({...}) do
    -- Set the theme variables
    if scope == "theme" or scope == "all" then
      vars["head"] = util.default_to (config["head"], core.petname ())

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

      -- Update the net ip and isp if connected to a new network
      if network["net_name"] ~= vars["net_name"] then
        vars["net_ip"] = ""
        vars["isp_org"] = ""
      end

      vars["net_name"] = network["net_name"]
      vars["lan_ip"] = network["lan_ip"]

      -- Calculate network upload and download speeds
      vars["down_speed"] = 0
      vars["up_speed"] = 0

      if util.is_not_empty (vars["net_name"]) and cycles > 0 then
        local bytes_prev = vars["down_bytes"] > 0 and vars["down_bytes"] or network["down_bytes"]
        local bytes_now = network["down_bytes"]

        local down_speed = util.to_mbits (bytes_now - bytes_prev) / cycles
        vars["down_speed"] = util.round (down_speed, 2)

        bytes_prev = vars["up_bytes"] > 0 and vars["up_bytes"] or network["up_bytes"]
        bytes_now = network["up_bytes"]

        local up_speed = util.to_mbits (bytes_now - bytes_prev) / cycles
        vars["up_speed"] = util.round (up_speed, 2)
      end

      vars["down_bytes"] = network["down_bytes"]
      vars["down_mbytes"] = util.round (util.to_mbytes (vars["down_bytes"]))

      vars["up_bytes"] = network["up_bytes"]
      vars["up_mbytes"] = util.round (util.to_mbytes (vars["up_bytes"]))

      log ("Network variables resolved to '" .. vars["net_name"] .. "'")
    end

    -- Set the current ISP variables
    if scope == "isp" or scope == "all" then
      local isp = core.isp ()

      vars["net_ip"] = isp["ip"]
      vars["isp_org"] = isp["org"]
    end

    -- Set the uptime variable
    if scope == "uptime" or scope == "all" then
      local uptime = core.uptime ()

      local hours = string.format ("%02d", uptime["hours"])
      local mins = string.format ("%02d", uptime["mins"])
      local secs = string.format ("%02d", uptime["secs"])

      vars["uptime"] = hours .. ":" .. mins .. ":" .. secs
    end

    -- Set the current system load values
    if scope == "loads" or scope == "all" then
      vars["cpu_load"] = conky_parse ("$cpu")
      vars["mem_load"] = conky_parse ("$memperc")
      vars["disk_load"] = conky_parse ("${fs_used_perc /}")

      local gpu = core.gpu ()

      vars["gpu_name"] = gpu["name"]
      vars["gpu_util"] = gpu["util"]
      vars["gpu_mem"] = gpu["mem"]
      vars["gpu_mem_util"] = gpu["mem_util"]
      vars["gpu_temp"] = gpu["temp"]
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

  return true
end

-- Main lua function called by conky
function conky_main ()
  if conky_window == nil then
    return
  end

  -- Update the current conky loop index
  loop = tonumber (conky_parse ("${updates}"))

  -- Try to resolve various interpolation variables
  resolve (1, "uptime")
  resolve (4, "loads")
  resolve (9, "network")
  resolve (61, "isp")

  local secs = tonumber (config["system"]["wallpapers"]['interval'])
  if secs > 0 then
    if resolve (secs, "wallpaper") then
      ui.updateWallpaper (vars["wallpaper"])
      ui.updateLockScreen (vars["wallpaper"])
    end
  end

  -- Mark conky as running in subsequent cycles
  if status == "init" then
    status = "running"
  end
end

-- Returns the given text after interpolating any given vars
function ie (text)
  local matches = string.gmatch (text, '${([a-zA-Z_]+)}')
  
  for key in matches do
    if vars[key] ~= nil then
      text = string.gsub (text, '${' .. key .. '}', vars[key])
    end
  end

  return text
end

-- Converts the given text as a conkyrc text line
function ln (scale, text)
  local line = "${alignr}"

  line = line .. "${font " .. vars["font_name"]

  if vars["font_bold"] then
    line = line .. ":bold"
  end

  if vars["font_italic"] then
    line = line .. ":italic"
  end

  local size = vars["font_size"]

  if scale > 1 then
    size = size * scale
  end

  line = line .. ":size=" .. size .. "}" .. text .. "${font}" .. "\n"

  return line
end

-- Builds and returns the conky text
function conky_text ()
  local text = ""

  text = text .. ln (1.4, ie ("${head}"))
  text = text .. ln (1.0, ie ("USER ${user} HOST ${hostname}"))
  text = text .. ln (1.0, ie ("DISTRO ${rls_name} ${rls_codename}"))
  text = text .. ln (1.0, ie ("CPU ${cpu_load}% MEM ${mem_load}% DISK ${disk_load}%"))
  text = text .. ln (1.0, ie ("GPU ${gpu_util}% MEM ${gpu_mem}MB TEMP ${gpu_temp}°C"))
  text = text .. ln (1.0, ie ("NETWORK ${net_name}"))
  text = text .. ln (1.0, ie ("LAN ${lan_ip}"))
  text = text .. ln (1.0, ie ("ISP ${isp_org}"))
  text = text .. ln (1.0, ie ("NET ${net_ip}"))
  text = text .. ln (1.0, ie ("SENT ${up_mbytes}MB RECEIVED ${down_mbytes}MB"))
  text = text .. ln (1.0, ie ("UP ${up_speed}Mbps DOWN ${down_speed}Mbps"))
  text = text .. ln (1.0, ie ("UPTIME T+${uptime}"))

  return conky_parse (text)
end

-- Resolve immediately all interoplation variables
resolve (0, "all")