# A lib module resolving system loads

import math
import psutil
import GPUtil

# Returns loads for the cpu, memory, gpu and disk
def resolve ():
  # Measure cpu utilization
  cpu_clock = math.floor(psutil.cpu_freq().current)
  cpu_util = psutil.cpu_percent()

  # Measure memory utilization
  mem = psutil.virtual_memory()

  if not mem:
    raise Exception('unable to resolve memory data')

  mem_util = mem.percent
  mem_used = math.floor(mem.used / (1024 * 1024))
  mem_free = math.floor(mem.available / (1024 * 1024))

  # Measure gpu utilization
  gpu = GPUtil.getGPUs()[0]

  if not gpu:
    raise Exception('unable to resolve gpu data')

  gpu_util = round(gpu.load * 100, 1)
  gpu_mem_used = math.floor(gpu.memoryUsed)
  gpu_mem_free = math.floor(gpu.memoryFree)

  # Measure disk utilization
  disk = psutil.disk_usage('/')

  if not disk:
    raise Exception('unable to resolve disk data')

  disk_util = disk.percent
  disk_used = math.floor(disk.used / (1024 * 1024))
  disk_free = math.floor(disk.free / (1024 * 1024))

  io = psutil.disk_io_counters()

  if not io:
    raise Exception('unable to resolve disk io data')

  disk_read = math.floor(io.read_bytes / (1024 * 1024))
  disk_write = math.floor(io.write_bytes / (1024 * 1024))

  return {
    'cpu': {
      'clock': cpu_clock,
      'util': cpu_util
    },
    'memory': {
      'util': mem_util,
      'used': mem_used,
      'free': mem_free
    },
    'gpu': {
      'util': gpu_util,
      'mem_used': gpu_mem_used,
      'mem_free': gpu_mem_free
    },
    'disk': {
      'util': disk_util,
      'used': disk_used,
      'free': disk_free,
      'read': disk_read,
      'write': disk_write
    }
  }