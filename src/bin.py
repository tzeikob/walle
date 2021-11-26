#!/usr/bin/env python3
# A python script to orchestrate conky and service processes

import time
import getpass
import config
import conky
import args
import system
import globals
import logger

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

# Parse given arguments into options
opts = args.parse(globals.PKG_NAME, globals.PKG_VERSION)

if opts.command == 'start':
  start()
elif opts.command == 'stop':
  stop()
elif opts.command == 'restart':
  restart()
elif opts.command == 'reset':
  config.reset()
  conky.reset()

  restart()
elif opts.command == 'config':
  config.update(opts)

  if opts.monitor != None:
    logger.info('monitor switching is an experimental option')
    conky.switch(opts.monitor)

  restart()
elif opts.command == 'preset':
  if opts.save:
    config.export(opts.save)
  elif opts.load:
    config.load(opts.load)

    restart()

system.exit(0)