#!/usr/bin/env python3
# A python script used as entry point for the service process

import json
import time
from datetime import datetime
from util import Logger
from core import Resolver

PKG_NAME = '#PKG_NAME'
USER = '#USER'
CONFIG_DIR = '/home/' + USER + '/.config/' + PKG_NAME
DATA_FILE_PATH = CONFIG_DIR + '/.data'
LOG_FILE_PATH = CONFIG_DIR + '/logs/' + PKG_NAME + '.log'
INTERVAL_SECS = 1

logger = Logger(LOG_FILE_PATH)

core = Resolver('core')
data = {}

logger.info('Service started at: ' + str(datetime.now()))

while True:
  try:
    core.resolve()

    data['name'] = core.name
    data['last'] = core.last
  except Exception as error:
    logger.error('Error: ' + str(error))

  # Write down data into a json file
  with open(DATA_FILE_PATH, 'w') as data_file:
    data_file.write(json.dumps(data))
    data_file.close()

  # Sleep for the next cycle
  time.sleep(INTERVAL_SECS)