#!/usr/bin/env python3
# An executable script resolving system data

import argparse
import signal
import json
import time
from common import globals
from util.logger import Router
from resolvers import static
from resolvers import uptime
from resolvers import monitor
from resolvers import network
from listeners import keyboard, mouse

# Parse command line arguments schema
parser = argparse.ArgumentParser(prog='resolver')

parser.add_argument('--debug', dest='debug', action='store_true')
parser.add_argument('--no-debug', dest='debug', action='store_false')
parser.set_defaults(debug=False)

opts = parser.parse_args()

state = {
  'up': True
}

# Initialize logging router
logger = Router('resolver', globals.LOG_FILE_PATH)

if opts.debug:
  logger.set_level('DEBUG')

# Terminates the main and child threads
def mark_shutdown (*args):
  uptime.stop()
  monitor.stop()
  keyboard.stop()
  mouse.stop()

  state['up'] = False

# Attach shutdown handlers
signal.signal(signal.SIGINT, mark_shutdown)
signal.signal(signal.SIGTERM, mark_shutdown)

# Resolve once the system's static information
static.resolve()

# Start monitoring system uptime, loads and network
uptime.start()
monitor.start()
network.start()

# Start listening for keyboard and mouse events
keyboard.start()
mouse.start()

while state['up']:
  data = {}

  # Read the static resolver state
  data['static'] = static.state['data']

  # Read monitoring data
  data['uptime'] = uptime.state['data']
  data['monitor'] = monitor.state['data']
  data['network'] = network.state['data']

  # Read keyboard and mouse state
  data['keyboard'] = keyboard.state['data']
  data['mouse'] = mouse.state['data']

  with open(globals.DATA_FILE_PATH, 'w') as data_file:
    data_file.write(json.dumps(data))

  logger.disk.debug('turning into the next resolve cycle...')

  # Wait before start the next cycle
  time.sleep(1)

logger.disk.info('shutting down gracefully...')