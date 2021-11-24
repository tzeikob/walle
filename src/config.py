# A module exporting utility methods to manage configuration

import os
import ruamel.yaml
from ruamel.yaml.scalarstring import SingleQuotedScalarString as scalar

PKG_NAME = '#PKG_NAME'
BASE_DIR = os.path.expanduser('~/.config/') + PKG_NAME
CONFIG_FILE_PATH = BASE_DIR + '/config.yml'

# Initialize yaml parser
yaml = ruamel.yaml.YAML()

# Reads and parses the config file to an object
def read ():
  if not os.path.exists(CONFIG_FILE_PATH):
    raise Exception('Failed to read config: missing config file')

  try:
    with open(CONFIG_FILE_PATH) as config_file:
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
  if not os.path.exists(CONFIG_FILE_PATH):
    raise Exception('Failed to write config: missing config file')

  try:
    with open(CONFIG_FILE_PATH, 'w') as config_file:
      yaml.dump(settings, config_file)
  except Exception as error:
    raise Exception('Failed to write config: ' + str(error))

# Dumps the theme part of the settings to a preset file with the given path
def save_preset (path, settings):
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

# Loads the preset file into the given setting object
def load_preset (path, settings):
  if not os.path.exists(path):
    raise Exception('Failed to load preset: file does not exist')

  try:
    with open(path) as preset_file:
      preset = yaml.load(preset_file)

      settings['theme']['mode'] = preset['theme']['mode']
      settings['theme']['font'] = scalar(preset['theme']['font'])

      return settings
  except Exception as error:
    raise Exception('Failed to load preset: ' + str(error))