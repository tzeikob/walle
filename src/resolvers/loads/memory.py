# A monitoring resolver to resolve memory loads

import psutil
from convert import integer, decimal, MB

# Returns a data object populated with memory load attributes
def resolve ():
  # Use psutil to read memory utilization
  mem = psutil.virtual_memory()

  utilization = mem.percent
  used = mem.used
  free = mem.available

  data = {
    'util': decimal(utilization, 1),
    'used': integer(MB(used)),
    'free': integer(MB(free))
  }

  return data