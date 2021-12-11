#!/usr/bin/env python3
# An executable script resolving system data and status

import json
import time
from datetime import datetime
import globals
import config
from logger import Router
from lib import uptime
from lib import release
from lib import login
from lib import hardware
from lib import loads
from lib import thermals
from lib import network

# Read the configuration settings
settings = config.read()

# Initialize logging router
logger = Router('resolver', globals.LOG_FILE_PATH)

if settings['debug'] == 'enabled':
  logger.set_level('DEBUG')

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

data = {}

logger.disk.debug(f'resolving static data at {str(datetime.now())}')

# Start resolving static data only once
data['release'] = run(release)
data['login'] = run(login)
data['hardware'] = run(hardware)

logger.disk.debug(f'static data resolved at {str(datetime.now())}')

# Loop endlessly resolving non-static data
while True:
  logger.disk.debug(f'resolving dynamic data at {str(datetime.now())}')

  data['uptime'] = run(uptime)
  data['loads'] = run(loads)
  data['thermals'] = run(thermals)
  data['network'] = run(network)

  logger.disk.debug(f'dynamic data resolved at {str(datetime.now())}')

  # Mark the last time resolving has occurred
  data['last'] = str(datetime.now())

  logger.disk.debug(f'resolved data: \n{str(data)}')

  logger.disk.debug('writing data to the disk...')

  # Write down the collected data to the disk
  with open(globals.DATA_FILE_PATH, 'w') as data_file:
    data_file.write(json.dumps(data))
    data_file.close()

  logger.disk.debug(f"data has been written to '{globals.DATA_FILE_PATH}'")

  logger.disk.debug(f'turning into the next resolve cycle...')

  # Wait before start the next cycle
  time.sleep(globals.RESOLVER_INTERVAL)