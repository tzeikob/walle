-- Main lua entry point for the conkyrc file

-- Resolved base and config paths at build time
PKG_NAME = "#PKG_NAME"
BASE_DIR = "/usr/share/" .. PKG_NAME .. "/lua"
CONFIG_DIR = "/home/#USER/.config/" .. PKG_NAME
DATA_DIR = CONFIG_DIR .. "/.data"

CONFIG_FILE_PATH = CONFIG_DIR .. "/config.yml"
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

  -- Load timings data
  local timings = util.json.load (DATA_DIR .. "/timings")
  context.timings.load (timings)

  if matches_cycle (1) then
    logger.debug ("reading dynamic data...")

    -- Load dynamic data from the resolver data file
    local monitor = util.json.load (DATA_DIR .. "/monitor")
    context.monitor.load (monitor)

    logger.debug ("monitoring data has been loaded")
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

  -- Add font color theme
  local theme_color = vars["theme_color"]

  text = text .. "${color " .. theme_color .. "}\n"

  -- Build the optional head line text
  local head_line = vars["head_line"]

  if util.given (head_line) then
    head_line = format.upper (head_line)

    text = text .. ln (head_line, 1.4)
  end

  -- Build the user and host line text
  local user = opt (vars["user"])
  local host = opt (vars["host"])

  user = format.upper (user)
  host = format.upper (host)

  text = text .. ln ("USER " .. user .. " HOST " .. host)

  -- Build the release line text
  local rls_name = opt (vars["rls_name"])
  local rls_codename = opt (vars["rls_codename"])
  local rls_version = opt (vars["rls_version"])

  rls_name = format.upper (rls_name)
  rls_codename = format.upper (rls_codename)
  rls_version = format.upper (rls_version)

  text = text .. ln ("SYSTEM " .. rls_name .. " " .. rls_codename .. " v" .. rls_version) .. "\n"

  -- Build the cpu line text
  local cpu_util = opt (vars["cpu_util"], 0.0)
  local cpu_clock = opt (vars["cpu_clock"], 0)
  local cpu_temp = opt (vars["cpu_temp"], 0.0)

  cpu_util = format.int (cpu_util, "%02d")
  cpu_clock = format.int (cpu_clock, "%04d")
  cpu_temp = format.int (cpu_temp, "%02d")

  text = text .. ln ("PROCESSOR " .. cpu_util .. "% " .. cpu_clock .. "MHz " .. cpu_temp .. "°C")

    -- Build the gpu line text
  local gpu_util = opt (vars["gpu_util"], 0.0)
  local gpu_used = opt (vars["gpu_used"], 0)
  local gpu_temp = opt (vars["gpu_temp"], 0.0)

  gpu_util = format.int (gpu_util, "%02d")
  gpu_used = format.int (gpu_used, "%05d")
  gpu_temp = format.int (gpu_temp, "%02d")

  text = text .. ln ("GRAPHICS " .. gpu_util .. "% " .. gpu_used .. "MB " .. gpu_temp .. "°C")

  -- Build the memory line text
  local mem_util = opt (vars["mem_util"], 0.0)
  local mem_used = opt (vars["mem_used"], 0)
  local mem_speed = opt (vars["mem_speed"], 0)

  mem_util = format.int (mem_util, "%02d")
  mem_used = format.int (mem_used, "%06d")
  mem_speed = format.int (mem_speed, "%04d")

  text = text .. ln ("MEMORY " .. mem_util .. "% " .. mem_used .. "MB " .. mem_speed .. "MHz")

  -- Build the disk line text
  local disk_util = opt (vars["disk_util"], 0.0)
  local disk_used = opt (vars["disk_used"], 0)
  local disk_free = opt (vars["disk_free"], 0)
  local disk_type = opt (vars["disk_type"])

  disk_util = format.int (disk_util, "%02d")
  disk_used = format.int (disk_used, "%06d")
  disk_free = format.int (disk_free, "%06d")
  disk_type = format.upper (disk_type)

  text = text .. ln ("DISK ROOT " .. disk_type .. " " .. disk_util .. "% Ux " .. disk_used .. "MB Fx " .. disk_free .. "MB")

  if util.given(vars["disk_home_util"]) then
    local disk_home_util = opt (vars["disk_home_util"], 0.0)
    local disk_home_used = opt (vars["disk_home_used"], 0)
    local disk_home_free = opt (vars["disk_home_free"], 0)
    local disk_home_type = opt (vars["disk_home_type"])
  
    disk_home_util = format.int (disk_home_util, "%02d")
    disk_home_used = format.int (disk_home_used, "%06d")
    disk_home_free = format.int (disk_home_free, "%06d")
    disk_home_type = format.upper (disk_home_type)

    text = text .. ln ("DISK HOME " .. disk_home_type .. " " .. disk_home_util .. "% Ux " .. disk_home_used .. "MB Fx " .. disk_home_free .. "MB")
  end

  local disk_read = opt (vars["disk_read"], 0)
  local disk_read_speed = opt (vars["disk_read_speed"], 0.0)

  local disk_write = opt (vars["disk_write"], 0)
  local disk_write_speed = opt (vars["disk_write_speed"], 0.0)

  disk_read = format.int (disk_read, "%05d")
  disk_read_speed = format.number (disk_read_speed, "%06.1f")

  disk_write = format.int (disk_write, "%05d")
  disk_write_speed = format.number (disk_write_speed, "%06.1f")

  text = text .. ln ("READ " .. disk_read .. "MB " .. disk_read_speed .. "MB/s")
  text = text .. ln ("WRITE " .. disk_write .. "MB " .. disk_write_speed .. "MB/s")

  -- Build the upload network line text
  local net_sent_bytes = 0
  local net_up_speed = 0.0

  if vars["net_up"] then
    net_sent_bytes = opt (vars["net_sent_bytes"], 0)
    net_up_speed = opt (vars["net_up_speed"], 0.0)
  end

  net_sent_bytes = format.int (net_sent_bytes, "%05d")
  net_up_speed = format.number (net_up_speed, "%05.1f")

  text = text .. ln (" UPLOAD " .. net_sent_bytes .. "MB " .. net_up_speed .. "Mbps")

  -- Build the download network line text
  local net_recv_bytes = 0
  local net_down_speed = 0.0

  if vars["net_up"] then
    net_recv_bytes = opt (vars["net_recv_bytes"], 0)
    net_down_speed = opt (vars["net_down_speed"], 0.0)
  end

  net_recv_bytes = format.int (net_recv_bytes, "%05d")
  net_down_speed = format.number (net_down_speed, "%05.1f")

  text = text .. ln ("DOWNLOAD " .. net_recv_bytes .. "MB " .. net_down_speed .. "Mbps")

  -- Build the local network line text
  local net_name = "NA"
  local lan_ip = "x.x.x.x"

  if vars["net_up"] then
    net_name = format.upper (opt (vars["net_name"]))
    lan_ip = opt (vars["lan_ip"], "x.x.x.x")
  end

  text = text .. ln ("NETWORK " .. net_name .. " IP " .. lan_ip) .. "\n"

  -- Build the uptime line text
  local uptime = opt (vars["uptime"])

  text = text .. ln ("UPTIME T+" .. uptime)

  return conky_parse (text)
end

-- Load configuration settings
config = util.yaml.load (CONFIG_FILE_PATH)

-- Initialize logger
logger.set_debug_mode (config["debug"])
logger.set_log_file (LOG_FILE_PATH)

-- Load static configuration variables
context.config.load (config)

-- Load hardware data
hardware = util.json.load (DATA_DIR .. "/hardware")
context.hardware.load (hardware)

-- Load release data
release = util.json.load (DATA_DIR .. "/release")
context.release.load (release)

-- Load login data
login = util.json.load (DATA_DIR .. "/login")
context.login.load (login)

-- Load timings data
timings = util.json.load (DATA_DIR .. "/timings")
context.timings.load (timings)

-- Load monitoring data
monitor = util.json.load (DATA_DIR .. "/monitor")
context.monitor.load (monitor)