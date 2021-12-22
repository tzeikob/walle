# A hardware resolver to resolve gpu information

import GPUtil
from convert import text, integer

# Returns a data object populated with gpu attributes
def resolve ():
  # Use gputil to read gpu information
  gpu = GPUtil.getGPUs()[0]

  name = gpu.name
  memory = gpu.memoryTotal

  data = {
    'name': text(name),
    'memory': integer(memory)
  }

  return data