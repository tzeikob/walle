# A resolver module task resolving system loads

from datetime import datetime
import psutil
import GPUtil
from convert import integer, decimal, MB

data = {}

# Last date time since the last call
last = datetime.now()

# Disk read and written bytes since the last call
last_hd_read = 0
last_hd_write = 0

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

  # Calculate the secs past since the last call
  global last
  now = datetime.now()
  past_secs = (now - last).total_seconds()

  # Save last checkpoint for the next call
  last = now

  # Read disk read and write io counters
  io = psutil.disk_io_counters()

  hd_read = io.read_bytes
  hd_write = io.write_bytes

    # Calculate current read and write disk speeds
  global last_hd_read, last_hd_write

  # Report zero read speed in case of invalid read values
  if last_hd_read == 0 or last_hd_read >= hd_read or past_secs <= 0:
    hd_read_speed = 0
  else:
    delta = hd_read - last_hd_read
    hd_read_speed = delta / past_secs

  # Report zero write speed in case of invalid write values
  if last_hd_write == 0 or last_hd_write >= hd_write or past_secs <= 0:
    hd_write_speed = 0
  else:
    delta = hd_write - last_hd_write
    hd_write_speed = delta / past_secs
  
  # Save last disk read and write values
  last_hd_read = hd_read
  last_hd_write = hd_write

  data['disk'] = {
    'util': decimal(utilization, 1),
    'used': integer(MB(used)),
    'free': integer(MB(free)),
    'read': {
      'bytes': integer(MB(hd_read)),
      'speed': decimal(MB(hd_read_speed), 1)
    },
    'write': {
      'bytes': integer(MB(hd_write)),
      'speed': decimal(MB(hd_write_speed), 1)
    }
  }

  return data