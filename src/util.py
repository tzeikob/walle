# A module exporting generic utilities

import sys
import logging

class Logger:
  def __init__ (self, filepath):
    self.file = logging.getLogger('file')
    self.file.addHandler(logging.FileHandler(filepath))
    self.file.setLevel(logging.INFO)

    self.stdout = logging.getLogger('stdout')
    self.stdout.addHandler(logging.StreamHandler(sys.stdout))
    self.stdout.setLevel(logging.INFO)

    self.stderr = logging.getLogger('stderr')
    self.stderr.addHandler(logging.StreamHandler(sys.stderr))
    self.stderr.setLevel(logging.ERROR)

  def info (self, message):
    self.stdout.info(message)
    self.file.info(message)

  def error (self, message):
    self.stderr.error(message)
    self.file.error(message)