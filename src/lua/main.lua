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
package.path = package.path .. ";" .. BASE_DIR .. "/?.lua"
package.path = package.path .. ";" .. BASE_DIR .. "/common/?.lua"
package.path = package.path .. ";" .. BASE_DIR .. "/components/?.lua"

local util = require "util"
local logging = require "logging"
local canvas = require "canvas"
local grid = require "grid"

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

  -- Initialize the ui 2d context
  local canvas = canvas.Canvas:new (conky_window, config["dark"], config["scale"], config["offsets"])

  -- Create and render ui components on the 2d context
  if debug_mode then
    local grid = grid.Grid:new (canvas, { 1, 1, 1, 0.8 })
    grid:render ()
  end

  -- Destroy the ui context
  canvas:dispose ()

  logger:debug ("exiting the post conky draw phase")
end