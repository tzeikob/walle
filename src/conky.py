# A module exporting utility methods to manage conky

import os
import re

PKG_NAME = '#PKG_NAME'
BASE_DIR = os.path.expanduser('~/.config/') + PKG_NAME
CONKYRC_FILE_PATH = BASE_DIR + '/.conkyrc'

# Writes the given settings to the conkyrc file
def config (settings):
  if not os.path.exists(CONKYRC_FILE_PATH):
    raise Exception('Failed to configure conky: missing conkyrc file')

  newContent = ''

  with open(CONKYRC_FILE_PATH, 'r') as conkyrc_file:
    for line in conkyrc_file:
      for key in settings:
        if re.match(r'^[ ]*{}[ ]*=[ ]*.+,[ ]*$'.format(key), line):
          value = settings[key]

          if type(value) is str:
            value = "'" + value + "'"

          line = '    ' + key + ' = ' + str(value) + ',\n'

      newContent += line

  with open(CONKYRC_FILE_PATH, 'w') as conkyrc_file:
    conkyrc_file.write(newContent)