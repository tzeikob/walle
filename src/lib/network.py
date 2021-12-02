# A lib module resolving network data and status

from datetime import datetime
import subprocess
import psutil
import requests

# Converts bytes to mbits
def to_mbits (bytes):
  return (bytes * 8) / (1024 * 1024)

# Sent and recv bytes since the last resolve call
last_sent = 0
last_recv = 0

# Last date time since the last resolve call
last = datetime.now()

# Returns network and connection data
def resolve ():
  # Use ip route to resolve if connection is up
  route = subprocess.run(
    ['ip', 'route', 'get', '8.8.8.8'],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    universal_newlines=True)

  # Return with network marked as down if stderr exists
  if route.stderr:
    return {
      'up': False,
      'name': None,
      'lip': None,
      'pip': None,
      'sent': None,
      'recv': None
    }

  if not route.stdout:
    raise Exception('unable to resolve network data')

  # Extract network name and local ip address
  parts = route.stdout.split()

  try:
    name = parts[4].strip()
    local_ip = parts[6].strip()
  except Exception as error:
    raise Exception(f'unable to resolve network data: {error}')

  # Read network sent and received bytes
  io = psutil.net_io_counters(pernic=True)[name]

  sent = io.bytes_sent
  recv = io.bytes_recv

  # Calculate the secs past since the last call
  global last
  past = (datetime.now() - last).total_seconds()

  # Update last date time for the next call
  last = datetime.now()

  # Calculate current download and upload speeds
  global last_sent, last_recv

  if last_sent == 0 and last_recv == 0:
    up_speed = 0
    down_speed = 0
  else:
    up_speed = round(to_mbits(sent - last_sent) / past, 2)
    down_speed = round(to_mbits(recv - last_recv) / past, 2)
  
  # Update the last sent and recv for the next call
  last_sent = sent
  last_recv = recv

  try:
    # Resolve the public address via the ident API
    response = requests.get('https://ident.me/', timeout=0.8)

    if response.status_code == 200:
      public_ip = response.text.strip()
    else:
      public_ip = None
  except Exception:
    public_ip = None

  return {
    'up': True,
    'name': name,
    'lip': local_ip,
    'pip': public_ip,
    'sent': sent,
    'recv': recv,
    'upspeed': up_speed,
    'downspeed': down_speed
  }