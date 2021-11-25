# A module exporting the logger

import os
import sys
import logging

PKG_NAME = '#PKG_NAME'
BASE_DIR = os.path.expanduser('~/.config/') + PKG_NAME
LOG_FILE_PATH = BASE_DIR + 'all.log'

stdout = logging.getLogger('stdout')
stdout.addHandler(logging.StreamHandler(sys.stdout))
stdout.setLevel(logging.INFO)

stderr = logging.getLogger('stderr')
stderr.addHandler(logging.StreamHandler(sys.stderr))
stderr.setLevel(logging.ERROR)

log_file = logging.getLogger('file')
log_file.addHandler(logging.FileHandler(LOG_FILE_PATH))
log_file.setLevel(logging.INFO)

def info (message):
  stdout.info(message)
  log_file.info(message)

def error (message):
  stderr.error(message)
  log_file.error(message)