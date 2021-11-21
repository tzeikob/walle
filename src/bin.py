#!/usr/bin/env python3
# An opinionated tool to manage and configure conky for developers

import sys
import os
import subprocess
import time
import re
import getpass
import argparse
import ruamel.yaml
from ruamel.yaml.scalarstring import SingleQuotedScalarString as scalar
from util import Logger

PKG_NAME = '#PKG_NAME'
BASE_DIR = os.path.expanduser("~") + '/.config/' + PKG_NAME
CONFIG_FILE_PATH = BASE_DIR + '/config.yml'
CONKYRC_FILE_PATH = BASE_DIR + '/.conkyrc'
LOG_FILE_PATH = BASE_DIR + '/logs/' + PKG_NAME + '.log'
CONKY_PID_FILE_PATH = BASE_DIR + '/conky.pid'

# Aborts the process in fatal error: message, errcode
def abort (message, errcode):
  logger.error('Error: ' + message)
  sys.exit(errcode)

# Asserts if the given value is a zero positive integer: value
def zeroPosInt (value):
  try:
    number = int(value)
    if number < 0:
      raise argparse.ArgumentTypeError("'%s' is not a zero positive int value" % value)

    return number
  except ValueError:
    raise argparse.ArgumentTypeError("'%s' is not a zero positive int value" % value)

# Asserts if the given value is a positive integer: value
def posInt (value):
  try:
    number = int(value)
    if number <= 0:
      raise argparse.ArgumentTypeError("'%s' is not a positive int value" % value)

    return number
  except ValueError:
    raise argparse.ArgumentTypeError("'%s' is not a positive int value" % value)

# Asserts if the given value is a conky valid font style value: value
def fontStyle (value):
  if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9_\- ])*(:bold)?(:italic)?(:size=[1-9][0-9]?[0-9]?)?$', value):
    raise argparse.ArgumentTypeError("'%s' is not a valid conky font style value" % value)

  return value

# Reads and parses the config file to an object
def readConfig ():
  try:
    with open(CONFIG_FILE_PATH) as config_file:
      cfg = yaml.load(config_file)

      # Recover string scalar values
      cfg['version'] = scalar(cfg['version'])
      cfg['head'] = scalar(cfg['head'])
      cfg['system']['wallpapers']['path'] = scalar(cfg['system']['wallpapers']['path'])
      cfg['theme']['font'] = scalar(cfg['theme']['font'])

      return cfg
  except EnvironmentError:
    abort('failed to read the config file', 1)

# Dumps the config object to a yaml file: config
def writeConfig (config):
  try:
    with open(CONFIG_FILE_PATH, 'w') as config_file:
      yaml.dump(config, config_file)
  except EnvironmentError:
    abort('failed to write to config file', 1)

# Write the given settings to conkyrc file
def writeConkyConfig (settings):
  if not os.path.exists(CONKYRC_FILE_PATH):
    abort('failed to write settings: missing conkyrc file', 1)

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

# Resolves the given arguments schema: prog
def resolveArgs (prog):
  parser = argparse.ArgumentParser(
    prog=prog,
    description='An opinionated tool to manage and configure conky for developers.',
    epilog='Have a nice %(prog)s time!')

  parser.add_argument(
    '-v', '--version',
    action='version',
    version=config['version'],
    help='show the version number and exit')

  subparsers = parser.add_subparsers(metavar='command', dest='command')
  subparsers.required = True

  subparsers.add_parser('start', help='start %(prog)s spawning the conky process')
  subparsers.add_parser('restart', help='restart %(prog)s respawning the conky process')
  subparsers.add_parser('stop', help='stop %(prog)s killing the conky process')
  subparsers.add_parser('reset', help='reset %(prog)s back to default settings')

  configParser = subparsers.add_parser('config', help='configure %(prog)s and restart the conky process')

  configParser.add_argument(
    '--head',
    metavar='text',
    help="set the text which will appear as head line")

  configParser.add_argument(
    '-m', '--mode',
    choices=['light', 'dark'],
    metavar='mode',
    help="set the theme color mode to 'light' or 'dark'")

  configParser.add_argument(
    '-f', '--font',
    type=fontStyle,
    metavar='font',
    help='set the font style the text should appear with')

  configParser.add_argument(
    '-w', '--wallpapers',
    metavar='path',
    help='set the path to a folder containing wallpaper image files')

  configParser.add_argument(
    '-i', '--interval',
    type=zeroPosInt,
    metavar='secs',
    help='set the interval in secs the wallpaper should randomly rotate by')

  configParser.add_argument(
    '--monitor',
    type=zeroPosInt,
    metavar='index',
    help='set the monitor index the conky should render at')

  configParser.add_argument(
    '--debug',
    choices=['enabled', 'disabled'],
    metavar='mode',
    help="set debug mode to 'enabled' or 'disabled'")

  presetParser = subparsers.add_parser('preset', help='save or load %(prog)s preset files')
  presetGroup = presetParser.add_mutually_exclusive_group()

  presetGroup.add_argument(
    '--save',
    metavar='path',
    help="set the file path the preset will be saved in")

  presetGroup.add_argument(
    '--load',
    metavar='path',
    help="set the file path the preset will be loaded from")

  return parser.parse_args()

# Read the pid of the pid file
def readPid ():
  if os.path.exists(CONKY_PID_FILE_PATH):
    with open(CONKY_PID_FILE_PATH) as pid_file:
      return pid_file.read().strip()
  else:
    return None

# Returns if the conky process is up and running
def isUp ():
  pid = readPid()
  return os.path.exists('/proc/' + str(pid))

# Spawns the conky process: silent
def start (silent=False):
  if isUp():
    if not silent: logger.info('Conky is already up and running')
    return

  # Launch the conky process
  with open(LOG_FILE_PATH, 'a') as log_file:
    try:
      process = subprocess.Popen(
        ['conky', '-b', '-p', '1', '-c', CONKYRC_FILE_PATH],
        stdout=log_file,
        stderr=log_file,
        universal_newlines=True)
    except:
      abort('failed to spawn the conky process', 1)

    # Give time to conky to be spawn
    time.sleep(2)

    # Check if the process has failed to spawn
    returncode = process.poll()
    if returncode != None and returncode != 0:
      abort('failed to spawn the conky process', 1)

    # Save the conky process id in the file system
    with open(CONKY_PID_FILE_PATH, 'w') as pid_file:
      pid_file.write(str(process.pid))

  if isUp():
    if not silent: logger.info('Conky is up and running')
  else:
    abort('failed to spawn the conky process', 1)

# Stops the running conky process: silent
def stop (silent=False):
  if isUp():
    pid = readPid()

    # Kill conky process given the pid
    with open(LOG_FILE_PATH, 'a') as log_file:
      try:
        process = subprocess.run(
          ['kill', str(pid)],
          stdout=log_file,
          stderr=log_file,
          universal_newlines=True)
      except:
        abort('failed to kill the conky process', 1)

    if process.returncode != 0:
      abort('failed to kill the conky process', 1)

    os.remove(CONKY_PID_FILE_PATH)

    if not silent: logger.info('Conky is now shut down')
  else:
    if not silent: logger.info('Conky is already shut down')

# Restart the conky process
def restart():
  if isUp():
    stop(True)
    time.sleep(1)
    start(True)

    logger.info('Conky has been restarted')
  else:
    start()

# Dumps the theme part of the config as a preset file
def savePreset (config, path):
  try:
    with open(path, 'w') as preset_file:
      preset = {
        'version': config['version'],
        'theme': {
          'mode': config['theme']['mode'],
          'font': config['theme']['font']
        }
      }

      yaml.dump(preset, preset_file)
  except EnvironmentError:
    abort('failed to save preset to file', 1)

# Loads the preset file into the config
def loadPreset (path, config):
  try:
    with open(path) as preset_file:
      preset = yaml.load(preset_file)

      config['theme']['mode'] = preset['theme']['mode']
      config['theme']['font'] = scalar(preset['theme']['font'])

      return config
  except EnvironmentError:
    abort('failed to read the preset file', 1)

# Initialize logger
logger = Logger(LOG_FILE_PATH)

# Initialize yaml parser
yaml = ruamel.yaml.YAML()

# Load the configuration file
config = readConfig()

# Resolve given arguments
args = resolveArgs(PKG_NAME)

# Disalow calling this script as root user or sudo
if getpass.getuser() == 'root':
  abort("don't run this script as root user", 1)

if args.command == 'start':
  start()
elif args.command == 'stop':
  stop()
elif args.command == 'restart':
  restart()
elif args.command == 'reset':
  config['head'] = ''
  config['system']['monitor'] = 0
  config['system']['wallpapers']['path'] = ''
  config['system']['wallpapers']['interval'] = 0
  config['system']['debug'] = 'disabled'
  config['theme']['mode'] = 'light'
  config['theme']['font'] = ''

  writeConfig(config)

  writeConkyConfig({
    'xinerama_head': 0,
    'default_color': 'white',
    'default_outline_color': 'white',
    'default_shade_color': 'white'
    })

  if isUp():
    restart()
elif args.command == 'config':
  if args.head != None:
    config['head'] = args.head.strip()

  if args.mode != None:
    config['theme']['mode'] = args.mode.strip()

    color = 'white'
    if config['theme']['mode'] == 'dark':
      color = 'black'

    writeConkyConfig({
      'default_color': color,
      'default_outline_color': color,
      'default_shade_color': color
      })


  if args.font != None:
    config['theme']['font'] = args.font.strip()

  if args.wallpapers != None:
    config['system']['wallpapers']['path'] = args.wallpapers

  if args.interval != None:
    config['system']['wallpapers']['interval'] = args.interval

  if args.monitor != None:
    monitor = args.monitor
    config['system']['monitor'] = monitor
    writeConkyConfig({'xinerama_head': monitor})

  if args.debug != None:
    config['system']['debug'] = args.debug.strip()

  writeConfig(config)

  if isUp():
    restart()
elif args.command == 'preset':
  if args.save:
    savePreset(config, args.save)
  elif args.load:
    config = loadPreset(args.load, config)
    writeConfig(config)

    if isUp():
      restart()

sys.exit(0)