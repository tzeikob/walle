-- A lua module to encapsulate the context lua script

format = require "format"

-- Initialize some state variables
status = "init"
loop = 0

-- Initialize the interpolation variables
vars = {}

-- Maps static configuration data into the vars
function map_config (data)
  vars["head_line"] = data["head"]

  vars["theme_color"] = "white"
  if data["theme"]["mode"] == "dark" then
    vars["theme_color"] = "black"
  end

  vars["font_name"] = "DejaVu Sans Mono"
  vars["font_bold"] = false
  vars["font_italic"] = false
  vars["font_size"] = 12
  
  local font = data["theme"]["font"]

  local parts = format.split (font, ":")
  for _, part in ipairs (parts) do
    if format.matches (part, "bold") then
      vars["font_bold"] = true
    elseif format.matches (part, "italic") then
      vars["font_italic"] = true
    elseif format.matches (part, "size=.+") then
      local size = format.split (part, "=")[2]
      vars["font_size"] = tonumber (size)
    elseif part ~= "" then
      vars["font_name"] = part
    end
  end

  return vars
end

-- Maps hardware data into the vars
function map_hardware (data)
  -- Read memory speed data
  vars["mem_speed"] = data["memory"]["speed"]

  return vars
end

-- Maps release data into the vars
function map_release (data)
  -- Read the release name and codename
  vars["rls_name"] = data["name"]
  vars["rls_codename"] = data["codename"]
  vars["rls_version"] = data["version"]

  return vars
end

-- Maps login data into the vars
function map_login (data)
  -- Read logged in user name and host
  vars["user"] = data["user"]
  vars["host"] = data["host"]

  return vars
end

-- Maps monitoring data into the vars
function map_monitor (data)
  -- Read cpu load and thermals
  vars["cpu_util"] = data["loads"]["cpu"]["util"]
  vars["cpu_clock"] = data["loads"]["cpu"]["clock"]
  vars["cpu_temp"] = data["thermals"]["cpu"]

  -- Read gpu load and thermals
  vars["gpu_util"] = data["loads"]["gpu"]["util"]
  vars["gpu_used"] = data["loads"]["gpu"]["used"]
  vars["gpu_temp"] = data["thermals"]["gpu"]

  -- Read memory utilization and usage
  vars["mem_util"] = data["loads"]["memory"]["util"]
  vars["mem_used"] = data["loads"]["memory"]["used"]
  vars["mem_free"] = data["loads"]["memory"]["free"]

  -- Read disk load and io counters
  vars["disk_util"] = data["loads"]["disk"]["util"]
  vars["disk_read"] = data["loads"]["disk"]["read"]
  vars["disk_write"] = data["loads"]["disk"]["write"]

  -- Read network state and usage
  vars["net_up"] = data["network"]["up"]
  vars["net_name"] = data["network"]["name"]
  vars["net_up_speed"] = data["network"]["upspeed"]
  vars["net_down_speed"] = data["network"]["downspeed"]
  vars["net_sent_bytes"] = data["network"]["sent"]
  vars["net_recv_bytes"] = data["network"]["recv"]
  vars["lan_ip"] = data["network"]["lip"]
  vars["public_ip"] = data["network"]["pip"]

  return vars
end

-- Maps dynamic timing data
function map_timings (data)
  -- Convert data to number
  local secs = tonumber (format.split (data, " ")[1])

  -- Calculate how many hours
  local hours = math.floor (secs / 3600)
  if hours > 0 then
    secs = secs - (hours * 3600)
  end

  -- Calculate how many mins
  local mins = math.floor (secs / 60)
  if mins > 0 then
    secs = secs - (mins * 60)
  end

  -- Floor down to the remaining secs
  secs = math.floor (secs)

  local hours = string.format ("%02d", hours)
  local mins = string.format ("%02d", mins)
  local secs = string.format ("%02d", secs)

  vars["uptime"] = hours .. ":" .. mins .. ":" .. secs

  return vars
end

return {
  status = status,
  loop = loop,
  vars = vars,
  config = {
    load = map_config
  },
  hardware = {
    load = map_hardware
  },
  release = {
    load = map_release
  },
  login = {
    load = map_login
  },
  monitor = {
    load = map_monitor
  },
  timings = {
    load = map_timings
  }
}