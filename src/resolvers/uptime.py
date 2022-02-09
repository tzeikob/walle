# An asynchronous resolver to read the system uptime

import ctypes
import struct
import math
import threading
import time
from util.convert import integer

# Load native c libraries
libc = ctypes.CDLL('libc.so.6')
buf = ctypes.create_string_buffer(4096)

state = {
  'up': False,
  'data': {
    'hours': 0,
    'mins': 0,
    'secs': 0
  }
}

def callback ():
  while state['up']:
    if libc.sysinfo(buf) == 0:
      secs = struct.unpack_from('@l', buf.raw)[0]
    else:
      # Fallback to the proc file in case libc has failed
      with open('/proc/uptime') as uptime_file:
        secs = float(uptime_file.readline().split()[0])

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

    state['data']['hours'] = integer(hours)
    state['data']['mins'] = integer(mins)
    state['data']['secs'] = integer(secs)

    time.sleep(1)

def stop ():
  state['up'] = False

def start ():
  state['up'] = True
  thread.start()

thread = threading.Thread(target=callback, daemon=True)