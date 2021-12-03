# A lib module resolving hardware meta data

import subprocess
import re
import psutil
import GPUtil

# Returns metadata for the board, cpu and gpu
def resolve ():
  # Extract the name of the motherboard
  board = subprocess.run(
    ['cat', '/sys/devices/virtual/dmi/id/board_name'],
    stdout=subprocess.PIPE,
    universal_newlines=True)

  if not board.stdout:
    raise Exception('unable to resolve motherboard data')

  board = board.stdout.lower().strip() if board.stdout else None

  # Extract the cpu info with lscpu
  lscpu = subprocess.run(
    ['lscpu'],
    stdout=subprocess.PIPE,
    universal_newlines=True)

  if not lscpu.stdout:
    raise Exception('unable to resolve cpu data')

  # Match the model name of the cpu
  for line in lscpu.stdout.split('\n'):
    if 'Model name' in line:
      cpu_name = re.sub('.*Model name.*:', '', line, 1)
    elif 'Architecture' in line:
      cpu_arch = re.sub('.*Architecture.*:', '', line, 1)
    elif 'Byte Order' in line:
      cpu_endian = re.sub('.*Byte Order.*:', '', line, 1)
    elif 'CPU max MHz' in line:
      cpu_clock = re.sub('.*CPU max MHz.*:', '', line, 1)

  cpu_name = cpu_name.lower().strip() if cpu_name else None
  cpu_arch = cpu_arch.lower().strip() if cpu_arch else None
  cpu_endian = cpu_endian.lower().strip() if cpu_endian else None
  cpu_clock = round(float(cpu_clock)) if cpu_clock else None

  # Use psutil to get cpu cores and threads
  cpu_cores = psutil.cpu_count(logical=False)
  cpu_threads = psutil.cpu_count(logical=True)

  # Extract gpu meta data
  gpu = GPUtil.getGPUs()[0]

  if not gpu:
    raise Exception('unable to resolve gpu data')

  gpu_name = gpu.name.lower().strip() if gpu.name else None
  gpu_memory = round(gpu.memoryTotal) if gpu.memoryTotal else None

  return {
    'board': board,
    'cpu': {
      'name': cpu_name,
      'arch': cpu_arch,
      'endian': cpu_endian,
      'cores': cpu_cores,
      'threads': cpu_threads,
      'clock': cpu_clock
    },
    'gpu': {
      'name': gpu_name,
      'memory': gpu_memory
    }
  }