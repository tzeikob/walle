# A hardware resolver to resolve cpu information

import subprocess
import re
import psutil
from convert import text, integer, decimal

# Returns a data object populated with cpu attributes
def resolve ():
  # Use lscpu to extract cpu information
  lscpu = subprocess.run(
    ['lscpu'],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    universal_newlines=True)

  if lscpu.stderr:
    raise Exception(f'unable to read cpu data via lscpu: {lscpu.stderr}')

  if not lscpu.stdout:
    raise Exception('unable to read cpu data via lscpu')

  # Extract various cpu attributes
  name = arch = endian = clock = None

  for line in lscpu.stdout.split('\n'):
    if 'Model name' in line:
      name = re.sub('.*Model name.*:', '', line, 1)
    elif 'Architecture' in line:
      arch = re.sub('.*Architecture.*:', '', line, 1)
    elif 'Byte Order' in line:
      endian = re.sub('.*Byte Order.*:', '', line, 1)
    elif 'CPU max MHz' in line:
      clock = re.sub('.*CPU max MHz.*:', '', line, 1)

  # Use psutil to read other cpu attributes
  cores = psutil.cpu_count(logical=False)
  threads = psutil.cpu_count(logical=True)

  data = {
    'name': text(name),
    'arch': text(arch),
    'endian': text(endian),
    'clock': decimal(clock, 0),
    'cores': integer(cores),
    'threads': integer(threads)
  }

  return data