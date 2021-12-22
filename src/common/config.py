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
  settings['head'] = scalar(settings['head'])
  settings['theme']['font'] = scalar(settings['theme']['font'])

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

  if opts.head != None:
    settings['head'] = opts.head.strip()

  if opts.mode != None:
    settings['theme']['mode'] = opts.mode.strip()

  if opts.font != None:
    settings['theme']['font'] = opts.font.strip()

  if opts.debug != None:
    settings['debug'] = opts.debug.strip()

  write(settings)

# Resets configuration to default settings
def reset ():
  settings = read()

  settings['head'] = ''
  settings['theme']['mode'] = 'light'
  settings['theme']['font'] = ''
  settings['debug'] = 'disabled'

  write(settings)

# Dumps the theme part of the settings to a preset file
def export (path):
  settings = read()

  preset = {
      'version': settings['version'],
      'theme': {
        'mode': settings['theme']['mode'],
        'font': settings['theme']['font']
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

  settings['theme']['mode'] = preset['theme']['mode']
  settings['theme']['font'] = scalar(preset['theme']['font'])

  write(settings)