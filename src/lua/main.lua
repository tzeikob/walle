-- Main lua entry point for the conkyrc file

-- Resolved base and config paths at build time
PKG_NAME = "#PKG_NAME"
BASE_DIR = "/usr/share/" .. PKG_NAME .. "/lua"
CONFIG_DIR = "/home/#USER/.config/" .. PKG_NAME

CONFIG_FILE_PATH = CONFIG_DIR .. "/config.yml"
DATA_FILE_PATH = CONFIG_DIR .. "/.data"
UPTIME_FILE_PATH = "/proc/uptime"
LOG_FILE_PATH = CONFIG_DIR .. "/all.log"

-- Add base directory to lua package path
package.path = package.path .. ";" .. BASE_DIR .. "/?.lua"

util = require "util"
logger = require "logger"
context = require "context"
format = require "format"

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

  -- Load timing data
  local uptime = util.read (UPTIME_FILE_PATH)
  context.timings.load (uptime)

  if matches_cycle (5) then
    logger.debug ("reading dynamic data...")

    -- Load dynamic data from the resolver data file
    local data = util.json.load (DATA_FILE_PATH)
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

-- Converts the given text to a conkyrc text line
function ln (text, scale)
  -- Read the interpolation variables from the context
  local vars = context.vars

  local line = "${alignr}"

  line = line .. "${font " .. vars["font_name"]

  if vars["font_bold"] then
    line = line .. ":bold"
  end

  if vars["font_italic"] then
    line = line .. ":italic"
  end

  local size = vars["font_size"]

  if scale and scale > 1 then
    size = size * scale
  end

  line = line .. ":size=" .. size .. "}" .. text .. "${font}" .. "\n"

  return line
end

-- Returs the value itself unless it is nullish or empty
function opt (value, default)
  if not util.given (value) then
    return default or "n/a"
  end

  return value
end

-- Builds and returns the conky text
function conky_text ()
  -- Read the interpolation variables from the context
  local vars = context.vars

  local text = ""

  local theme_color = vars["theme_color"]

  text = text .. "${color " .. theme_color .. "}\n"

  local head_line = vars["head_line"]

  if util.given (head_line) then
    head_line = format.upper (head_line)

    text = text .. ln (head_line, 1.4)
  end

  local user = opt (vars["user"])
  local host = opt (vars["host"])

  user = format.upper (user)
  host = format.upper (host)

  text = text .. ln ("USER " .. user .. " HOST " .. host)

  local rls_name = opt (vars["rls_name"])
  local rls_codename = opt (vars["rls_codename"])
  local rls_version = opt (vars["rls_version"])

  rls_name = format.upper (rls_name)
  rls_codename = format.upper (rls_codename)
  rls_version = format.upper (rls_version)

  text = text .. ln ("SYS " .. rls_name .. " " .. rls_codename .. " v" .. rls_version)

  local cpu_util = opt (vars["cpu_util"])
  local cpu_clock = opt (vars["cpu_clock"])
  local cpu_temp = opt (vars["cpu_temp"])
  text = text .. ln ("CPU " .. cpu_util .. "% " .. cpu_clock .. "MHz " .. cpu_temp .. "°C")

  local gpu_util = opt (vars["gpu_util"])
  local gpu_used = opt (vars["gpu_used"])
  local gpu_temp = opt (vars["gpu_temp"])
  text = text .. ln ("GPU " .. gpu_util .. "% " .. gpu_used .. "MB " .. gpu_temp .. "°C")

  local mem_util = opt (vars["mem_util"])
  local mem_used = opt (vars["mem_used"])
  local mem_free = opt (vars["mem_free"])
  text = text .. ln ("MEM " .. mem_util .. "% " .. mem_used .. "MB " .. mem_free .. "MB")

  local disk_util = opt (vars["disk_util"])
  local disk_read = opt (vars["disk_read"])
  local disk_write = opt (vars["disk_write"])
  text = text .. ln ("HD " .. disk_util .. "% R " .. disk_read .. "MB W " .. disk_write .. "MB")

  local net_up_speed = 0.0
  local net_sent_bytes = 0

  if vars["net_up"] then
    net_up_speed = opt (vars["net_up_speed"], 0.0)
    net_sent_bytes = opt (vars["net_sent_bytes"], 0)
  end

  text = text .. ln (" UP " .. net_up_speed .. "Mbps TRx " .. net_sent_bytes .. "MB")

  local net_down_speed = 0.0
  local net_recv_bytes = 0

  if vars["net_up"] then
    net_down_speed = opt (vars["net_down_speed"], 0.0)
    net_recv_bytes = opt (vars["net_recv_bytes"], 0)
  end

  text = text .. ln ("DOWN " .. net_down_speed .. "Mbps REx " .. net_recv_bytes .. "MB")

  local net_name = "NA"
  local lan_ip = "x.x.x.x"

  if vars["net_up"] then
    net_name = format.upper (opt (vars["net_name"]))
    lan_ip = opt (vars["lan_ip"], "x.x.x.x")
  end

  text = text .. ln ("LAN " .. net_name .. " IP " .. lan_ip)

  local public_ip = "x.x.x.x"

  if vars["net_up"] then
    public_ip = opt (vars["public_ip"], "x.x.x.x")
  end

  text = text .. ln ("PUB IP " .. public_ip)

  local uptime = opt (vars["uptime"])

  text = text .. ln ("UP T+" .. uptime)

  return conky_parse (text)
end

-- Load configuration settings
config = util.yaml.load (CONFIG_FILE_PATH)

-- Initialize logger
logger.set_debug_mode (config["debug"])
logger.set_log_file (LOG_FILE_PATH)

-- Load static configuration variables
context.static.load (config)

-- Load dynamic system data
data = util.json.load (DATA_FILE_PATH)
context.dynamic.load (data)

-- Load timing data
uptime = util.read (UPTIME_FILE_PATH)
context.timings.load (uptime)