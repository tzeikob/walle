-- Main lua entry point for the conkyrc file

-- Resolved base and config paths at build time
PKG_NAME = "#PKG_NAME"
BASE_DIR = "/usr/share/" .. PKG_NAME .. "/lua"
CONFIG_DIR = "/home/#USER/.config/" .. PKG_NAME

CONFIG_FILE_PATH = CONFIG_DIR .. "/config.yml"
DATA_FILE_PATH = CONFIG_DIR .. "/.data"
LOG_FILE_PATH = CONFIG_DIR .. "/all.log"

-- Add base directory to lua package path
package.path = package.path .. ";" .. BASE_DIR .. "/?.lua"

util = require "util"
logger = require "logger"
context = require "context"

-- Load configuration settings
config = util.yaml.load (CONFIG_FILE_PATH)

-- Initialize logger
logger.set_debug_mode (config["debug"])
logger.set_log_file (LOG_FILE_PATH)

-- Checks if the given cycle matches the current context loop
function matches_cycle (cycle)
  local timer = (context.loop % cycle)

  -- Return true if in the given cycle or at start up
  if timer == 0 or context.status == "init" then
    return true
  end

  return false
end

-- Main lua function called by conky
function conky_main ()
  logger.debug ("entering a conky cycle")

  if conky_window == nil then
    logger.debug ("aborting since no conky window is ready")
    return
  end

  -- Update the current conky loop index
  context.loop = tonumber (conky_parse ("${updates}"))

  if matches_cycle (1) then
    logger.debug ("reading dynamic data...")

    -- Load dynamic data from the resolver data file
    data = util.json.load (DATA_FILE_PATH)
    context.dynamic.load (data)

    logger.debug ("dynamic data has been loaded")
    logger.debug ("context:\n" .. util.json.stringify (context.vars))
  end

  -- Mark conky as running in the subsequent cycles
  if context.status == "init" then
    context.status = "running"

    logger.debug ("changed from init to running state")
  end

  logger.debug ("exiting the conky cycle")
end

-- Returns the given text interpolating any given variables
function ie (text)
  -- Read the interpolation variables from the context
  vars = context.vars

  local matches = string.gmatch (text, '${([a-zA-Z_]+)}')

  for key in matches do
    if vars[key] ~= nil and vars[key] ~= util.json.null then
      text = string.gsub (text, '${' .. key .. '}', vars[key])
    end
  end

  return text
end

-- Converts the given text to a conkyrc text line
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

-- Load static configuration variables
context.static.load (config)

-- Load dynamic system data
data = util.json.load (DATA_FILE_PATH)
context.dynamic.load (data)