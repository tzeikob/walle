#!/usr/bin/env python3
# An executable script to orchestrate conky and resolver processes

import time
import globals
import system
import args
import config
import conky
import logger

# Starts the resolver process
def start_resolver ():
  pid = system.read(globals.RESOLVER_PID_FILE_PATH)

  if not system.isUp(pid):
    pid = system.spawn('/usr/share/' + globals.PKG_NAME + '/bin/resolver.py')
    system.write(pid, globals.RESOLVER_PID_FILE_PATH)

  logger.disk.info(f"resolver process is up with pid '{pid}'")

# Stops the resolver process
def stop_resolver ():
  pid = system.read(globals.RESOLVER_PID_FILE_PATH)

  if system.kill(pid):
    system.remove(globals.RESOLVER_PID_FILE_PATH)

  logger.disk.info('resolver process is down')

# Starts the conky process
def start_conky ():
  pid = system.read(globals.CONKY_PID_FILE_PATH)

  if not system.isUp(pid):
    pid = system.spawn('conky -b -p 1 -c ' + globals.CONKYRC_FILE_PATH)
    system.write(pid, globals.CONKY_PID_FILE_PATH)

  logger.disk.info(f"conky process is up with pid '{pid}'")

# Stops the conky process
def stop_conky ():
  pid = system.read(globals.CONKY_PID_FILE_PATH)

  if system.kill(pid):
    system.remove(globals.CONKY_PID_FILE_PATH)

  logger.disk.info('conky process is down')

# Restarts the resolver and conky processes
def restart():
  stop_conky()
  stop_resolver()

  time.sleep(1)

  start_resolver()
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
  # Parse given cmd line arguments into options
  opts = args.parse(globals.PKG_NAME, globals.PKG_VERSION)

  # Start processes
  if opts.command == 'start':
    logger.disk.info('starting processes...')

    start_resolver()
    start_conky()

  # Stop processes
  if opts.command == 'stop':
    logger.disk.info('stopping processes...')

    stop_conky()
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
except Exception as error:
  logger.stderr.error(str(error))
  logger.disk.trace(error)
  system.exit(1)