# An asynchronous resolver to monitoring network information

import threading
import time
import subprocess
import psutil
from util.meter import Meter
from util.convert import text, integer, decimal, MB, Mb

# Initialize upload and download speedometers
sent = Meter()
recv = Meter()

state = {
  'up': False,
  'data':{
    'conn': False,
    'nic': '',
    'ip': '',
    'sent': 0,
    'recv': 0,
    'up': 0,
    'down': 0
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
    state['data']['ip'] = ''
    state['data']['up'] = 0
    state['data']['down'] = 0

    if not route.stderr:
      # Extract network name and local ip address
      parts = route.stdout.split()
      name = parts[4]
      ip = parts[6]

      # Read network sent and received bytes
      io = psutil.net_io_counters(pernic=True)[name]

      # Update current values in speedometers
      sent.update(io.bytes_sent)
      recv.update(io.bytes_recv)

      state['data']['conn'] = True
      state['data']['nic'] = text(name)
      state['data']['ip'] = text(ip)
      state['data']['sent'] = integer(MB(sent.value))
      state['data']['recv'] = integer(MB(recv.value))
      state['data']['up'] = decimal(Mb(sent.speed), 2)
      state['data']['down'] = decimal(Mb(recv.speed), 2)

    time.sleep(1)

def stop ():
  state['up'] = False

def start ():
  state['up'] = True
  thread.start()

thread = threading.Thread(target=callback, daemon=True)