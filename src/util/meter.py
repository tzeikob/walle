# A utility module to expose a speed metering class

from datetime import datetime

class Meter:

  def __init__ (self):
    self.value = 0
    self.last = datetime.now()
  
  def update (self, value):
    now = datetime.now()

    past_secs = (now - self.last).total_seconds()

    # Calculate the current speed, taking care of extreme values
    if self.value == 0 or self.value >= value or past_secs <= 0:
      self.speed = 0
    else:
      delta = value - self.value
      self.speed = delta / past_secs

    # Restore new values
    self.value = value
    self.last = now

  def reset (self):
    self.value = 0
    self.last = datetime.now()