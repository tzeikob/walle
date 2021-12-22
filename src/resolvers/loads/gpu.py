# A monitoring resolver to resolve gpu loads

import GPUtil
from convert import integer, decimal

# Returns a data object populated with gpu load attributes
def resolve ():
  # Use gputils to measure gpu utilization
  gpu = GPUtil.getGPUs()[0]

  utilization = gpu.load * 100
  used = gpu.memoryUsed
  free = gpu.memoryFree

  data = {
    'util': decimal(utilization, 1),
    'used': integer(used),
    'free': integer(free)
  }

  return data