# A monitoring resolver to resolve public network information

import requests
from util.convert import text

# Returns a data object populated with public network data
def resolve ():
  try:
    # Resolve the public address via the ident API
    response = requests.get('https://ident.me/', timeout=2)

    if response.status_code == 200:
      ip = response.text
    else:
      ip = None
  except Exception:
    ip = None

  data = {
    'ip': text(ip)
  }

  return data