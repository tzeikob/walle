# A monitoring resolver to resolve cpu loads

import psutil
from util.convert import integer, decimal

# Returns a data object populated with cpu load attributes
def resolve ():
  # Use psutil to read cpu utilization
  utilization = psutil.cpu_percent()
  clock = psutil.cpu_freq().current

  data = {
    'util': decimal(utilization, 1),
    'clock': integer(clock)
  }

  return data