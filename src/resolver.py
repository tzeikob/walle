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
from datetime import datetime
import globals
import config
from logger import Router
from lib import release
from lib import login
from lib import hardware
from lib import loads
from lib import thermals
from lib import network

# Marks process as not up and running on kill signals
def mark_shutdown (*args):
  global is_up
  is_up = False

# Executes the resolve API of the given callback
def run (module):
  result = None

  try:
    # Call the resolve method each module should has
    result = module.resolve()
  except Exception as exc:
    # Just report and return none
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

# Collect system data in one place
data = {
  'hardware': {},
  'system': {},
  'monitor': {}
}

logger.disk.debug(f'resolving static data at {str(datetime.now())}')

# Read memory data already resolved at installation
with open(globals.DATA_DIR_PATH + '/hardware') as hardware_file:
  memory = json.load(hardware_file)['memory']

# Resolve the rest of the hardware data and save them along with memory
data['hardware'] = run(hardware)
data['hardware']['memory'] = memory

# Save again hardware data into the disk
with open(globals.DATA_DIR_PATH + '/hardware', 'w') as hardware_file:
  hardware_file.write(json.dumps(data['hardware']))

# Resolve static system's release and login data
data['system']['release'] = run(release)
data['system']['login'] = run(login)

# Save system data into the disk
with open(globals.DATA_DIR_PATH + '/system', 'w') as system_file:
  system_file.write(json.dumps(data['system']))

logger.disk.debug('static data resolved successfully')

# Loop endlessly resolving monitoring data
while is_up:
  logger.disk.debug(f'resolving monitor data at {str(datetime.now())}')

  data['monitor']['loads'] = run(loads)
  data['monitor']['thermals'] = run(thermals)
  data['monitor']['network'] = run(network)

  logger.disk.debug('monitor data resolved successfully')

  # Write down the collected monitoring data to the disk
  with open(globals.DATA_DIR_PATH + '/monitor', 'w') as data_file:
    data_file.write(json.dumps(data['monitor']))

  logger.disk.debug(f'resolved data: \n{str(data)}')
  logger.disk.debug(f'turning into the next resolve cycle...')

  # Wait before start the next cycle
  time.sleep(globals.RESOLVER_INTERVAL)

logger.disk.info('shutdown gracefully')