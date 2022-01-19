-- A lua module to encapsulate the context lua script

local util = require "util"
local format = require "format"

-- Initialize some state variables
local state = {
  phase = "init",
  loop = 0
}

-- Initialize the interpolation variables
local vars = {}

-- Maps static configuration data into the vars
function map_config (data)
  vars["head_line"] = data["head"]

  vars["theme_color"] = "white"
  if data["theme"]["mode"] == "dark" then
    vars["theme_color"] = "black"
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
  vars["cpu_temp"] = data["thermals"]["cpu"]["mean"]

  -- Read gpu load and thermals
  vars["gpu_util"] = data["loads"]["gpu"]["util"]
  vars["gpu_used"] = data["loads"]["gpu"]["used"]
  vars["gpu_temp"] = data["thermals"]["gpu"]["chip"]

  -- Read memory utilization and usage
  vars["mem_util"] = data["loads"]["memory"]["util"]
  vars["mem_used"] = data["loads"]["memory"]["used"]
  vars["mem_free"] = data["loads"]["memory"]["free"]

  -- Read disk load and io counters
  if util.given (data["loads"]["disk"]["/"]) then
    vars["disk_root_util"] = data["loads"]["disk"]["/"]["util"]
    vars["disk_root_used"] = data["loads"]["disk"]["/"]["used"]
    vars["disk_root_free"] = data["loads"]["disk"]["/"]["free"]
    vars["disk_root_type"] = data["loads"]["disk"]["/"]["type"]
  end

  if util.given (data["loads"]["disk"]["/home"]) then
    vars["disk_home_util"] = data["loads"]["disk"]["/home"]["util"]
    vars["disk_home_used"] = data["loads"]["disk"]["/home"]["used"]
    vars["disk_home_free"] = data["loads"]["disk"]["/home"]["free"]
    vars["disk_home_type"] = data["loads"]["disk"]["/home"]["type"]
  end

  vars["disk_read"] = data["loads"]["disk"]["read"]["bytes"]
  vars["disk_read_speed"] = data["loads"]["disk"]["read"]["speed"]

  vars["disk_write"] = data["loads"]["disk"]["write"]["bytes"]
  vars["disk_write_speed"] = data["loads"]["disk"]["write"]["speed"]

  -- Read network state and usage
  vars["net_up"] = data["network"]["lan"]["up"]
  vars["net_name"] = data["network"]["lan"]["name"]
  vars["net_up_speed"] = data["network"]["lan"]["upspeed"]
  vars["net_down_speed"] = data["network"]["lan"]["downspeed"]
  vars["net_sent_bytes"] = data["network"]["lan"]["sent"]
  vars["net_recv_bytes"] = data["network"]["lan"]["recv"]
  vars["lan_ip"] = data["network"]["lan"]["ip"]
  vars["public_ip"] = data["network"]["public"]["ip"]

  return vars
end

-- Maps dynamic timing data
function map_timings (data)
  -- Read uptime data
  local hours = data["uptime"]["hours"]
  local mins = data["uptime"]["mins"]
  local secs = data["uptime"]["secs"]

  hours = string.format ("%02d", hours)
  mins = string.format ("%02d", mins)
  secs = string.format ("%02d", secs)

  vars["uptime"] = hours .. ":" .. mins .. ":" .. secs

  return vars
end

return {
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
  },
  state = state,
  vars = vars
}