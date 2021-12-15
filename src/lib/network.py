# A lib module resolving network data and status

from datetime import datetime
import subprocess
import psutil
import requests
from convert import text, integer, decimal, MB, Mb

data = {}

# Sent and recv bytes since the last call
last_sent = 0
last_recv = 0

# Last date time since the last call
last = datetime.now()

# Returns network and connection data
def resolve ():
  # Read network name and local ip via ip route
  route = subprocess.run(
    ['ip', 'route', 'get', '8.8.8.8'],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    universal_newlines=True)

  # Return with network marked as down if stderr exists
  if route.stderr:
    data['up'] = False

    return data

  if not route.stdout:
    raise Exception('unable to resolve network data via ip route')

  # Mark network status as up
  data['up'] = True

  # Extract network name and local ip address
  parts = route.stdout.split()
  nic = parts[4]
  ip = parts[6]

  data['name'] = text(nic)
  data['lip'] = text(ip)

  # Read network sent and received bytes
  io = psutil.net_io_counters(pernic=True)[nic]

  sent = io.bytes_sent
  recv = io.bytes_recv

  # Calculate the secs past since the last call
  global last
  now = datetime.now()
  past_secs = (now - last).total_seconds()

  # Save last checkpoint for the next call
  last = now

  # Calculate current download and upload speeds
  global last_sent, last_recv

  # Report zero up speed in case of invalid sent value
  if last_sent >= sent or past_secs <= 0:
    up_speed = 0
  else:
    delta = sent - last_sent
    up_speed = delta / past_secs

  # Report zero down speed in case of invalid recv value
  if last_recv >= recv or past_secs <= 0:
    down_speed = 0
  else:
    delta = recv - last_recv
    down_speed = delta / past_secs

  # Save last sent and recv bytes for the next call
  last_sent = sent
  last_recv = recv

  data['sent'] = integer(MB(sent))
  data['recv'] = integer(MB(recv))
  data['upspeed'] = decimal(Mb(up_speed), 2)
  data['downspeed'] = decimal(Mb(down_speed), 2)

  try:
    # Resolve the public address via the ident API
    response = requests.get('https://ident.me/', timeout=2)

    if response.status_code == 200:
      public_ip = response.text
    else:
      public_ip = None
  except Exception:
    public_ip = None

  data['pip'] = text(public_ip)

  return data