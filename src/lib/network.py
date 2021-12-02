# A lib module resolving network data and status

import subprocess
import math
import psutil
import requests

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

  sent = math.floor(io.bytes_sent / (1024 * 1024))
  received = math.floor(io.bytes_recv / (1024 * 1024))

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
    'recv': received
  }