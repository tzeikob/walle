# A monitoring resolver to resolve disk loads

import psutil
from util.meter import Meter
from util.convert import integer, decimal, MB

# Initialize read and write speedometers
read = Meter()
write = Meter()

# Returns a data object populated with disk load data
def resolve ():
  io = psutil.disk_io_counters()

  # Update current value in speedometers
  read.update(io.read_bytes)
  write.update(io.write_bytes)

  data = {
    'read': {
      'bytes': integer(MB(read.value)),
      'speed': decimal(MB(read.speed), 1)
    },
    'write': {
      'bytes': integer(MB(write.value)),
      'speed': decimal(MB(write.speed), 1)
    }
  }

  return data