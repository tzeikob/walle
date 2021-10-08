-- Main lua file for the conky config file

conky_on_start = true

interface = ""
ip = ""

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

-- Executes an operation after the given cycles have passed
function executeEvery (cycles, updates, operation)
	timer = (updates % cycles)

	if timer == 0 or conky_on_start then
    operation ()
	end
end

-- Resolves the current network interface and IP
function resolveConnection ()
  local file = io.popen ("ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}' ")
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

-- Expose data and variables into the config file
function conky_interface () return interface end
function conky_ip () return ip end

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