# A module exporting utility methods to manage conky

import os
import re
import screeninfo
from common import globals

# Writes the given settings to the conkyrc file
def config (settings):
  if not os.path.exists(globals.CONKYRC_FILE_PATH):
    raise Exception('[Errno 2] Conkyrc file not found')

  newContent = ''

  with open(globals.CONKYRC_FILE_PATH, 'r') as conkyrc_file:
    for line in conkyrc_file:
      for key in settings:
        if re.match(r'^[ ]*{}[ ]*=[ ]*.+,[ ]*$'.format(key), line):
          value = settings[key]

          if type(value) is str:
            value = "'" + value + "'"

          line = '    ' + key + ' = ' + str(value) + ',\n'

      newContent += line

  with open(globals.CONKYRC_FILE_PATH, 'w') as conkyrc_file:
    conkyrc_file.write(newContent)

# Initializes various conky settings
def init ():
  # Resolve primary monitor resolution
  width = height = 0

  for monitor in screeninfo.get_monitors():
    if monitor.is_primary:
      width = monitor.width
      height = monitor.height

  config({
    'maximum_width': width,
    'minimum_width': width,
    'minimum_height': height
  })

# Sets the monitor index the conky should render on
def switch (index):
  config({'xinerama_head': index})

# Resets conky configuration to default settings
def reset ():
  config({'xinerama_head': 0})