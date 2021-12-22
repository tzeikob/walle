# A monitoring resolver to resolve gpu thermals

import GPUtil
from util.convert import decimal

# Returns a data object populated with gpu thermal data
def resolve ():
  # Use gputil to read gpu thermals
  gpu = GPUtil.getGPUs()[0]

  temp = gpu.temperature

  data = {
    'chip': decimal(temp, 1)
  }

  return data