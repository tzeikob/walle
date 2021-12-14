-- A lua module for various util functions

yaml = require "yaml"
json = require "cjson"
format = require "format"

-- Executes a native system command given as string
function exec (command)
  local file = io.popen (command)
  local output = file:read ("*a")
  file:close ()

  return format.trim (output)
end

-- Reads the given file
function read (path)
  local file = io.open (path, "r")
  local data = file:read ("*a")
  file:close ()

  return data
end

-- Loads the given yaml file into a dictionary object
function load_yaml (path)
  local file = io.open (path, "r")
  local dict = yaml.load (file:read ("*a"))
  file:close ()

  return dict
end

-- Loads the given json file into a dictionary object
function load_json (path)
  local file = io.open (path, "r")
  local dict = json.decode (file:read ("*a"))
  file:close ()

  return dict
end

-- Encodes the given dictionary into a string json
function stringify (dict)
  return json.encode (dict)
end

-- Check if the given value is nil or empty
function is_empty (value)
  return value == nil or value == ""
end

-- Check if the given value is not nil and not empty
function is_not_empty (value)
  return not is_empty (value)
end

-- Returns the given value if not empty, otherwise the default
function default_to (value, default)
  if is_empty (value) then
    return default
  end

  return value
end

-- Return if the given value is not nullish not empty
function given (value)
  return is_not_empty(value) and value ~= json.null
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
  given = given
}