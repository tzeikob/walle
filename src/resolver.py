#!/usr/bin/env python3
# An executable script resolving system data and status

import argparse
import signal
import json
import time
import threading
from common import globals
from util.logger import Router
from resolvers import static
from resolvers import loads
from resolvers import thermals
from resolvers import network
from resolvers import moment
from listeners import keyboard, mouse

# Marks process as not up and running on kill signals
def mark_shutdown (*args):
  global is_up
  is_up = False

  # Terminate keyboard and mouse listeners
  keyboard.listener.stop()
  mouse.listener.stop()

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

# Resolves instant timing tasks endlessly until the resolver goes down
def timings ():
  while is_up:
    timings_data = {}

    logger.disk.debug(f'resolving uptime data at {time.strftime(globals.TIME_FORMAT)}')

    timings_data['uptime'] = resolve(moment.uptime)

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

    monitor_data['loads'] = {
      'cpu': resolve(loads.cpu),
      'memory': resolve(loads.memory),
      'gpu': resolve(loads.gpu),
      'disk': resolve(loads.disk)
    }

    logger.disk.debug(f"loads data resolved:\n{monitor_data['loads']}")

    logger.disk.debug(f'resolving thermals data at {time.strftime(globals.TIME_FORMAT)}')

    monitor_data['thermals'] = {
      'cpu': resolve(thermals.cpu),
      'gpu': resolve(thermals.gpu)
    }

    logger.disk.debug(f"thermals data resolved:\n{monitor_data['thermals']}")

    logger.disk.debug(f'resolving network data at {time.strftime(globals.TIME_FORMAT)}')

    monitor_data['network'] = {
      'lan': resolve(network.lan),
      'public': resolve(network.public)
    }

    logger.disk.debug(f"network data resolved:\n{monitor_data['network']}")

    with open(globals.DATA_DIR_PATH + '/monitor', 'w') as monitor_file:
      monitor_file.write(json.dumps(monitor_data))

    logger.disk.debug('turning into the next monitor resolve cycle...')

    # Wait before start the next cycle
    time.sleep(1)

# Resolves keyboard listener events endlessly until the resolver goes down
def listen ():
  while is_up:
    listeners_data = {}

    logger.disk.debug(f'resolving listeners data at {time.strftime(globals.TIME_FORMAT)}')

    # Read a shared value among main and keyboard thread, but it's okay for just reading
    listeners_data['keyboard'] = keyboard.state['counters']
    listeners_data['mouse'] = mouse.state['counters']

    logger.disk.debug(f"listeners data resolved:\n{listeners_data}")

    with open(globals.DATA_DIR_PATH + '/listeners', 'w') as listeners_file:
      listeners_file.write(json.dumps(listeners_data))

    logger.disk.debug('turning into the next listeners resolve cycle...')

    # Wait before start the next cycle
    time.sleep(1)

# Parse command line arguments schema
parser = argparse.ArgumentParser(prog='resolver')

parser.add_argument('--debug', dest='debug', action='store_true')
parser.add_argument('--no-debug', dest='debug', action='store_false')
parser.set_defaults(debug=False)

opts = parser.parse_args()

# Initialize logging router
logger = Router('resolver', globals.LOG_FILE_PATH)

if opts.debug:
  logger.set_level('DEBUG')

# Mark script as up and running
is_up = True

# Attach shutdown kill handlers
signal.signal(signal.SIGINT, mark_shutdown)
signal.signal(signal.SIGTERM, mark_shutdown)

# Resolve once the system's static information
logger.disk.debug(f'resolving static information at {time.strftime(globals.TIME_FORMAT)}')

static.resolve()

logger.disk.debug(f"static information resolved:\n{static.state}")

with open(globals.DATA_DIR_PATH + '/static', 'w') as system_file:
  system_file.write(json.dumps(static.state))

# Launching timings tasks in a separate parallel thread
timings_thread = threading.Thread(target=timings)
timings_thread.start()

logger.disk.debug('timings thread spawn successfully')

# Launching monitor tasks in a separate parallel thread
monitor_thread = threading.Thread(target=monitor)
monitor_thread.start()

logger.disk.debug('monitor thread spawn successfully')

# Launch keyboard and mouse listener threads
keyboard.listener.start()
mouse.listener.start()

# Start monitoring user input events
listen()

logger.disk.debug('listener threads spawn successfully')

# Wait until any spawn threads have been terminated
timings_thread.join()
monitor_thread.join()

logger.disk.info('shutting down gracefully...')