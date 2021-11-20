#!/usr/bin/env python3
# A python script to resolve system info and status

import time
from datetime import datetime

PKG_NAME = '#PKG_NAME'
BASE_DIR = '/usr/share/' + PKG_NAME
DATA_FILE_PATH = BASE_DIR + '/.data'

while True:
  with open(DATA_FILE_PATH, "a") as f:
    f.write("Date: " + str(datetime.now()))
    f.close()
  time.sleep(1)