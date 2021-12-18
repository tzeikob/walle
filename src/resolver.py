#!/usr/bin/env python3
# An executable script resolving system data and status

import sys
import getpass

# Abort if user in context is root or sudo used
if getpass.getuser() == 'root':
  print("[Errno 13] Don't run as root user")
  sys.exit(1)

import signal
import json
import time
import threading
import globals
import config
from logger import Router
from tasks import release
from tasks import login
from tasks import hardware
from tasks import loads
from tasks import thermals
from tasks import network
from tasks import uptime

# Marks process as not up and running on kill signals
def mark_shutdown (*args):
  global is_up
  is_up = False

# Resolve the given module task with fallback protection
def resolve (task):
  result = None

  try:
    # Call the resolve method each task should has
    result = task.resolve()
  except Exception as exc:
    # Just report and fallback to return none
    logger.disk.trace(exc)

  return result

# Read the configuration settings
settings = config.read()

# Initialize logging router
logger = Router('resolver', globals.LOG_FILE_PATH)

if settings['debug'] == 'enabled':
  logger.set_level('DEBUG')

# Mark script as up and running
is_up = True

# Attach shutdown kill handlers
signal.signal(signal.SIGINT, mark_shutdown)
signal.signal(signal.SIGTERM, mark_shutdown)

logger.disk.debug(f"resolving hardware data at {time.strftime(globals.TIME_FORMAT)}")

hardware_data = resolve(hardware)

# Read memory data already resolved at installation
with open(globals.DATA_DIR_PATH + '/hardware') as hardware_file:
  hardware_data['memory'] = json.load(hardware_file)['memory']

logger.disk.debug(f'hardware data resolved:\n{hardware_data}')

with open(globals.DATA_DIR_PATH + '/hardware', 'w') as hardware_file:
  hardware_file.write(json.dumps(hardware_data))

logger.disk.debug(f'resolving release data at {time.strftime(globals.TIME_FORMAT)}')

release_data = resolve(release)

logger.disk.debug(f'release data resolved:\n{release_data}')

with open(globals.DATA_DIR_PATH + '/release', 'w') as release_file:
  release_file.write(json.dumps(release_data))

logger.disk.debug(f'resolving login data at {time.strftime(globals.TIME_FORMAT)}')

login_data = resolve(login)

logger.disk.debug(f'login data resolved:\n{login_data}')

with open(globals.DATA_DIR_PATH + '/login', 'w') as login_file:
  login_file.write(json.dumps(login_data))

# Resolves instant timing tasks endlessly until the resolver goes down
def timings ():
  while is_up:
    timings_data = {}

    logger.disk.debug(f'resolving uptime data at {time.strftime(globals.TIME_FORMAT)}')

    timings_data['uptime'] = resolve(uptime)

    logger.disk.debug(f"uptime data resolved:\n{timings_data['uptime']}")

    with open(globals.DATA_DIR_PATH + '/timings', 'w') as timings_file:
      timings_file.write(json.dumps(timings_data))

    logger.disk.debug('turning into the next timings resolve cycle...')

    # Wait before start the next cycle
    time.sleep(1)

# Resolves monitoring tasks endlessly until the resolver goes down
def monitor ():
  while is_up:
    monitor_data = {}

    logger.disk.debug(f'resolving loads data at {time.strftime(globals.TIME_FORMAT)}')

    monitor_data['loads'] = resolve(loads)

    logger.disk.debug(f"loads data resolved:\n{monitor_data['loads']}")

    logger.disk.debug(f'resolving thermals data at {time.strftime(globals.TIME_FORMAT)}')

    monitor_data['thermals'] = resolve(thermals)

    logger.disk.debug(f"thermals data resolved:\n{monitor_data['thermals']}")

    logger.disk.debug(f'resolving network data at {time.strftime(globals.TIME_FORMAT)}')

    monitor_data['network'] = resolve(network)

    logger.disk.debug(f"network data resolved:\n{monitor_data['network']}")

    with open(globals.DATA_DIR_PATH + '/monitor', 'w') as monitor_file:
      monitor_file.write(json.dumps(monitor_data))

    logger.disk.debug('turning into the next monitor resolve cycle...')

    # Wait before start the next cycle
    time.sleep(4)

# Launching timings tasks in a separate parallel thread
timings_thread = threading.Thread(target=timings)
timings_thread.start()

logger.disk.debug('timings thread spawn successfully')

# Launching monitor tasks in a separate parallel thread
monitor_thread = threading.Thread(target=monitor)
monitor_thread.start()

logger.disk.debug('monitor thread spawn successfully')

timings_thread.join()
monitor_thread.join()

logger.disk.info('shutting down gracefully...')