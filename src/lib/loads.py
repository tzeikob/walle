# A lib module resolving system loads

import psutil
import GPUtil
from convert import integer, decimal, MB

data = {}

# Returns loads for the cpu, memory, gpu and disk
def resolve ():
  # Read cpu utilization
  utilization = psutil.cpu_percent()
  clock = psutil.cpu_freq().current

  data['cpu'] = {
    'util': decimal(utilization, 1),
    'clock': integer(clock)
  }

  # Read memory utilization
  mem = psutil.virtual_memory()

  utilization = mem.percent
  used = mem.used
  free = mem.available

  data['memory'] = {
    'util': decimal(utilization, 1),
    'used': integer(MB(used)),
    'free': integer(MB(free))
  }

  # Measure gpu utilization
  gpu = GPUtil.getGPUs()[0]

  utilization = gpu.load * 100
  used = gpu.memoryUsed
  free = gpu.memoryFree

  data['gpu'] = {
    'util': decimal(utilization, 1),
    'used': integer(used),
    'free': integer(free)
  }

  # Measure disk utilization
  disk = psutil.disk_usage('/')

  utilization = disk.percent
  used = disk.used
  free = disk.free

  io = psutil.disk_io_counters()

  read = io.read_bytes
  write = io.write_bytes

  data['disk'] = {
    'util': decimal(utilization, 1),
    'used': integer(MB(used)),
    'free': integer(MB(free)),
    'read': integer(MB(read)),
    'write': integer(MB(write))
  }

  return data