-- A lua library for various system and os native operations

util = require "util"

-- Returns information of the release
function release ()
  local lsb_release = "lsb_release --short -icr"
  lsb_release = util.split (util.exec (lsb_release), "\n")

  uname = "uname -p | sed -z '$ s/\\n$//'"
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
    net_name = "n/a",
    lan_ip = "x.x.x.x",
    net_ip = "x.x.x.x",
    down_bytes = 0,
    up_bytes = 0
  }

  local route = "ip route get 8.8.8.8 | awk -- '{printf \"%s,%s\", $5, $7}'"
  route = util.split (util.exec (route), ",")

  if route[1] ~= nil and route[1] ~= "" then
    result["net_name"] = route[1]
    result["lan_ip"] = route[2]

    local dig = "dig +short myip.opendns.com @resolver1.opendns.com"
    local net_ip = util.exec (dig)

    if net_ip ~= nil and net_ip ~= "" then
      result["net_ip"] = net_ip
    end

    local net_proc = "cat /proc/net/dev | awk '/" .. result["net_name"] .. "/ {printf \"%s %s\",  $2, $10}'"
    local bytes = util.split (util.exec (net_proc), " ")

    result["down_bytes"] = util.round (tonumber (bytes[1]) / (1024 * 1024 * 1024), 1)
    result["up_bytes"] = util.round (tonumber (bytes[2]) / (1024 * 1024 * 1024), 1)
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
  if isNvidia ~= nil and isNvidia ~= "" then
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

-- Returns a random pet name
function petname ()
  util.cap (util.exec ("petname -w 2 -l 5 -s ' ' -c 2"))
end

return {
  release = release,
  user = user,
  hostname = hostname,
  network = network,
  hw = hw,
  petname = petname
}