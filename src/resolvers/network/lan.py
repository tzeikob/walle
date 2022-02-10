# A monitoring resolver to resolve lan network information

import subprocess
import psutil
from util.meter import Meter
from util.convert import text, integer, decimal, MB, Mb

# Initialize upload and download speedometers
sent = Meter()
recv = Meter()

# Returns a data object populated with lan network data
def resolve ():
  # Read network name and local ip via ip route
  route = subprocess.run(
    ['ip', 'route', 'get', '8.8.8.8'],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    universal_newlines=True)

  # Return with network marked as down if stderr exists
  if route.stderr:
    return { 'up': False }

  if not route.stdout:
    raise Exception('unable to resolve network data via ip route')

  # Mark network status as up
  up = True

  # Extract network name and local ip address
  parts = route.stdout.split()
  name = parts[4]
  ip = parts[6]

  # Read network sent and received bytes
  io = psutil.net_io_counters(pernic=True)[name]

  # Update current values in speedometers
  sent.update(io.bytes_sent)
  recv.update(io.bytes_recv)

  data = {
    'up': up,
    'name': text(name),
    'ip': text(ip),
    'sent': integer(MB(sent.value)),
    'recv': integer(MB(recv.value)),
    'upspeed': decimal(Mb(sent.speed), 2),
    'downspeed': decimal(Mb(recv.speed), 2)
  }

  return data