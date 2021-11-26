# A module exporting utility methods to manage configuration

import os
import ruamel.yaml
from ruamel.yaml.scalarstring import SingleQuotedScalarString as scalar
import globals

# Initialize yaml parser
yaml = ruamel.yaml.YAML()

# Reads and parses the config file to an object
def read ():
  if not os.path.exists(globals.CONFIG_FILE_PATH):
    raise Exception('Failed to read config: missing config file')

  try:
    with open(globals.CONFIG_FILE_PATH) as config_file:
      settings = yaml.load(config_file)

      # Recover string scalar values
      settings['version'] = scalar(settings['version'])
      settings['head'] = scalar(settings['head'])
      settings['system']['wallpapers']['path'] = scalar(settings['system']['wallpapers']['path'])
      settings['theme']['font'] = scalar(settings['theme']['font'])

      return settings
  except Exception as error:
    raise Exception('Failed to read config: ' + str(error))

# Dumps the settings object to the config file
def write (settings):
  if not os.path.exists(globals.CONFIG_FILE_PATH):
    raise Exception('Failed to write config: missing config file')

  try:
    with open(globals.CONFIG_FILE_PATH, 'w') as config_file:
      yaml.dump(settings, config_file)
  except Exception as error:
    raise Exception('Failed to write config: ' + str(error))

# Update the configuration settings given the cmd line arguments
def update (opts):
  settings = read()

  if opts.head != None:
    settings['head'] = opts.head.strip()

  if opts.mode != None:
    settings['theme']['mode'] = opts.mode.strip()

  if opts.font != None:
    settings['theme']['font'] = opts.font.strip()

  if opts.wallpapers != None:
    settings['system']['wallpapers']['path'] = opts.wallpapers

  if opts.interval != None:
    settings['system']['wallpapers']['interval'] = opts.interval

  if opts.debug != None:
    settings['system']['debug'] = opts.debug.strip()

  write(settings)

# Resets configuration to default settings
def reset ():
  settings = read()

  settings['head'] = ''
  settings['system']['wallpapers']['path'] = ''
  settings['system']['wallpapers']['interval'] = 0
  settings['system']['debug'] = 'disabled'
  settings['theme']['mode'] = 'light'
  settings['theme']['font'] = ''

  write(settings)

# Dumps the theme part of the settings to a preset file
def export (path):
  settings = read()

  try:
    with open(path, 'w') as preset_file:
      preset = {
        'version': settings['version'],
        'theme': {
          'mode': settings['theme']['mode'],
          'font': settings['theme']['font']
        }
      }

      yaml.dump(preset, preset_file)
  except Exception as error:
    raise Exception('Failed to save preset: ' + str(error))

# Loads the setting from the preset file to the configuration file
def load (path):
  if not os.path.exists(path):
    raise Exception('Failed to load preset: file does not exist')

  settings  = read()

  try:
    with open(path) as preset_file:
      preset = yaml.load(preset_file)

      settings['theme']['mode'] = preset['theme']['mode']
      settings['theme']['font'] = scalar(preset['theme']['font'])

      write(settings)
  except Exception as error:
    raise Exception('Failed to load preset: ' + str(error))