-- Main lua entry point for the conkyrc file

-- Set debug mode variable in global scope
debug_mode = os.getenv ("DEBUG_MODE") == "true" or false

-- Resolved base and config paths at build time
local PKG_NAME = "#PKG_NAME"
local BASE_DIR = "/usr/share/" .. PKG_NAME .. "/lua"
local CONFIG_DIR = "/home/#USER/.config/" .. PKG_NAME

local CONFIG_FILE_PATH = CONFIG_DIR .. "/config.yml"
local LOG_FILE_PATH = CONFIG_DIR .. "/all.log"

-- Add base directory to lua package path
package.path = package.path .. ";" .. BASE_DIR .. "/?.lua;" .. BASE_DIR .. "/components/?.lua"

local ui = require "ui"
local util = require "util"
local logging = require "logging"
local format = require "format"

-- create logger and set it in global scope
logger = logging.Logger:new (LOG_FILE_PATH)

-- Load configuration settings
local config = util.yaml.load (CONFIG_FILE_PATH)

-- Initialize resolved data map
local data = {}

-- Initializes the lua context
function conky_init ()
  logger:debug ('entering initialization phase')

  -- Load resolved data
  data = util.json.load (CONFIG_DIR .. "/.data")

  logger:debug ("initialization completed successfully")
end

-- Resolves monitoring system data
function conky_resolve ()
  logger:debug ("entering the pre conky resolve phase")
  logger:debug ("reading monitoring data...")

  -- Load resolved data
  data = util.json.load (CONFIG_DIR .. "/.data")

  logger:debug ("monitoring data has been loaded to context")
  logger:debug ("context:\n" .. util.json.stringify (data))

  logger:debug ("exiting the pre conky resolve phase")
end

-- Draws the ui in conky's viewport
function conky_draw ()
  logger:debug ("entering the post conky draw phase")

  if conky_window == nil then
    logger:debug ("aborting since no conky window is ready")
    return
  end

  -- Read various ui config settings
  local dark = config["dark"]
  local scale = config["scale"]
  local offsets = config["offsets"]

  -- Initialize ui context
  ui.init (conky_window, dark, scale, offsets)

  -- Attach processor ui component
  local cpu_clock = util.opt (data["monitor"]["cpu"]["clock"], 0)
  local cpu_util = util.opt (data["monitor"]["cpu"]["util"], 0.0)

  cpu_clock = format.int (cpu_clock, "%04d") .. "MHz"
  cpu_util = format.int (cpu_util, "%02d") .. "%"

  ui.attach ("PROCESSOR", cpu_clock, cpu_util)

  -- Attach graphics ui component
  local gpu_used = util.opt (data["monitor"]["gpu"]["used"], 0)
  local gpu_util = util.opt (data["monitor"]["gpu"]["util"], 0.0)

  gpu_used = format.int (gpu_used, "%05d") .. "MB"
  gpu_util = format.int (gpu_util, "%02d") .. "%"

  ui.attach ("GRAPHICS", gpu_used, gpu_util)

  -- Attach memory ui component
  local mem_used = util.opt (data["monitor"]["memory"]["used"], 0)
  local mem_util = util.opt (data["monitor"]["memory"]["util"], 0.0)

  mem_used = format.int (mem_used, "%06d") .. "MB"
  mem_util = format.int (mem_util, "%02d") .. "%"

  ui.attach ("MEMORY", mem_used, mem_util)

  -- Attach root disk ui component
  local disk_root_used = util.opt (data["monitor"]["disk"]["used"], 0)
  local disk_root_util = util.opt (data["monitor"]["disk"]["util"], 0.0)

  disk_root_used = format.int (disk_root_used, "%06d") .. "MB"
  disk_root_util = format.int (disk_root_util, "%02d") .. "%"

  ui.attach ("DISK " .. 'EXT4', disk_root_used, disk_root_util)

  -- Attach keyboard ui component
  local kb_press = util.opt (data["keyboard"]["press"], 0)
  kb_press = format.int (kb_press, "%06d")

  ui.attach ("KEYBOARD", kb_press, "Keys")

  -- Attach mouse clicks ui component
  local ms_clicks = util.opt (data["mouse"]["left"], 0) + util.opt (data["mouse"]["right"], 0) + util.opt (data["mouse"]["middle"], 0)
  ms_clicks = format.int (ms_clicks, "%06d")

  ui.attach ("MOUSE", ms_clicks, "Clks")

  -- Attach the uptime component
  ui.attach ("UPTIME", "T+" .. data["uptime"]["hours"] .. ":" .. data["uptime"]["mins"] .. ":" .. data["uptime"]["secs"], "-")

  -- Render ui into the canvas
  ui.render ()

  -- Destroy ui context
  ui.destroy ()

  logger:debug ("exiting the post conky draw phase")
end