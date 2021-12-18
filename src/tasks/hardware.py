# A resolver module task resolving hardware meta data

import subprocess
import re
import psutil
import GPUtil
from convert import text, integer, decimal

data = {}

# Returns meta data for the mobo, cpu and gpu
def resolve ():
  # Read motherboard data via sys/devices
  with open('/sys/devices/virtual/dmi/id/board_name') as board_file:
    name = board_file.readline()

  data['mobo'] = {
    'name': text(name)
  }

  # Read cpu data via lscpu and psutil
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

  cores = psutil.cpu_count(logical=False)
  threads = psutil.cpu_count(logical=True)

  data['cpu'] = {
    'name': text(name),
    'arch': text(arch),
    'endian': text(endian),
    'clock': decimal(clock, 0),
    'cores': integer(cores),
    'threads': integer(threads)
  }

  # Read gpu data via gputils
  gpu = GPUtil.getGPUs()[0]

  name = gpu.name
  memory = gpu.memoryTotal

  data['gpu'] = {
    'name': text(name),
    'memory': integer(memory)
  }

  return data