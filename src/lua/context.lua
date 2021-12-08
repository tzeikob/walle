-- A lua module to encapsulate the context lua script

text = require "text"

-- Initialize some state variables
status = "init"
loop = 0

-- Initialize the interpolation variables
vars = {}

-- Maps static configuration data into the vars
function map_static (data)
  vars["head"] = data["head"]

  vars["mode"] = "white"
  if data["theme"]["mode"] == "dark" then
    vars["mode"] = "black"
  end

  vars["font_name"] = "DejaVu Sans Mono"
  vars["font_bold"] = false
  vars["font_italic"] = false
  vars["font_size"] = 12
  
  local font = data["theme"]["font"]

  local parts = text.split (font, ":")
  for _, part in ipairs (parts) do
    if text.matches (part, "bold") then
      vars["font_bold"] = true
    elseif text.matches (part, "italic") then
      vars["font_italic"] = true
    elseif text.matches (part, "size=.+") then
      local size = text.split (part, "=")[2]
      vars["font_size"] = tonumber (size)
    elseif part ~= "" then
      vars["font_name"] = part
    end
  end

  return vars
end

-- Maps dynamic system data into the vars
function map_dynamic (data)
  vars["user"] = data["login"]["user"]
  vars["hostname"] = data["login"]["host"]
  vars["rls_name"] = data["release"]["name"]
  vars["rls_codename"] = data["release"]["codename"]
  vars["cpu_load"] = data["loads"]["cpu"]["util"]
  vars["mem_load"] = data["loads"]["memory"]["util"]
  vars["disk_load"] = data["loads"]["disk"]["util"]
  vars["cpu_temp"] = data["thermals"]["cpu"]
  vars["gpu_util"] = data["loads"]["gpu"]["util"]
  vars["gpu_mem"] = data["loads"]["gpu"]["used"]
  vars["gpu_temp"] = data["thermals"]["gpu"]
  vars["net_name"] = data["network"]["name"]
  vars["lan_ip"] = data["network"]["lip"]
  vars["public_ip"] = data["network"]["pip"]
  vars["up_mbytes"] = data["network"]["sent"]
  vars["down_mbytes"] = data["network"]["recv"]
  vars["up_speed"] = data["network"]["upspeed"]
  vars["down_speed"] = data["network"]["downspeed"]

  local hours = string.format ("%02d", data["uptime"]["hours"])
  local mins = string.format ("%02d", data["uptime"]["mins"])
  local secs = string.format ("%02d", data["uptime"]["secs"])

  vars["uptime"] = hours .. ":" .. mins .. ":" .. secs

  return vars
end

return {
  status = status,
  loop = loop,
  vars = vars,
  static = {
    load = map_static
  },
  dynamic = {
    load = map_dynamic
  }
}