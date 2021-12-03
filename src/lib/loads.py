# A lib module resolving system loads

import psutil
import GPUtil
import units

# Returns loads for the cpu, memory, gpu and disk
def resolve ():
  # Measure cpu utilization
  cpu_clock = round(psutil.cpu_freq().current)
  cpu_util = round(psutil.cpu_percent(), 1)

  # Measure memory utilization
  mem = psutil.virtual_memory()

  if not mem:
    raise Exception('unable to resolve memory data')

  mem_util = round(mem.percent, 1)
  mem_used = round(units.MB(mem.used))
  mem_free = round(units.MB(mem.available))

  # Measure gpu utilization
  gpu = GPUtil.getGPUs()[0]

  if not gpu:
    raise Exception('unable to resolve gpu data')

  gpu_util = round(gpu.load * 100, 1)
  gpu_mem_used = round(gpu.memoryUsed)
  gpu_mem_free = round(gpu.memoryFree)

  # Measure disk utilization
  disk = psutil.disk_usage('/')

  if not disk:
    raise Exception('unable to resolve disk data')

  disk_util = round(disk.percent, 1)
  disk_used = round(units.MB(disk.used))
  disk_free = round(units.MB(disk.free))

  io = psutil.disk_io_counters()

  if not io:
    raise Exception('unable to resolve disk io data')

  disk_read = round(units.MB(io.read_bytes))
  disk_write = round(units.MB(io.write_bytes))

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