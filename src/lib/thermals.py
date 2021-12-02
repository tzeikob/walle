# A lib module resolving system thermals

import statistics
import psutil
import GPUtil

# Returns thermal data for the cpu and gpu
def resolve ():
  # Extract any thermal sensor data
  thermals = psutil.sensors_temperatures()

  # Read only thermals from cpu k10temp sensors
  thermals = thermals['k10temp']

  if not thermals:
    raise Exception('unable to resolve cpu thermals')

  temps = []

  # Collect thermal data from only cpu dies
  for thermal in thermals:
    if thermal.label == 'Tdie':
      temps.append(thermal.current)
  
  if not len(temps) > 0:
    raise Exception('unable to resolve cpu thermals')

  # Reduce temperatures down to the mean average
  cpu_temp = round(statistics.mean(temps), 1)

  # Measure thermals only for nvidia gpu
  gpu = GPUtil.getGPUs()[0]

  if not gpu:
    raise Exception('unable to resolve gpu thermals')

  gpu_temp = round(gpu.temperature, 1)

  return {
    'cpu': cpu_temp,
    'gpu': gpu_temp
  }