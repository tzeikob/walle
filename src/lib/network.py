# A lib module resolving network data and status

from datetime import datetime
import subprocess
import psutil
import requests
import units

# Sent and recv bytes since the last call
last_sent = None
last_recv = None

# Last date time since the last call
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
    return { 'up': False }

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
  now = datetime.now()
  past_secs = (now - last).total_seconds()

  # Save last checkpoint for the next call
  last = now

  # Calculate current download and upload speeds
  global last_sent, last_recv

  if not last_sent and not last_recv:
    up_speed = 0
    down_speed = 0
  else:
    delta = units.Mb(sent - last_sent)
    up_speed = round(delta / past_secs, 2)

    delta = units.Mb(recv - last_recv)
    down_speed = round(delta / past_secs, 2)
  
  # Save last sent and recv bytes for the next call
  last_sent = sent
  last_recv = recv

  # Convert bytes to megabytes
  sent = round(units.MB(sent))
  recv = round(units.MB(recv))

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