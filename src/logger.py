# A module exporting the logging router class

import sys
import logging
from logging import StreamHandler, FileHandler

class Route:
  def __init__ (self, scope, name, handler, level):
    self.scope = scope
    self.logger = logging.getLogger(name)
    self.logger.addHandler(handler)
    self.logger.setLevel(level)

  def info (self, message):
    self.logger.info(f'{self.scope}: {message}')

  def warn (self, message):
    self.logger.warning(f'{self.scope}: {message}')

  def debug (self, message):
    self.logger.debug(f'{self.scope}: {message}')

  def error (self, message):
    self.logger.error(f'{self.scope}: {message}')

  def trace (self, error):
    self.error(error)
    self.logger.exception(error)

  def set_level (self, level):
    self.logger.setLevel(level)

    for handler in self.logger.handlers:
      handler.setLevel(level)

class Router:
  def __init__ (self, scope, filepath):
    self.stdout = Route(scope, scope + '.stdout', StreamHandler(sys.stdout), 'INFO')
    self.stderr = Route(scope, scope + '.stderr', StreamHandler(sys.stderr), 'ERROR')

    if filepath:
      self.disk = Route(scope, scope + '.disk', FileHandler(filepath), 'INFO')

  def set_level (self, level):
    self.stdout.set_level(level)

    if self.disk:
      self.disk.set_level(level)