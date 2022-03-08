-- A lua module for various util functions

local yaml = require "yaml"
local json = require "cjson"
local format = require "format"

-- Executes a native system command given as string
local function exec (command)
  local file = io.popen (command)
  local output = file:read ("*a")
  file:close ()

  return format.trim (output)
end

-- Reads the given file
local function read (path)
  local file = io.open (path, "r")
  local data = file:read ("*a")
  file:close ()

  return data
end

-- Loads the given yaml file into a dictionary object
local function load_yaml (path)
  local file = io.open (path, "r")
  local dict = yaml.load (file:read ("*a"))
  file:close ()

  return dict
end

-- Loads the given json file into a dictionary object
local function load_json (path)
  local file = io.open (path, "r")
  local dict = json.decode (file:read ("*a"))
  file:close ()

  return dict
end

-- Encodes the given dictionary into a string json
local function stringify (dict)
  return json.encode (dict)
end

-- Check if the given value is nil or empty
local function is_empty (value)
  return value == nil or value == ""
end

-- Check if the given value is not nil and not empty
local function is_not_empty (value)
  return not is_empty (value)
end

-- Returns the given value if not empty, otherwise the default
local function default_to (value, default)
  if is_empty (value) then
    return default
  end

  return value
end

-- Return if the given value is not nullish not empty
local function given (value)
  return is_not_empty(value) and value ~= json.null
end

-- Returns the value itself unless it is nullish or empty
local function opt (value, default)
  if not given (value) then
    return default or "n/a"
  end

  return value
end

-- Converts the given value to boolean
local function to_boolean (value)
  return value == "true"
end

return {
  exec = exec,
  read = read,
  yaml = {
    load = load_yaml
  },
  json = {
    load = load_json,
    stringify = stringify,
    null = json.null
  },
  is_empty = is_empty,
  is_not_empty = is_not_empty,
  default_to = default_to,
  given = given,
  opt = opt,
  to_boolean = to_boolean
}