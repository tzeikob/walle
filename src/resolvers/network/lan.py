# A monitoring resolver to resolve lan network information

from datetime import datetime
import subprocess
import psutil
from util.convert import text, integer, decimal, MB, Mb

# Last date time since the last call
last = datetime.now()

# Sent and recv bytes since the last call
last_sent = 0
last_recv = 0

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

  sent = io.bytes_sent
  recv = io.bytes_recv

  # Calculate the secs past since the last call
  now = datetime.now()

  global last
  past_secs = (now - last).total_seconds()

  # Save last checkpoint for the next call
  last = now

  # Calculate current download and upload speeds
  global last_sent, last_recv

  # Report zero up speed in case of invalid sent values
  if last_sent == 0 or last_sent >= sent or past_secs <= 0:
    up_speed = 0
  else:
    delta = sent - last_sent
    up_speed = delta / past_secs

  # Report zero down speed in case of invalid recv values
  if last_recv == 0 or last_recv >= recv or past_secs <= 0:
    down_speed = 0
  else:
    delta = recv - last_recv
    down_speed = delta / past_secs

  # Save last sent and recv bytes for the next call
  last_sent = sent
  last_recv = recv

  data = {
    'up': up,
    'name': text(name),
    'ip': text(ip),
    'sent': integer(MB(sent)),
    'recv': integer(MB(recv)),
    'upspeed': decimal(Mb(up_speed), 2),
    'downspeed': decimal(Mb(down_speed), 2)
  }

  return data