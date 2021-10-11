-- Main lua file for the conky config file

-- Global variables
config_file = "~/.config/PKG_NAME/.wallerc"
conky_on_start = true

-- Splits the given string by the given delimiter
function string:split (delimiter)
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find (self, delimiter, from)

	while delim_from do
		table.insert (result, string.sub (self, from , delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find (self, delimiter, from)
	end

	table.insert ( result, string.sub (self, from))

	return result
end

-- Reads the configuration property with the given json path
function config (path, default)
  local cmd = "jq --raw-output " .. path .. " " .. config_file .. " | awk -- '{printf \"%s\", $1}'"
  local file = io.popen (cmd)
  local value = file:read ("*a")
  file:close ()

  -- Return default if not found
  if value ~= "null" then
    return value
  else
    return default
  end
end

-- Executes an operation after the given cycles have passed
function executeEvery (cycles, updates, operation)
	timer = (updates % cycles)

	if timer == 0 or conky_on_start then
    operation ()
	end
end

-- Initialize configuration properties
theme = config (".theme", "light")
interface = ""
ip = ""

-- Resolves the current network interface and IP
function resolveConnection ()
  local file = io.popen ("ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}'")
  output = file:read ("*a")
  file:close ()
  
  output = string.split (output, ',')

  interface = output[1]
  ip = output[2]
end

function conky_main ()
  -- Abort if the conky window is not rendered
  if conky_window == nil then
    return
  end

  -- Read the number of conky updates so far
  updates = tonumber (conky_parse ("${updates}"))

  executeEvery (10, updates, resolveConnection)

  -- Mark conky as started in the subsequent cycles
  if conky_on_start then
    conky_on_start = false
  end
end

-- Expose information to the conky config file
function conky_theme ()
  if theme == "light" then
    return "${color white}"
  elseif theme == "dark" then
    return "${color black}"
  else
    return "${color white}"
  end
end

function conky_upspeed ()
  return "${upspeedf " .. interface .. "}KiB"
end

function conky_downspeed ()
  return "${downspeedf " .. interface .. "}KiB"
end

function conky_connection ()
  if interface ~= nil and interface ~= "" then
    return "Connected " .. ip
  else
    return "Offline"
  end
end