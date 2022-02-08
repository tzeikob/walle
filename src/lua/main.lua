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

local ui = require "ui"
local util = require "util"
local logger = require "logger"
local context = require "context"
local format = require "format"

-- Read debug mode env variable
local debug_mode = util.to_boolean (os.getenv ("DEBUG_MODE"))

-- Load configuration settings
local config = util.yaml.load (CONFIG_FILE_PATH)

-- Checks if the given cycle matches the current context loop
function matches_cycle (cycle)
  local timer = (context.state.loop % cycle)

  -- Return true if in the given cycle or at start up
  if timer == 0 or context.state.phase == "init" then
    return true
  end

  return false
end

-- Initializes the lua context
function conky_init ()
  logger.debug ('entering initialization phase')

  -- Initialize logger
  logger.set_debug_mode (debug_mode)
  logger.set_log_file (LOG_FILE_PATH)

  -- Load static data
  local static = util.json.load (DATA_DIR .. "/static")
  context.static.load (static)

  -- Load timings data
  local timings = util.json.load (DATA_DIR .. "/timings")
  context.timings.load (timings)

  -- Load monitoring data
  local monitor = util.json.load (DATA_DIR .. "/monitor")
  context.monitor.load (monitor)

  -- Load listeners data
  local listeners = util.json.load (DATA_DIR .. "/listeners")
  context.listeners.load (listeners)

  logger.debug ("initialization completed successfully")
end

-- Resolves monitoring system data
function conky_resolve ()
  logger.debug ("entering the pre conky resolve phase")
  logger.debug ("reading monitoring data...")

  -- Update the current conky loop index
  context.state.loop = tonumber (conky_parse ("${updates}"))

  -- Load timings data
  local timings = util.json.load (DATA_DIR .. "/timings")
  context.timings.load (timings)

  if matches_cycle (1) then
    -- Load dynamic data from the monitor data file
    local monitor = util.json.load (DATA_DIR .. "/monitor")
    context.monitor.load (monitor)

    -- Load dynamic data from the listeners data file
    local listeners = util.json.load (DATA_DIR .. "/listeners")
    context.listeners.load (listeners)
  end

  logger.debug ("monitoring data has been loaded to context")
  logger.debug ("context:\n" .. util.json.stringify (context.vars))

  -- Mark conky as running in the subsequent cycles
  if context.state.phase == "init" then
    context.state.phase = "running"

    logger.debug ("state changed from init to running")
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

  -- Read various ui config settings
  local dark = config["dark"]
  local scale = config["scale"]
  local offsets = config["offsets"]

  -- Initialize ui context
  ui.init (conky_window, dark, scale, offsets)

  -- Draw ui context
  if debug_mode then
    ui.render_borders ()
    ui.render_grid ()
  end

  -- Read context vars
  local vars = context.vars

  -- Attach processor ui component
  local cpu_clock = util.opt (vars["cpu_clock"], 0)
  local cpu_util = util.opt (vars["cpu_util"], 0.0)

  cpu_clock = format.int (cpu_clock, "%04d") .. "MHz"
  cpu_util = format.int (cpu_util, "%02d") .. "%"

  ui.attach ("PROCESSOR", cpu_clock, cpu_util)

  -- Attach graphics ui component
  local gpu_used = util.opt (vars["gpu_used"], 0)
  local gpu_util = util.opt (vars["gpu_util"], 0.0)

  gpu_used = format.int (gpu_used, "%05d") .. "MB"
  gpu_util = format.int (gpu_util, "%02d") .. "%"

  ui.attach ("GRAPHICS", gpu_used, gpu_util)

  -- Attach memory ui component
  local mem_used = util.opt (vars["mem_used"], 0)
  local mem_util = util.opt (vars["mem_util"], 0.0)

  mem_used = format.int (mem_used, "%06d") .. "MB"
  mem_util = format.int (mem_util, "%02d") .. "%"

  ui.attach ("MEMORY", mem_used, mem_util)

  -- Attach root disk ui component
  local disk_root_used = util.opt (vars["disk_root_used"], 0)
  local disk_root_util = util.opt (vars["disk_root_util"], 0.0)
  local disk_root_type = util.opt (vars["disk_root_type"])

  disk_root_used = format.int (disk_root_used, "%06d") .. "MB"
  disk_root_util = format.int (disk_root_util, "%02d") .. "%"
  disk_root_type = format.upper (disk_root_type)

  ui.attach ("DISK " .. disk_root_type, disk_root_used, disk_root_util)

  -- Attach keyboard ui component
  local kb_press = util.opt (vars["kb_press"], 0)
  kb_press = format.int (kb_press, "%06d")

  ui.attach ("KEYBOARD", kb_press, "Keys")

  -- Attach mouse clicks ui component
  local ms_clicks = util.opt (vars["ms_left"], 0) + util.opt (vars["ms_right"], 0) + util.opt (vars["ms_middle"], 0)
  ms_clicks = format.int (ms_clicks, "%06d")

  ui.attach ("MOUSE", ms_clicks, "Clks")

  -- Render ui into the canvas
  ui.render ()

  -- Destroy ui context
  ui.destroy ()

  logger.debug ("exiting the post conky draw phase")
end