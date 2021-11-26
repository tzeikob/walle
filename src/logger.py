# A module exporting the logger

import sys
import logging
import globals

stdout = logging.getLogger('stdout')
stdout.addHandler(logging.StreamHandler(sys.stdout))
stdout.setLevel(logging.INFO)

stderr = logging.getLogger('stderr')
stderr.addHandler(logging.StreamHandler(sys.stderr))
stderr.setLevel(logging.ERROR)

log_file = logging.getLogger('file')
log_file.addHandler(logging.FileHandler(globals.LOG_FILE_PATH))
log_file.setLevel(logging.INFO)

def info (message):
  stdout.info(message)
  log_file.info(message)

def error (message):
  stderr.error(message)
  log_file.error(message)