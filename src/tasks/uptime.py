# A resolver module task resolving the current uptime

import ctypes
import struct
import math
from convert import integer

data = {}

# Load native c libraries
libc = ctypes.CDLL('libc.so.6')
buf = ctypes.create_string_buffer(4096)

# Returns the current uptime in hours, mins and secs
def resolve ():
  if libc.sysinfo(buf) == 0:
    secs = struct.unpack_from('@l', buf.raw)[0]
  else:
    # Otherwise fallback to the proc file
    with open('/proc/uptime') as uptime_file:
      secs = float(uptime_file.readline().split()[0])

  if not isinstance(secs, (int, float)):
    raise Exception(f'uptime resolved to a non numeric value: {secs}')

  if secs < 0:
    raise Exception(f'uptime resolved to a negative value: {secs}')

  # Calculate how many hours
  hours = math.floor (secs / 3600)
  if hours > 0:
    secs = secs - (hours * 3600)

  # Calculate how many mins
  mins = math.floor (secs / 60)
  if mins > 0 :
    secs = secs - (mins * 60)

  # Floor down to the remaining secs
  secs = math.floor (secs)

  data['hours'] = integer(hours)
  data['mins'] = integer(mins)
  data['secs'] = integer(secs)

  return data