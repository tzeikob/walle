-- A lua library for various util functions

lfs = require "lfs"
yaml = require "yaml"

-- Splits the string by the given delimiter
function split (str, delimiter, lazy)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find (str, delimiter, from)

  while delim_from do
    table.insert (result, string.sub (str, from , delim_from - 1))
    from = delim_to + 1

    -- Split only by the first occurence if lazy is given
    if lazy then
      break
    end

    delim_from, delim_to = string.find (str, delimiter, from)
  end

  table.insert (result, string.sub (str, from))

  return result
end

-- Change the first character to upper case
function cap (str)
  if str == nil or str == "" then
    return str
  end

  return (str:gsub ("^%l", string.upper))
end

-- Checks if the string matches the given patterns
function matches (str, ...)
  if str ~= nil then
    for _, pattern in ipairs ({...}) do
      if string.find (str, pattern) then
        return true
      end
    end
  end

  return false
end

-- Trims any whitespace of the string
function trim (str)
  if str ~= nil then
    return str:gsub ("^%s*(.-)%s*$", "%1")
  end

  return str
end

-- Executes a native system command given as string
function exec (command)
  local file = io.popen (command)
  local output = file:read ("*a")
  file:close ()

  return output
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

-- Round the given value to the given number of decimal places
function round (value, precision)
  local mult = 10^(precision or 0)

  return math.floor(value * mult + 0.5) / mult
end

return {
  split = split,
  cap = cap,
  matches = matches,
  trim = trim,
  exec = exec,
  list = list,
  yaml = load_yaml,
  round = round
}