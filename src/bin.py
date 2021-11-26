#!/usr/bin/env python3
# A python script to orchestrate conky and service processes

import time
import getpass
import config
import conky
import args
import logger
import system
import globals

# Starts resolver and conky processes
def start ():
  pid = system.read(globals.RESOLVER_PID_FILE_PATH)

  if not system.isUp(pid):
    try:
      pid = system.spawn('/usr/share/' + globals.PKG_NAME + '/bin/resolver.py')
      system.write(globals.RESOLVER_PID_FILE_PATH, pid)

      logger.info('resolver is up')
    except Exception as error:
      logger.error('Failed to spawn resolver process: ' + str(error))
      system.exit(1)

  pid = system.read(globals.CONKY_PID_FILE_PATH)

  if not system.isUp(pid):
    try:
      pid = system.spawn('conky -b -p 1 -c ' + globals.CONKYRC_FILE_PATH)
      system.write(globals.CONKY_PID_FILE_PATH, pid)

      logger.info('conky is up')
    except Exception as error:
      logger.error('Failed to spawn conky process: ' + str(error))
      system.exit(1)

  logger.info(globals.PKG_NAME + ' is up and running')

# Stops the resolver and conky processes
def stop ():
  pid = system.read(globals.RESOLVER_PID_FILE_PATH)

  try:
    if system.kill(pid):
      system.remove(globals.RESOLVER_PID_FILE_PATH)

    logger.info('resolver is down')
  except Exception as error:
    logger.error('Failed to stop resolver process: ' + str(error))
    system.exit(1)

  pid = system.read(globals.CONKY_PID_FILE_PATH)

  try:
    if system.kill(pid):
      system.remove(globals.CONKY_PID_FILE_PATH)

    logger.info('conky is down')
  except Exception as error:
    logger.error('Failed to stop resolver process: ' + str(error))
    system.exit(1)
  
  logger.info(globals.PKG_NAME + ' is shut down')

# Restart the resolver and conky processes
def restart():
  stop()
  time.sleep(1)
  start()

# Disalow calling this script as root user or sudo
if getpass.getuser() == 'root':
  logger.error("don't run this script as root user")
  system.exit(1)

# Load the configuration file
settings = config.read()

# Parse given arguments into options
opts = args.parse(globals.PKG_NAME, settings['version'])

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

system.exit(0)