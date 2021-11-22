#!/usr/bin/env python3
# A python script to resolve system info and status

import time
from datetime import datetime
from util import Logger

PKG_NAME = '#PKG_NAME'
USER = '#USER'
CONFIG_DIR = '/home/' + USER + '/.config/' + PKG_NAME
DATA_FILE_PATH = CONFIG_DIR + '/.data'
LOG_FILE_PATH = CONFIG_DIR + '/logs/' + PKG_NAME + '.log'

logger = Logger(LOG_FILE_PATH)

while True:
  dt = str(datetime.now())

  with open(DATA_FILE_PATH, "a") as f:
    f.write('Date: ' + dt)
    f.close()

  logger.info('Added: ' + dt)
  time.sleep(1)