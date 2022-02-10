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

      # Map io network counters per nic in the system
      counters = psutil.net_io_counters(pernic=True)

      # Iterate through each nic and aggregate bytes and packets
      bytes_sent = 0
      bytes_recv = 0
      packets_sent = 0
      packets_recv = 0

      for nic in counters:
        io = counters[nic]

        bytes_sent += io.bytes_sent
        bytes_recv += io.bytes_recv
        packets_sent += io.packets_sent
        packets_recv += io.packets_recv

      state['data']['bytes']['sent'] = integer(MB(bytes_sent))
      state['data']['bytes']['recv'] = integer(MB(bytes_recv))
      state['data']['packets']['sent'] = integer(packets_sent)
      state['data']['packets']['recv'] = integer(packets_recv)
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