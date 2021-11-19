-- A lua library for various system and os native operations

util = require "util"
json = require "cjson"

-- Returns information of the release
function release ()
  local lsb_release = "lsb_release --short -icr"
  lsb_release = util.split (util.exec (lsb_release), "\n")

  local uname = "uname -p | sed -z '$ s/\\n$//'"
  uname = util.exec (uname)

  return {
    name = lsb_release[1],
    version = lsb_release[2],
    codename = lsb_release[3],
    arch = uname
  }
end

-- Returns the name of the current logged in user
function user ()
  return util.exec ("echo $(whoami)")
end

-- Returns the name of the host
function hostname ()
  return util.exec ("echo $(hostname)")
end

-- Returns the network interface data
function network ()
  local result = {
    net_name = "",
    lan_ip = "",
    down_bytes = 0,
    up_bytes = 0
  }

  local route = "ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}'"
  route = util.split (util.exec (route), ",")

  if util.is_not_empty (route[1]) then
    result["net_name"] = route[1]
    result["lan_ip"] = route[2]

    local net_proc = "cat /proc/net/dev | awk '/" .. result["net_name"] .. "/ {printf \"%s %s\",  $2, $10}'"
    local bytes = util.split (util.exec (net_proc), " ")

    result["down_bytes"] = tonumber (bytes[1])
    result["up_bytes"] = tonumber (bytes[2])
  end

  return result
end

-- Returns the ISP information data
function isp ()
  local result = {
    ip = "",
    org = ""
  }

  local response = util.exec ("curl -s https://ipinfo.io/")

  if util.is_not_empty (response) then
    local status, info = pcall (function () return json.decode (response) end)

    if status then
      if util.is_not_empty (info["ip"]) then
        result["ip"] = info["ip"]
      end

      if util.is_not_empty (info["org"]) then
        result["org"] = info["org"]
      end
    end
  end

  return result
end

-- Returns the hardware info data
function hw ()
  local cpu_name = util.exec ("lscpu | grep 'Model name'")
  cpu_name = util.trim (util.split (cpu_name, ":")[2])

  local cpu_cores = util.exec ("lscpu | grep 'Core(s)'")
  cpu_cores = util.trim (util.split (cpu_cores, ":")[2])

  local cpu_freq = util.exec ("lscpu | grep 'CPU max MHz'")
  cpu_freq = util.trim (util.split (cpu_freq, ":")[2])
  cpu_freq = util.split (cpu_freq, "%.")[1]

  local mobo_name = util.exec ("cat /sys/devices/virtual/dmi/id/board_name")

  local gpu_name = ""

  local isNvidia = util.exec ("lsmod | grep nvidia_uvm")

  if util.is_not_empty (isNvidia) then
    gpu_name = util.exec ("nvidia-smi --query-gpu=gpu_name --format=csv,noheader")
  end

  return {
    cpu_name = cpu_name,
    cpu_cores = cpu_cores,
    cpu_freq = cpu_freq,
    mobo_name = mobo_name,
    gpu_name = gpu_name
  }
end

-- Returns the system thermal sensors
function thermals ()
  local result = {
    cpus = {},
    chipset = 0
  }

  -- Resolve any AMD CPU thermal values
  local index = 0
  while util.exec ("cat /sys/class/hwmon/hwmon" .. index .. "/name") == "k10temp" do
    local temp = util.exec ("cat /sys/class/hwmon/hwmon" .. index .. "/temp1_input")
    table.insert(result["cpus"], util.round (tonumber (temp) / 1000, 1))

    index = index + 1
  end

  return result
end

-- Returns the GPU data and current loads
function gpu ()
  local result = {
    name = "",
    util = 0,
    mem = 0,
    mem_util = 0,
    temp = 0
  }

  -- Check if an nvidia card is installed
  local isNvidia = util.exec ("lsmod | grep nvidia_uvm")

  if util.is_not_empty (isNvidia) then
    local opts = "gpu_name,utilization.gpu,memory.used,utilization.memory,temperature.gpu"
    local cmd = "nvidia-smi --query-gpu=" .. opts .. " --format=csv,noheader"
    local output = util.split (util.exec (cmd), ",")

    result["name"] = util.trim (output[1])
    result["util"] = util.split (util.trim (output[2]), " ")[1]
    result["mem"] = util.split (util.trim (output[3]), " ")[1]
    result["mem_util"] = util.split (util.trim (output[4]), " ")[1]
    result["temp"] = util.trim (output[5])
  end

  return result
end

-- Returns the uptime in hours, mins and secs
function uptime ()
  local output = exec ("cat /proc/uptime")
  local secs = tonumber (split (output, " ")[1])

  local hours = math.floor (secs / 3600)
  if hours > 0 then
    secs = secs - (hours * 3600)
  end

  local mins = math.floor (secs / 60)
  if mins > 0 then
    secs = secs - (mins * 60)
  end

  secs = math.floor (secs)

  return {
    hours = hours,
    mins = mins,
    secs = secs
  }
end

-- Returns a random pet name
function petname ()
  return util.cap (util.exec ("petname -w 2 -l 5 -s ' ' -c 2"))
end

return {
  release = release,
  user = user,
  hostname = hostname,
  network = network,
  isp = isp,
  hw = hw,
  thermals = thermals,
  gpu = gpu,
  uptime = uptime,
  petname = petname
}