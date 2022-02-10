# An asynchronous resolver to monitoring network information

import threading
import time
import subprocess
import psutil
from util.meter import Meter
from util.convert import text, integer, decimal, MB, Mb

# Initialize upload and download speedometers
bytes_sent = Meter()
bytes_recv = Meter()
packets_sent = Meter()
packets_recv = Meter()

state = {
  'up': False,
  'data':{
    'conn': False,
    'nic': '',
    'bytes': {
      'sent': 0,
      'recv': 0,
      'up': 0,
      'down': 0
    },
    'packets': {
      'sent': 0,
      'recv': 0,
      'up': 0,
      'down': 0
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
    
    # Consider network initially as down
    state['data']['conn'] = False
    state['data']['nic'] = ''
    state['data']['bytes']['up'] = 0
    state['data']['bytes']['down'] = 0
    state['data']['packets']['up'] = 0
    state['data']['packets']['down'] = 0

    if not route.stderr:
      # Extract network nic name
      name = route.stdout.split()[4]

      # Read network sent and received bytes
      io = psutil.net_io_counters(pernic=True)[name]

      # Update current values in speedometers
      bytes_sent.update(io.bytes_sent)
      bytes_recv.update(io.bytes_recv)
      packets_sent.update(io.packets_sent)
      packets_recv.update(io.packets_recv)

      state['data']['conn'] = True
      state['data']['nic'] = text(name)
      state['data']['bytes']['sent'] = integer(MB(bytes_sent.value))
      state['data']['bytes']['recv'] = integer(MB(bytes_recv.value))
      state['data']['bytes']['up'] = decimal(Mb(bytes_sent.speed), 2)
      state['data']['bytes']['down'] = decimal(Mb(bytes_recv.speed), 2)
      state['data']['packets']['sent'] = integer(packets_sent.value)
      state['data']['packets']['recv'] = integer(packets_recv.value)
      state['data']['packets']['up'] = decimal(packets_sent.speed, 2)
      state['data']['packets']['down'] = decimal(packets_recv.speed, 2)

    time.sleep(1)

def stop ():
  state['up'] = False

def start ():
  state['up'] = True
  thread.start()

thread = threading.Thread(target=callback, daemon=True)