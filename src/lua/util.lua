-- A lua module for various util functions

lfs = require "lfs"
yaml = require "yaml"
json = require "cjson"
text = require "text"

-- Executes a native system command given as string
function exec (command)
  local file = io.popen (command)
  local output = file:read ("*a")
  file:close ()

  return text.trim (output)
end

-- Returns the list of files filtered by the given patterns
function list (path, ...)
  -- Return if no such path exists
  if not lfs.chdir(path) then
    return {}
  end

  local paths = {}

  for file in lfs.dir (path) do
    if matches (file, ...) then
      table.insert (paths, path .. "/" .. file)
    end
  end

  return paths
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

return {
  exec = exec,
  list = list,
  yaml = load_yaml,
  json = load_json,
  is_empty = is_empty,
  is_not_empty = is_not_empty,
  default_to = default_to
}