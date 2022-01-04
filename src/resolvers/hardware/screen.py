# A hardware resolver to resolve screen information

import screeninfo
from util.convert import integer

# Returns a data object populated with screen info
def resolve ():
  # Read primary screen resolution
  width = height = 0

  for monitor in screeninfo.get_monitors():
    if monitor.is_primary:
      width = monitor.width
      height = monitor.height

  data = {
    'width': integer(width),
    'height': integer(height)
  }

  return data