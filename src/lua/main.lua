-- Entry point script for lua in the conkyrc file

local PKG_NAME = "#PKG_NAME"
local BASE_DIR = "/usr/share/" .. PKG_NAME .. "/lua"
local CONFIG_DIR = "/home/#USER/.config/" .. PKG_NAME
local ASSETS_DIR = CONFIG_DIR .. "/assets"

local CONFIG_FILE_PATH = CONFIG_DIR .. "/config.yml"
local LOG_FILE_PATH = CONFIG_DIR .. "/all.log"
local DATA_FILE_PATH = CONFIG_DIR .. "/.data"

-- Add package paths to every lua script and module
package.path = package.path .. ";" .. BASE_DIR .. "/?.lua"
package.path = package.path .. ";" .. BASE_DIR .. "/common/?.lua"
package.path = package.path .. ";" .. BASE_DIR .. "/ui/?.lua"

local util = require "util"
local logging = require "logging"
local format = require "format"

local Canvas = require "canvas"
local Grid = require "grid"
local Status = require "status"
local Actions = require "actions"
local Timings = require "timings"

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
  local canvas = Canvas:new (conky_window, config["dark"], config["scale"], config["offsets"])

  -- Render ui components for debugging purposes
  if debug_mode then
    -- Exclude grid area size from scaling
    local width = canvas.width / canvas.scale
    local height = canvas.height / canvas.scale

    local grid = Grid:new (canvas, width, height)
    grid:locate (canvas.left, canvas.top)
    grid:render ()
  end

  -- Render the user's status component
  local status = Status:new (canvas, {
    avatar = ASSETS_DIR .. '/avatar.png',
    energy = 999,
    username = format.upper (data.static.login.user),
    connected = data.network.conn })
  status:locate (canvas.left, canvas.bottom)
  status:render ()

  -- Render the user's actions component
  local actions = Actions:new (canvas, data.actions)
  actions:locate (canvas.right, canvas.bottom)
  actions:render ()

  -- Render the timings component
  local timings = Timings:new (canvas, { uptime = data.uptime })
  timings:locate (canvas.center_x, canvas.top)
  timings:render ()

  -- Destroy the ui context
  canvas:dispose ()

  logger:debug ("exiting the post conky draw phase")
end