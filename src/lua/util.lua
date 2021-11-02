-- A lua library for various util functions

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

-- Checks if the string matches the given patterns
function matches (str, ...)
  if str ~= nil then
    for _, pattern in ipairs ({...}) do
      if string.find (str, pattern) then
        return true
      end
    end

    return false
  end

  return str
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

return {
  split = split,
  matches = matches,
  trim = trim,
  exec = exec
}