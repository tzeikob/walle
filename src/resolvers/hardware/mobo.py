# A hardware resolver to resolve motherboard information

from convert import text

# Returns a data object populated with motherboard attributes
def resolve ():
  # Read motherboard data via sys/devices
  with open('/sys/devices/virtual/dmi/id/board_name') as board_file:
    name = board_file.readline()

  data = {
    'name': text(name)
  }

  return data