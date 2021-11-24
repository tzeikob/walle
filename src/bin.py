#!/usr/bin/env python3
# A python script to orchestrate conky and service processes

import sys
import os
import subprocess
import time
import re
import getpass
import args
import ruamel.yaml
from ruamel.yaml.scalarstring import SingleQuotedScalarString as scalar
from util import Logger

PKG_NAME = '#PKG_NAME'
BASE_DIR = os.path.expanduser("~") + '/.config/' + PKG_NAME
CONFIG_FILE_PATH = BASE_DIR + '/config.yml'
CONKYRC_FILE_PATH = BASE_DIR + '/.conkyrc'
LOG_FILE_PATH = BASE_DIR + '/logs/' + PKG_NAME + '.log'
CONKY_LOG_FILE_PATH = BASE_DIR + '/logs/conky.log'
CONKY_PID_FILE_PATH = BASE_DIR + '/conky.pid'

# Aborts the process in fatal error: message, errcode
def abort (message, errcode):
  logger.error('Error: ' + message)
  sys.exit(errcode)

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

  with open(LOG_FILE_PATH, 'a') as log_file:
    try:
      service = subprocess.run(
        ['sudo', 'systemctl', 'start', PKG_NAME + '.service'],
        stdout=log_file,
        stderr=log_file,
        universal_newlines=True)
    except:
      abort('failed to start the service', 1)

  if service.returncode != 0:
    abort('failed to start the service', 1)

  # Launch the conky process
  with open(CONKY_LOG_FILE_PATH, 'a') as log_file:
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
    with open(CONKY_LOG_FILE_PATH, 'a') as log_file:
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

    with open(LOG_FILE_PATH, 'a') as log_file:
      try:
        service = subprocess.run(
          ['sudo', 'systemctl', 'stop', PKG_NAME + '.service'],
          stdout=log_file,
          stderr=log_file,
          universal_newlines=True)
      except:
        abort('failed to stop the service', 1)

    if service.returncode != 0:
      abort('failed to stop the service', 1)
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

# Parse given arguments
opts = args.parse(PKG_NAME, config['version'])

# Disalow calling this script as root user or sudo
if getpass.getuser() == 'root':
  abort("don't run this script as root user", 1)

if opts.command == 'start':
  start()
elif opts.command == 'stop':
  stop()
elif opts.command == 'restart':
  restart()
elif opts.command == 'reset':
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
elif opts.command == 'config':
  if opts.head != None:
    config['head'] = opts.head.strip()

  if opts.mode != None:
    config['theme']['mode'] = opts.mode.strip()

    color = 'white'
    if config['theme']['mode'] == 'dark':
      color = 'black'

    writeConkyConfig({
      'default_color': color,
      'default_outline_color': color,
      'default_shade_color': color
      })


  if opts.font != None:
    config['theme']['font'] = opts.font.strip()

  if opts.wallpapers != None:
    config['system']['wallpapers']['path'] = opts.wallpapers

  if opts.interval != None:
    config['system']['wallpapers']['interval'] = opts.interval

  if opts.monitor != None:
    monitor = opts.monitor
    config['system']['monitor'] = monitor
    writeConkyConfig({'xinerama_head': monitor})

  if opts.debug != None:
    config['system']['debug'] = opts.debug.strip()

  writeConfig(config)

  if isUp():
    restart()
elif opts.command == 'preset':
  if opts.save:
    savePreset(config, opts.save)
  elif opts.load:
    config = loadPreset(opts.load, config)
    writeConfig(config)

    if isUp():
      restart()

sys.exit(0)