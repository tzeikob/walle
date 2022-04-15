#!/usr/bin/env python3

import sys
import getpass

# Abort if user in context is root or sudo used
if getpass.getuser() == 'root':
  print("[Errno 13] Don't run as root user")
  sys.exit(1)

import time
from common import globals
from common import args
from common import config
from util import system
from util.logger import Router

def start (debug=False):
  pid = system.read(globals.PID_FILE_PATH)

  if not system.isUp(pid):
    cmd = globals.INSTALL_DIR + '/app.py' + (' --debug' if debug else '')

    # Spawn resolver process
    pid = system.spawn(cmd, globals.LOG_FILE_PATH)

    # Save the pid to the disk
    system.write(pid, globals.PID_FILE_PATH)

  logger.disk.info(f"process is up with pid '{pid}'")

def stop ():
  pid = system.read(globals.PID_FILE_PATH)

  if system.kill(pid, globals.LOG_FILE_PATH):
    system.remove(globals.PID_FILE_PATH)

  logger.disk.info('process is down')

def restart():
  stop()
  time.sleep(1)
  start()

def should_restart ():
  pid = system.read(globals.PID_FILE_PATH)

  # Restart only if the process is up
  if not system.isUp(pid):
    return False

  return True

try:
  # Initialize logging router
  logger = Router(globals.PKG_NAME, globals.LOG_FILE_PATH)

  # Parse given command line arguments into options
  opts = args.parse(globals.PKG_NAME, globals.PKG_VERSION)

  # Start processes
  if opts.command == 'start':
    logger.disk.info('starting processes...')

    if opts.debug:
      logger.set_level('DEBUG')
      logger.disk.debug('debug mode has been enabled')

    start(opts.debug)

  # Stop processes
  if opts.command == 'stop':
    logger.disk.info('stopping processes...')

    stop()

  # Restart processes
  if opts.command == 'restart':
    logger.disk.info('restarting processes...')

    restart()

  # Reset configuration
  if opts.command == 'reset':
    logger.disk.info('resetting configuration...')

    config.reset()

    logger.disk.info('configuration has been set to default settings')

    if should_restart():
      restart()

  # Update configuration
  if opts.command == 'config':
    logger.disk.info('updating configuration settings...')

    config.update(opts)

    logger.disk.info('configuration settings have been updated')

    if should_restart():
      restart()

  # Export configuration to preset
  if opts.command == 'preset' and opts.save != None:
    logger.disk.info('exporting preset file...')

    config.export(opts.save)

    logger.disk.info(f"preset file has been saved to '{opts.save}'")

  # Load preset to configuration
  if opts.command == 'preset' and opts.load != None:
    logger.disk.info('loading preset file...')

    config.load(opts.load)

    logger.disk.info(f"preset has been loaded from '{opts.load}'")

    if should_restart():
      restart()

  system.exit(0)
except Exception as exc:
  logger.stderr.error(exc)
  logger.disk.trace(exc)
  system.exit(1)