#!/usr/bin/env python3
# An executable script to orchestrate conky and resolver processes

import sys
import getpass

# Abort if user in context is root or sudo used
if getpass.getuser() == 'root':
  print("[Errno 13] Don't run as root user")
  sys.exit(1)

import os
import time
from common import globals
from common import args
from common import config
from common import conky
from util import system
from util.logger import Router

# Starts the resolver process
def start_resolver (debug=False):
  pid = system.read(globals.RESOLVER_PID_FILE_PATH)

  if not system.isUp(pid):
    options = ' --release --login --timings --monitor'

    if debug:
      options += ' --debug'

    # Spawn resolver process
    pid = system.spawn(globals.RESOLVER_FILE_PATH + options, globals.LOG_FILE_PATH)

    # Save the pid to the disk
    system.write(pid, globals.RESOLVER_PID_FILE_PATH)

  logger.disk.info(f"resolver process is up with pid '{pid}'")

# Stops the resolver process
def stop_resolver ():
  pid = system.read(globals.RESOLVER_PID_FILE_PATH)

  if system.kill(pid, globals.LOG_FILE_PATH):
    system.remove(globals.RESOLVER_PID_FILE_PATH)

  logger.disk.info('resolver process is down')

# Starts the conky process
def start_conky (debug=False):
  pid = system.read(globals.CONKY_PID_FILE_PATH)

  if not system.isUp(pid):
    # Initialize conky with respect to the system
    conky.init()

    options = ' -b -p 1 -c ' + globals.CONKYRC_FILE_PATH

    if debug:
      options += ' --debug'

    # Define env variable to set debug mode or not
    debug_env = os.environ.copy()
    debug_env['DEBUG_MODE'] = str(debug).lower()

    # Spawn the conky process
    pid = system.spawn('conky' + options, globals.LOG_FILE_PATH, debug_env)

    # Save pid to the dsk
    system.write(pid, globals.CONKY_PID_FILE_PATH)

  logger.disk.info(f"conky process is up with pid '{pid}'")

# Stops the conky process
def stop_conky ():
  pid = system.read(globals.CONKY_PID_FILE_PATH)

  if system.kill(pid, globals.LOG_FILE_PATH):
    system.remove(globals.CONKY_PID_FILE_PATH)

  logger.disk.info('conky process is down')

# Restarts the resolver and conky processes
def restart():
  stop_conky()
  time.sleep(1)
  stop_resolver()

  time.sleep(1)

  start_resolver()
  time.sleep(1)
  start_conky()

# Returns if should restart processes when any process is down
def should_restart ():
  resolver_pid = system.read(globals.RESOLVER_PID_FILE_PATH)
  conky_pid = system.read(globals.CONKY_PID_FILE_PATH)

  # Restart only if both up or one of them is down
  if not system.isUp(resolver_pid) and not system.isUp(conky_pid):
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

    start_resolver(opts.debug)
    time.sleep(1)
    start_conky(opts.debug)

  # Stop processes
  if opts.command == 'stop':
    logger.disk.info('stopping processes...')

    stop_conky()
    time.sleep(1)
    stop_resolver()

  # Restart processes
  if opts.command == 'restart':
    logger.disk.info('restarting processes...')

    restart()

  # Reset configuration
  if opts.command == 'reset':
    logger.disk.info('resetting configuration...')

    config.reset()
    conky.reset()

    logger.disk.info('configuration has been set to default settings')

    if should_restart():
      restart()

  # Update configuration
  if opts.command == 'config':
    logger.disk.info('updating configuration settings...')

    config.update(opts)

    # Update the conky config instantly
    if opts.monitor != None:
      conky.switch(opts.monitor)
      logger.stdout.info('Warning: monitor switch is an experimental operation')

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