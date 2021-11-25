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

PKG_NAME = '#PKG_NAME'
BASE_DIR = os.path.expanduser('~/.config/') + PKG_NAME
LOG_FILE_PATH = BASE_DIR + '/logs/' + PKG_NAME + '.log'
CONKY_LOG_FILE_PATH = BASE_DIR + '/logs/conky.log'
CONKY_PID_FILE_PATH = BASE_DIR + '/conky.pid'

# Aborts the process in fatal error: message, errcode
def abort (message, errcode):
  logger.error('Error: ' + message)
  sys.exit(errcode)

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

# Load the configuration file
settings = config.read()

# Parse given arguments into options
opts = args.parse(PKG_NAME, settings['version'])

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

  if isUp():
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
    monitor = opts.monitor
    settings['system']['monitor'] = monitor

    conky.config({'xinerama_head': monitor})

  if opts.debug != None:
    settings['system']['debug'] = opts.debug.strip()

  config.write(settings)

  if isUp():
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

    if isUp():
      restart()

sys.exit(0)