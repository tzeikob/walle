# A lib module resolving the current uptime

import ctypes
import struct
import math

# Load native c libraries
libc = ctypes.CDLL('libc.so.6')

# Initialize the buffer
buf = ctypes.create_string_buffer(4096)

# Returns the current uptime in hours, mins and secs
def resolve ():
  try:
    if libc.sysinfo(buf) == 0:
      secs = struct.unpack_from('@l', buf.raw)[0]
    else:
      # Otherwise try to read the proc file
      with open('/proc/uptime') as uptime_file:
        secs = float(uptime_file.readline().split()[0])
  except Exception:
    return None

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

  return {
    "hour": hours,
    "mins": mins,
    "secs": secs
  }