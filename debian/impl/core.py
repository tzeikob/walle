# A module exporting debian core resolving implementations

from datetime import datetime

class Resolver:
  def __init__ (self, name):
    self.sys = 'debian'
    self.name = name
    self.last = str(datetime.now())

  def resolve (self):
    self.last = str(datetime.now())