# A module to expose various unit converters

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