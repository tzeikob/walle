# A monitoring resolver to resolve cpu thermals

import statistics
import psutil
from convert import decimal

# Returns a data object populated with cpu thermal data
def resolve ():
  # Use psutil to read any thermal sensor
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
  mean = statistics.mean(temps)

  data = {
    'mean': decimal(mean, 1)
  }

  return data