#!/usr/bin/env python3
# An executable script resolving system data and status

import json
import time
from datetime import datetime
import globals
import logger
from lib import uptime
from lib import release
from lib import login

# Executes the resolve API of the given callback
def run (callback):
  result = None

  try:
    # Call the resolve method each cb should has
    result = callback.resolve()
  except Exception as error:
    # Just report and return none
    logger.disk.trace(error)

  return result

data = {}

# Start resolving static data only once
data['release'] = run(release)
data['login'] = run(login)

# Loop endlessly resolving non-static data
while True:
  logger.disk.info('gathering system data...')

  data['uptime'] = run(uptime)
  data['last'] = str(datetime.now())

  logger.disk.info('system data have been resolved')

  # Write down the collected data to the disk
  with open(globals.DATA_FILE_PATH, 'w') as data_file:
    data_file.write(json.dumps(data))
    data_file.close()

  # Wait before start the next cycle
  time.sleep(globals.RESOLVER_INTERVAL)