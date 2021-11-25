#!/usr/bin/env python3
# A python script to orchestrate conky and service processes

import sys
import os
import subprocess
import time
import getpass
import config
import conky
import args
import logger
import globals

# Aborts the process in fatal error
def abort (message, errcode):
  logger.error('Error: ' + message)
  sys.exit(errcode)

# Writes the given data to the file with the given path
def write (path, data):
  with open(path, 'w') as output_file:
    output_file.write(str(data))

# Reads the contents of file with the given path
def read (path):
  if os.path.exists(path):
    with open(path) as input_file:
      return input_file.read().strip()
  else:
    return None

# Returns if the process with the given pid is up and running
def isUp (pid):
  return os.path.exists('/proc/' + str(pid))

# Spawns a new process given the command
def spawn (command):
  with open(globals.LOG_FILE_PATH, 'a') as log_file:
    try:
      process = subprocess.Popen(
        command.split(),
        stdout=log_file,
        stderr=log_file,
        universal_newlines=True)
    except Exception as error:
      raise Exception('Failed to execute command: ' + str(error))

  # Give time to the process to be spawn
  time.sleep(2)

  # Check if the process has failed to be spawn
  returncode = process.poll()

  if returncode != None and returncode != 0:
    raise Exception('Failed to spawn the process: ' + str(command))

  return process.pid

# Kills the process identified by the given pid
def kill (pid):
  if isUp(pid):
    with open(globals.LOG_FILE_PATH, 'a') as log_file:
      try:
        process = subprocess.run(
          ['kill', str(pid)],
          stdout=log_file,
          stderr=log_file,
          universal_newlines=True)
      except Exception as error:
        raise Exception('Failed to execute kill command: ' + str(error))

    if process.returncode != 0:
      raise Exception('Failed to kill the process: ' + str(pid))

    return True
  else:
    return False

# Starts resolver and conky processes
def start ():
  pid = read(globals.RESOLVER_PID_FILE_PATH)

  if not isUp(pid):
    try:
      pid = spawn('/usr/share/' + globals.PKG_NAME + '/bin/resolver.py')
      write(globals.RESOLVER_PID_FILE_PATH, pid)

      logger.info('resolver is up')
    except Exception as error:
      abort('Failed to spawn resolver process: ' + str(error), 1)
  
  pid = read(globals.CONKY_PID_FILE_PATH)

  if not isUp(pid):
    try:
      pid = spawn('conky -b -p 1 -c ' + globals.CONKYRC_FILE_PATH)
      write(globals.CONKY_PID_FILE_PATH, pid)

      logger.info('conky is up')
    except Exception as error:
      abort('Failed to spawn conky process: ' + str(error), 1)

  logger.info(globals.PKG_NAME + ' is up and running')

# Stops the resolver and conky processes
def stop ():
  pid = read(globals.RESOLVER_PID_FILE_PATH)

  try:
    if kill(pid):
      os.remove(globals.RESOLVER_PID_FILE_PATH)

    logger.info('resolver is down')
  except Exception as error:
    abort('Failed to stop resolver process: ' + str(error), 1)

  pid = read(globals.CONKY_PID_FILE_PATH)

  try:
    if kill(pid):
      os.remove(globals.CONKY_PID_FILE_PATH)

    logger.info('conky is down')
  except Exception as error:
    abort('Failed to stop resolver process: ' + str(error), 1)
  
  logger.info(globals.PKG_NAME + ' is shut down')

# Restart the resolver and conky processes
def restart():
  stop()
  time.sleep(1)
  start()

# Load the configuration file
settings = config.read()

# Parse given arguments into options
opts = args.parse(globals.PKG_NAME, settings['version'])

# Disalow calling this script as root user or sudo
if getpass.getuser() == 'root':
  abort("Don't run this script as root user", 1)

if opts.command == 'start':
  start()
elif opts.command == 'stop':
  stop()
elif opts.command == 'restart':
  restart()
elif opts.command == 'reset':
  settings['head'] = ''
  settings['system']['monitor'] = 0
  settings['system']['wallpapers']['path'] = ''
  settings['system']['wallpapers']['interval'] = 0
  settings['system']['debug'] = 'disabled'
  settings['theme']['mode'] = 'light'
  settings['theme']['font'] = ''

  config.write(settings)
  conky.config({
    'xinerama_head': 0,
    'default_color': 'white',
    'default_outline_color': 'white',
    'default_shade_color': 'white'
    })

  restart()
elif opts.command == 'config':
  if opts.head != None:
    settings['head'] = opts.head.strip()

  if opts.mode != None:
    settings['theme']['mode'] = opts.mode.strip()

    color = 'white'
    if settings['theme']['mode'] == 'dark':
      color = 'black'

    conky.config({
      'default_color': color,
      'default_outline_color': color,
      'default_shade_color': color
      })

  if opts.font != None:
    settings['theme']['font'] = opts.font.strip()

  if opts.wallpapers != None:
    settings['system']['wallpapers']['path'] = opts.wallpapers

  if opts.interval != None:
    settings['system']['wallpapers']['interval'] = opts.interval

  if opts.monitor != None:
    logger.info('monitor option is experimental')

    monitor = opts.monitor
    settings['system']['monitor'] = monitor

    conky.config({'xinerama_head': monitor})

  if opts.debug != None:
    settings['system']['debug'] = opts.debug.strip()

  config.write(settings)

  restart()
elif opts.command == 'preset':
  if opts.save:
    config.save_preset(opts.save, settings)
  elif opts.load:
    settings = config.load_preset(opts.load, settings)

    config.write(settings)

    color = 'white'
    if settings['theme']['mode'] == 'dark':
      color = 'black'

    conky.config({
      'default_color': color,
      'default_outline_color': color,
      'default_shade_color': color
      })

    restart()

sys.exit(0)