#!/usr/bin/env python3
# An executable script to orchestrate conky and resolver processes

import time
import getpass
import config
import conky
import args
import system
import globals
import logger

# Starts the resolver process
def start_resolver ():
  pid = system.read(globals.RESOLVER_PID_FILE_PATH)

  if not system.isUp(pid):
    pid = system.spawn('/usr/share/' + globals.PKG_NAME + '/bin/resolver.py')
    system.write(globals.RESOLVER_PID_FILE_PATH, pid)

  logger.info('resolver process is up')

# Stops the resolver process
def stop_resolver ():
  pid = system.read(globals.RESOLVER_PID_FILE_PATH)

  if system.kill(pid):
    system.remove(globals.RESOLVER_PID_FILE_PATH)

  logger.info('resolver process is down')

# Starts the conky process
def start_conky ():
  pid = system.read(globals.CONKY_PID_FILE_PATH)

  if not system.isUp(pid):
    pid = system.spawn('conky -b -p 1 -c ' + globals.CONKYRC_FILE_PATH)
    system.write(globals.CONKY_PID_FILE_PATH, pid)

  logger.info('conky process is up')

# Stops the conky process
def stop_conky ():
  pid = system.read(globals.CONKY_PID_FILE_PATH)

  if system.kill(pid):
    system.remove(globals.CONKY_PID_FILE_PATH)

  logger.info('conky process is down')

# Restarts the resolver and conky processes
def restart():
  stop_conky()
  stop_resolver()

  time.sleep(1)

  start_resolver()
  start_conky()

# Disalow calling this script as root user or sudo
if getpass.getuser() == 'root':
  logger.error("don't run this script as root user")
  system.exit(1)

try:
  # Parse given cmd line arguments into options
  opts = args.parse(globals.PKG_NAME, globals.PKG_VERSION)

  if opts.command == 'start':
    start_resolver()
    start_conky()

    logger.info(globals.PKG_NAME + ' is up and running')

  if opts.command == 'stop':
    stop_conky()
    stop_resolver()

    logger.info(globals.PKG_NAME + ' is shutdown')

  if opts.command == 'restart':
    restart()

    logger.info(globals.PKG_NAME + ' is up and running')

  if opts.command == 'reset':
    config.reset()
    conky.reset()

    restart()

    logger.info(globals.PKG_NAME + ' is up and running')

  if opts.command == 'config':
    config.update(opts)

    if opts.monitor != None:
      logger.info('monitor switching is an experimental option')
      conky.switch(opts.monitor)

    restart()

    logger.info(globals.PKG_NAME + ' is up and running')

  if opts.command == 'preset' and opts.save != None:
    config.export(opts.save)

    logger.info('preset has been saved to ' + opts.save)

  if opts.command == 'preset' and opts.load != None:
    config.load(opts.load)

    restart()

    logger.info(globals.PKG_NAME + ' is up and running')

  system.exit(0)
except Exception as error:
  logger.error(str(error))
  system.exit(1)