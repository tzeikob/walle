# A module exporting conversion methods

# Converts the given value into a trimmed lowercase string
def text (value):
  if value != None:
    value = str(value).lower().strip()

  return value

# Converts the given value into an integer
def integer (value):
  return int(value)

# Converts the given value into a rounded decimal
def decimal (value, precision):
  value = float(value)

  if precision > 0:
    value = round(value, precision)
  elif precision == 0:
    value = round(value)

  return value

# Converts bytes to kilobytes
def KB (bytes):
  return bytes / 1024

# Converts bytes to megabytes
def MB (bytes):
  return bytes / (1024 ** 2)

# Converts bytes to gigabytes
def GB (bytes):
  return bytes / (1024 ** 3)

# Converts bytes to terabytes
def TB (bytes):
  return bytes / (1024 ** 4)

# Converts bytes to bits
def b (bytes):
  return bytes * 8

# Converts bytes to kilobits
def Kb (bytes):
  return b(bytes) / 1024

# Converts bytes to megabits
def Mb (bytes):
  return b(bytes) / (1024 ** 2)

# Converts bytes to gigabits
def Gb (bytes):
  return b(bytes) / (1024 ** 3)