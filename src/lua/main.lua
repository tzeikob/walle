-- Main lua entry point for the conkyrc file

-- Resolved base and config paths at build time
local PKG_NAME = "#PKG_NAME"
local BASE_DIR = "/usr/share/" .. PKG_NAME .. "/lua"
local CONFIG_DIR = "/home/#USER/.config/" .. PKG_NAME
local DATA_DIR = CONFIG_DIR .. "/.data"

local CONFIG_FILE_PATH = CONFIG_DIR .. "/config.yml"
local LOG_FILE_PATH = CONFIG_DIR .. "/all.log"

-- Add base directory to lua package path
package.path = package.path .. ";" .. BASE_DIR .. "/?.lua"

local cairo = require "cairo"
local ui = require "ui"
local util = require "util"
local logger = require "logger"
local context = require "context"
local format = require "format"

-- Checks if the given cycle matches the current context loop
function matches_cycle (cycle)
  local timer = (context.loop % cycle)

  -- Return true if in the given cycle or at start up
  if timer == 0 or context.status == "init" then
    return true
  end

  return false
end

-- Resolves monitoring system data
function conky_resolve ()
  logger.debug ("entering the pre conky resolve phase")
  logger.debug ("reading monitoring data...")

  -- Update the current conky loop index
  context.loop = tonumber (conky_parse ("${updates}"))

  -- Load timings data
  local timings = util.json.load (DATA_DIR .. "/timings")
  context.timings.load (timings)

  if matches_cycle (1) then
    -- Load dynamic data from the monitor data file
    local monitor = util.json.load (DATA_DIR .. "/monitor")
    context.monitor.load (monitor)
  end

  logger.debug ("monitoring data has been loaded to context")
  logger.debug ("context:\n" .. util.json.stringify (context.vars))

  -- Mark conky as running in the subsequent cycles
  if context.status == "init" then
    context.status = "running"

    logger.debug ("changed from init to running state")
  end

  logger.debug ("exiting the pre conky resolve phase")
end

-- Draws the ui in conky's viewport
function conky_draw ()
  logger.debug ("entering the post conky draw phase")

  if conky_window == nil then
    logger.debug ("aborting since no conky window is ready")
    return
  end

  -- Create the cairo render viewport
  local surface = cairo_xlib_surface_create (conky_window.display,
    conky_window.drawable,
    conky_window.visual,
    conky_window.width,
    conky_window.height)

  local viewport = cairo_create (surface)

  -- Initialize ui context
  ui.init (
    conky_window.width,
    conky_window.height,
    context.vars["screen_width"],
    context.vars["screen_height"],
    config["viewport"]["pan"])

  -- Draw debug borders and grid
  if config["debug"] == "enabled" then
    ui.draw_border (viewport)
    ui.draw_grid (viewport)
  end

  -- Destroy and clean cairo render viewport
  cairo_destroy (viewport)
  cairo_surface_destroy (surface)
  viewport = nil

  logger.debug ("exiting the post conky draw phase")
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
  local user = util.opt (vars["user"])
  local host = util.opt (vars["host"])

  user = format.upper (user)
  host = format.upper (host)

  text = text .. ln ("USER " .. user .. " HOST " .. host)

  -- Build the release line text
  local rls_name = util.opt (vars["rls_name"])
  local rls_codename = util.opt (vars["rls_codename"])
  local rls_version = util.opt (vars["rls_version"])

  rls_name = format.upper (rls_name)
  rls_codename = format.upper (rls_codename)
  rls_version = format.upper (rls_version)

  text = text .. ln ("SYSTEM " .. rls_name .. " " .. rls_codename .. " v" .. rls_version) .. "\n"

  -- Build the cpu line text
  local cpu_util = util.opt (vars["cpu_util"], 0.0)
  local cpu_clock = util.opt (vars["cpu_clock"], 0)
  local cpu_temp = util.opt (vars["cpu_temp"], 0.0)

  cpu_util = format.int (cpu_util, "%02d")
  cpu_clock = format.int (cpu_clock, "%04d")
  cpu_temp = format.int (cpu_temp, "%02d")

  text = text .. ln ("PROCESSOR " .. cpu_util .. "% " .. cpu_clock .. "MHz " .. cpu_temp .. "°C")

    -- Build the gpu line text
  local gpu_util = util.opt (vars["gpu_util"], 0.0)
  local gpu_used = util.opt (vars["gpu_used"], 0)
  local gpu_temp = util.opt (vars["gpu_temp"], 0.0)

  gpu_util = format.int (gpu_util, "%02d")
  gpu_used = format.int (gpu_used, "%05d")
  gpu_temp = format.int (gpu_temp, "%02d")

  text = text .. ln ("GRAPHICS " .. gpu_util .. "% " .. gpu_used .. "MB " .. gpu_temp .. "°C")

  -- Build the memory line text
  local mem_util = util.opt (vars["mem_util"], 0.0)
  local mem_used = util.opt (vars["mem_used"], 0)
  local mem_speed = util.opt (vars["mem_speed"], 0)

  mem_util = format.int (mem_util, "%02d")
  mem_used = format.int (mem_used, "%06d")
  mem_speed = format.int (mem_speed, "%04d")

  text = text .. ln ("MEMORY " .. mem_util .. "% " .. mem_used .. "MB " .. mem_speed .. "MHz")

  -- Build the disk line text
  local disk_root_util = util.opt (vars["disk_root_util"], 0.0)
  local disk_root_used = util.opt (vars["disk_root_used"], 0)
  local disk_root_free = util.opt (vars["disk_root_free"], 0)
  local disk_root_type = util.opt (vars["disk_root_type"])

  disk_root_util = format.int (disk_root_util, "%02d")
  disk_root_used = format.int (disk_root_used, "%06d")
  disk_root_free = format.int (disk_root_free, "%06d")
  disk_root_type = format.upper (disk_root_type)

  text = text .. ln ("DISK ROOT " .. disk_root_type .. " " .. disk_root_util .. "% Ux " .. disk_root_used .. "MB Fx " .. disk_root_free .. "MB")

  if util.given(vars["disk_home_util"]) then
    local disk_home_util = util.opt (vars["disk_home_util"], 0.0)
    local disk_home_used = util.opt (vars["disk_home_used"], 0)
    local disk_home_free = util.opt (vars["disk_home_free"], 0)
    local disk_home_type = util.opt (vars["disk_home_type"])
  
    disk_home_util = format.int (disk_home_util, "%02d")
    disk_home_used = format.int (disk_home_used, "%06d")
    disk_home_free = format.int (disk_home_free, "%06d")
    disk_home_type = format.upper (disk_home_type)

    text = text .. ln ("DISK HOME " .. disk_home_type .. " " .. disk_home_util .. "% Ux " .. disk_home_used .. "MB Fx " .. disk_home_free .. "MB")
  end

  local disk_read = util.opt (vars["disk_read"], 0)
  local disk_read_speed = util.opt (vars["disk_read_speed"], 0.0)

  local disk_write = util.opt (vars["disk_write"], 0)
  local disk_write_speed = util.opt (vars["disk_write_speed"], 0.0)

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
    net_sent_bytes = util.opt (vars["net_sent_bytes"], 0)
    net_up_speed = util.opt (vars["net_up_speed"], 0.0)
  end

  net_sent_bytes = format.int (net_sent_bytes, "%05d")
  net_up_speed = format.number (net_up_speed, "%05.1f")

  text = text .. ln (" UPLOAD " .. net_sent_bytes .. "MB " .. net_up_speed .. "Mbps")

  -- Build the download network line text
  local net_recv_bytes = 0
  local net_down_speed = 0.0

  if vars["net_up"] then
    net_recv_bytes = util.opt (vars["net_recv_bytes"], 0)
    net_down_speed = util.opt (vars["net_down_speed"], 0.0)
  end

  net_recv_bytes = format.int (net_recv_bytes, "%05d")
  net_down_speed = format.number (net_down_speed, "%05.1f")

  text = text .. ln ("DOWNLOAD " .. net_recv_bytes .. "MB " .. net_down_speed .. "Mbps")

  -- Build the local network line text
  local net_name = "NA"
  local lan_ip = "x.x.x.x"

  if vars["net_up"] then
    net_name = format.upper (util.opt (vars["net_name"]))
    lan_ip = util.opt (vars["lan_ip"], "x.x.x.x")
  end

  text = text .. ln ("NETWORK " .. net_name .. " IP " .. lan_ip) .. "\n"

  -- Build the uptime line text
  local uptime = util.opt (vars["uptime"])

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