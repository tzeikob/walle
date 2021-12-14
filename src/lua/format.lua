-- A lua module to format and manage text

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
  end

  return false
end

-- Changes the first character to upper case
function cap (str)
  if str == nil or str == "" then
    return str
  end

  return str:gsub ("^%l", string.upper)
end

-- Converts the given string to upper case
function upper (str)
  if str == nil or str == "" then
    return str
  end

  return str:upper ()
end

-- Trims any whitespace of the given string
function trim (str)
  if str ~= nil then
    return str:gsub ("^%s*(.-)%s*$", "%1")
  end

  return str
end

-- Converts the number into a string with the given pattern
function number (value, pattern)
  if format then
    value = string.format (pattern, value)
  end

  return value
end

-- Converts the integer into a string witht he given pattern
function int (value, pattern)
  value = math.floor (value + 0.5)

  return number(value, pattern)
end

return {
  split = split,
  matches = matches,
  cap = cap,
  upper = upper,
  trim = trim,
  number = number,
  int = int
}