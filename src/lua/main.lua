-- Entry point script for lua in the conkyrc file

local PKG_NAME = "#PKG_NAME"
local BASE_DIR = "/usr/share/" .. PKG_NAME .. "/lua"
local CONFIG_DIR = "/home/#USER/.config/" .. PKG_NAME

local CONFIG_FILE_PATH = CONFIG_DIR .. "/config.yml"
local LOG_FILE_PATH = CONFIG_DIR .. "/all.log"
local DATA_FILE_PATH = CONFIG_DIR .. "/.data"

-- Add package paths to every lua script and module
package.path = package.path .. ";" .. BASE_DIR .. "/?.lua"
package.path = package.path .. ";" .. BASE_DIR .. "/common/?.lua"
package.path = package.path .. ";" .. BASE_DIR .. "/ui/?.lua"

local util = require "util"
local logging = require "logging"
local canvas = require "canvas"
local grid = require "grid"

local config = util.yaml.load (CONFIG_FILE_PATH)

-- Read debug mode from environment variables
local debug_mode = util.to_boolean (os.getenv ("DEBUG_MODE"))

local logger = logging.Logger:new (LOG_FILE_PATH, debug_mode)

-- Initialize the map to store the resolved data
local data = {}

function conky_init ()
  logger:debug ("entering initialization phase")

  -- Read and load the current resolved data
  data = util.json.load (DATA_FILE_PATH)

  logger:debug ("initialization completed successfully")
end

function conky_resolve ()
  logger:debug ("entering the pre conky resolve phase")
  logger:debug ("reading monitoring data...")

  -- Read and load the current resolved data
  data = util.json.load (DATA_FILE_PATH)

  logger:debug ("monitoring data has been loaded to context")
  logger:debug ("context:\n" .. util.json.stringify (data))

  logger:debug ("exiting the pre conky resolve phase")
end

function conky_draw ()
  logger:debug ("entering the post conky draw phase")

  if conky_window == nil then
    logger:debug ("aborting since no conky window is ready")
    return
  end

  -- Create the ui context as a 2d canvas
  local canvas = canvas.Canvas:new (conky_window, config["dark"], config["scale"], config["offsets"])

  -- Render ui components for debugging purposes
  if debug_mode then
    local grid_x = canvas.left
    local grid_y = canvas.top
    local grid_width = canvas.right - canvas.margin
    local grid_height = canvas.bottom - canvas.margin

    local grid = grid.Grid:new (canvas, grid_x, grid_y, grid_width, grid_height)
    grid:render ()
  end

  -- Destroy the ui context
  canvas:dispose ()

  logger:debug ("exiting the post conky draw phase")
end