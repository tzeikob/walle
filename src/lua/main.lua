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

  -- Render ui components
  ui.render ()

  -- Destroy ui context
  ui.destroy ()

  logger:debug ("exiting the post conky draw phase")
end