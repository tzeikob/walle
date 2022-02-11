# A module exporting utility methods to manage configuration

import os
import ruamel.yaml
from ruamel.yaml.scalarstring import SingleQuotedScalarString as scalar
from common import globals

# Initialize yaml parser
yaml = ruamel.yaml.YAML()

# Reads and parses the config file to an object
def read ():
  if not os.path.exists(globals.CONFIG_FILE_PATH):
    raise Exception('[Errno 2] Config file not found')

  with open(globals.CONFIG_FILE_PATH) as config_file:
    settings = yaml.load(config_file)

  # Recover string scalar values
  settings['version'] = scalar(settings['version'])

  return settings

# Dumps the settings object to the config file
def write (settings):
  if not os.path.exists(globals.CONFIG_FILE_PATH):
    raise Exception('[Errno 2] Config file not found')

  with open(globals.CONFIG_FILE_PATH, 'w') as config_file:
    yaml.dump(settings, config_file)

# Update the configuration settings given the cmd line arguments
def update (opts):
  settings = read()

  if opts.dark != None:
    settings['dark'] = opts.dark

  if opts.scale != None:
    settings['scale'] = opts.scale

  if opts.top != None:
    settings['offsets']['top'] = opts.top

  if opts.left != None:
    settings['offsets']['left'] = opts.left

  if opts.bottom != None:
    settings['offsets']['bottom'] = opts.bottom

  if opts.right != None:
    settings['offsets']['right'] = opts.right

  write(settings)

# Resets configuration to default settings
def reset ():
  settings = read()

  settings['dark'] = False
  settings['scale'] = 1
  settings['offsets']['top'] = 0
  settings['offsets']['left'] = 0
  settings['offsets']['bottom'] = 0
  settings['offsets']['right'] = 0

  write(settings)

# Dumps the theme part of the settings to a preset file
def export (path):
  settings = read()

  preset = {
      'version': settings['version'],
      'dark': settings['dark'],
      'scale': settings['scale'],
      'offsets': {
        'top': settings['offsets']['top'],
        'left': settings['offsets']['left'],
        'bottom': settings['offsets']['bottom'],
        'right': settings['offsets']['right']
      }
    }

  with open(path, 'w') as preset_file:
    yaml.dump(preset, preset_file)

# Loads the setting from the preset file to the configuration file
def load (path):
  if not os.path.exists(path):
    raise Exception(f"[Errno 2] File not found: '{path}'")

  with open(path) as preset_file:
    preset = yaml.load(preset_file)

  settings  = read()

  settings['dark'] = preset['dark']
  settings['scale'] = preset['scale']
  settings['offsets']['top'] = preset['offsets']['top']
  settings['offsets']['left'] = preset['offsets']['left']
  settings['offsets']['bottom'] = preset['offsets']['bottom']
  settings['offsets']['right'] = preset['offsets']['right']

  write(settings)