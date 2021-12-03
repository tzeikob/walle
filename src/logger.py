# A module exporting the logging routers

import sys
import logging
import globals

class Router:
  def __init__(self, name, handler, level):
    self.logger = logging.getLogger(name)
    self.logger.addHandler(handler)
    self.logger.setLevel(level)

  def info (self, message):
    self.logger.info(f'{globals.PKG_NAME}: {message}')
  
  def error (self, message):
    self.logger.error(f'{globals.PKG_NAME}: {message}')
  
  def trace (self, error):
    self.logger.exception(error)

stdout = Router('stdout', logging.StreamHandler(sys.stdout), logging.INFO)
stderr = Router('stderr', logging.StreamHandler(sys.stderr), logging.ERROR)
disk = Router('disk', logging.FileHandler(globals.LOG_FILE_PATH), logging.INFO)