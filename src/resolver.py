#!/usr/bin/env python3
# An executable script resolving system data and status

import json
import time
from datetime import datetime
import logger
import globals
from core import Resolver

core = Resolver('core')
data = {}

logger.disk.info('Service started at: ' + str(datetime.now()))

while True:
  try:
    core.resolve()

    data['name'] = core.name
    data['last'] = core.last
  except Exception as error:
    logger.disk.trace(error)

  # Write down data into a json file
  with open(globals.DATA_FILE_PATH, 'w') as data_file:
    data_file.write(json.dumps(data))
    data_file.close()

  # Sleep for the next cycle
  time.sleep(globals.RESOLVER_INTERVAL)