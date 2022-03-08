-- A lua module to convert between different units

-- Rounds the given value to the given number of decimal places
local function round (value, precision)
  local mult = 10 ^ (precision or 0)

  return math.floor (value * mult + 0.5) / mult
end

-- Converts bytes to bits
local function b (bytes)
  return bytes * 8
end

-- Converts bytes to kilo bits
local function Kb (bytes)
  return b (bytes) / 1024
end

-- Converts bytes to mega bits
local function Mb (bytes)
  return b (bytes) / 1024 ^ 2
end

-- Converts bytes to giga bits
local function Gb (bytes)
  return b (bytes) / 1024 ^ 3
end

-- Converts bytes to kilo bytes
local function KB (bytes)
  return bytes / 1024
end

-- Converts bytes to mega bytes
local function MB (bytes)
  return bytes / 1024 ^ 2
end

-- Converts bytes to giga bytes
local function GB (bytes)
  return bytes / 1024 ^ 3
end

return {
  round = round,
  b = b,
  Kb = Kb,
  Mb = Mb,
  Gb = Gb,
  KB = KB,
  MB = MB,
  GB = GB
}