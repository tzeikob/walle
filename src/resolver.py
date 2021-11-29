#!/usr/bin/env python3
# An executable script resolving system data and status

import json
import time
from datetime import datetime
import globals
import logger
from lib import uptime

data = {}

while True:
  try:
    logger.disk.info('gathering system data...')

    data['uptime'] = uptime.resolve()
    data['last'] = str(datetime.now())

    logger.disk.info('system data have been resolved')
  except Exception as error:
    # Just report and skip to the next cycle
    logger.disk.trace(error)

    time.sleep(globals.RESOLVER_INTERVAL)
    continue

  # Write down the collected data to the disk
  with open(globals.DATA_FILE_PATH, 'w') as data_file:
    data_file.write(json.dumps(data))
    data_file.close()

  # Wait before start the next cycle
  time.sleep(globals.RESOLVER_INTERVAL)