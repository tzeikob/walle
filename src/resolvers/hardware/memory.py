# A hardware resolver to resolve memory information

import subprocess
import re
from util.convert import decimal

# Returns a data object populated with memory attributes
def resolve ():
  # Use dmidecode to read memory information
  dmi = subprocess.run(
    ['sudo', 'dmidecode', '-t', 'memory'],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    universal_newlines=True)

  if dmi.stderr:
    raise Exception(f'unable to read memory data via dmidecode: {dmi.stderr}')

  if not dmi.stdout:
    raise Exception('unable to read memory data via dmidecode')

  # Extract the configurable memory speed
  speed = None

  # Stop at the first match
  for line in dmi.stdout.split('\n'):
    matches = re.findall('.*Configured Clock Speed:.* (\d{2,}) .*', line)

    if len(matches) > 0:
      speed = matches[0]
      break

  data = {
    'speed': decimal(speed, 0)
  }

  return data