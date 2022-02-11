# An asynchronous resolver to monitoring network information

import threading
import time
import subprocess
import psutil
from util.convert import text, integer, MB

state = {
  'up': False,
  'data':{
    'conn': False,
    'nic': '',
    'bytes': {
      'sent': 0,
      'recv': 0
    },
    'packets': {
      'sent': 0,
      'recv': 0
    }
  }
}

def callback ():
  while state['up']:
    # Read network name and local ip via ip route
    route = subprocess.run(
      ['ip', 'route', 'get', '8.8.8.8'],
      stdout=subprocess.PIPE,
      stderr=subprocess.PIPE,
      universal_newlines=True)

    if not route.stderr:
      # Extract the name of the active network interface
      name = route.stdout.split()[4]

      state['data']['conn'] = True
      state['data']['nic'] = text(name)

      # Read system-wide io counters
      io = psutil.net_io_counters(pernic=False)

      state['data']['bytes']['sent'] = integer(MB(io.bytes_sent))
      state['data']['bytes']['recv'] = integer(MB(io.bytes_recv))
      state['data']['packets']['sent'] = integer(io.packets_sent)
      state['data']['packets']['recv'] = integer(io.packets_recv)
    else:
      state['data']['conn'] = False
      state['data']['nic'] = ''

    time.sleep(1)

def stop ():
  state['up'] = False

def start ():
  state['up'] = True
  thread.start()

thread = threading.Thread(target=callback, daemon=True)