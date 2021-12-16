# A lib module resolving system thermals

import statistics
import psutil
import GPUtil
from convert import decimal

data = {}

# Returns thermal data for the cpu and gpu
def resolve ():
  # Read any thermal sensor
  thermals = psutil.sensors_temperatures()

  # Extract only thermals matching k10temp cpu sensors
  thermals = thermals['k10temp']

  if not thermals:
    raise Exception('unable to resolve cpu thermals via psutil')

  temps = []

  # Collect thermal data from only cpu dies
  for thermal in thermals:
    if thermal.label == 'Tdie':
      temps.append(thermal.current)
  
  if not len(temps) > 0:
    raise Exception('unable to resolve cpu thermals via psutil')

  # Reduce temperatures down to the mean average
  temp = statistics.mean(temps)

  data['cpu'] = decimal(temp, 1)

  # Read gpu thermals
  gpu = GPUtil.getGPUs()[0]

  temp = gpu.temperature

  data['gpu'] = decimal(temp, 1)

  return data