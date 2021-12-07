-- Main lua entry point for the conkyrc file

-- Resolved base and config paths at build time
PKG_NAME = "#PKG_NAME"
BASE_DIR = "/usr/share/" .. PKG_NAME .. "/lua"
CONFIG_DIR = "/home/#USER/.config/" .. PKG_NAME

-- Add base directory to lua package path
package.path = package.path .. ";" .. BASE_DIR .. "/?.lua"

util = require "util"
logger = require "logger"
text = require "text"
convert = require "convert"

-- Load configuration into a dict object
config = util.yaml (CONFIG_DIR .. "/config.yml")

-- Initialize logger
logger.set_debug_mode (config["debug"])

-- Initialize global variables
status = "init"
loop = 0
vars = {}

-- Initialize theme settings
vars["head"] = config["head"]

vars["mode"] = "white"
if config["theme"]["mode"] == "dark" then
  vars["mode"] = "black"
end

vars["font_name"] = "DejaVu Sans Mono"
vars["font_bold"] = false
vars["font_italic"] = false
vars["font_size"] = 12

local font = config["theme"]["font"]
local parts = text.split (font, ":")
for _, part in ipairs (parts) do
  if text.matches (part, "bold") then
    vars["font_bold"] = true
  elseif text.matches (part, "italic") then
    vars["font_italic"] = true
  elseif text.matches (part, "size=.+") then
    local size = text.split (part, "=")[2]
    vars["font_size"] = tonumber (size)
  elseif part ~= "" then
    vars["font_name"] = part
  end
end

function read_resolve_data ()
  data = util.json(CONFIG_DIR .. "/.data")

  vars["user"] = data["login"]["user"]
  vars["hostname"] = data["login"]["host"]
  vars["rls_name"] = data["release"]["name"]
  vars["rls_codename"] = data["release"]["codename"]
  vars["cpu_load"] = data["loads"]["cpu"]["util"]
  vars["mem_load"] = data["loads"]["memory"]["util"]
  vars["disk_load"] = data["loads"]["disk"]["util"]
  vars["cpu_temp"] = data["thermals"]["cpu"]
  vars["gpu_util"] = data["loads"]["gpu"]["util"]
  vars["gpu_mem"] = data["loads"]["gpu"]["used"]
  vars["gpu_temp"] = data["thermals"]["gpu"]
  vars["net_name"] = data["network"]["name"]
  vars["lan_ip"] = data["network"]["lip"]
  vars["public_ip"] = data["network"]["pip"]
  vars["up_mbytes"] = data["network"]["sent"]
  vars["down_mbytes"] = data["network"]["recv"]
  vars["up_speed"] = data["network"]["upspeed"]
  vars["down_speed"] = data["network"]["downspeed"]

  local hours = string.format ("%02d", data["uptime"]["hours"])
  local mins = string.format ("%02d", data["uptime"]["mins"])
  local secs = string.format ("%02d", data["uptime"]["secs"])

  vars["uptime"] = hours .. ":" .. mins .. ":" .. secs

  logger.debug ("system data loaded from resolver's data file")
end

-- Calls the given callback in the given loop cycle
function call (cycle, callback)
  if cycle > 0 then
    local timer = (loop % cycle)

    -- Return if not in the given cycle or not at start up
    if timer ~= 0 and status ~= "init" then
      return true
    end
  end

  callback ()

  return true
end

-- Main lua function called by conky
function conky_main ()
  if conky_window == nil then
    return
  end

  -- Update the current conky loop index
  loop = tonumber (conky_parse ("${updates}"))

  call (1, read_resolve_data)

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

  text = text .. "${color " .. vars["mode"] .. "}\n"
  text = text .. ln (1.4, ie ("${head}"))
  text = text .. ln (1.0, ie ("USER ${user} HOST ${hostname}"))
  text = text .. ln (1.0, ie ("DISTRO ${rls_name} ${rls_codename}"))
  text = text .. ln (1.0, ie ("CPU ${cpu_load}% MEM ${mem_load}% DISK ${disk_load}%"))
  text = text .. ln (1.0, ie ("CPU ".. vars["cpu_temp"] .. "°C"))
  text = text .. ln (1.0, ie ("GPU ${gpu_util}% MEM ${gpu_mem}MB TEMP ${gpu_temp}°C"))
  text = text .. ln (1.0, ie ("NETWORK ${net_name}"))
  text = text .. ln (1.0, ie ("LAN ${lan_ip}"))
  text = text .. ln (1.0, ie ("NET ${public_ip}"))
  text = text .. ln (1.0, ie ("SENT ${up_mbytes}MB RECEIVED ${down_mbytes}MB"))
  text = text .. ln (1.0, ie ("UP ${up_speed}Mbps DOWN ${down_speed}Mbps"))
  text = text .. ln (1.0, ie ("UPTIME T+${uptime}"))

  return conky_parse (text)
end

read_resolve_data ()