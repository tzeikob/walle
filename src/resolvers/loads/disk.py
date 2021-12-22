# A monitoring resolver to resolve disk loads

from datetime import datetime
import psutil
from convert import integer, decimal, MB

# Last date time since the last call
last = datetime.now()

# Read and written bytes since the last call
last_read = 0
last_write = 0

# Returns a data object populated with disk load data
def resolve ():
  # Calculate the secs past since the last call
  now = datetime.now()

  global last
  past_secs = (now - last).total_seconds()

  # Save last checkpoint for the next call
  last = now

  # Read system-wide disk read and write io counters
  io = psutil.disk_io_counters()

  read = io.read_bytes
  write = io.write_bytes

  # Calculate current read and write speeds
  global last_read, last_write

  # Report zero read speed in case of invalid read values
  if last_read == 0 or last_read >= read or past_secs <= 0:
    read_speed = 0
  else:
    delta = read - last_read
    read_speed = delta / past_secs

  # Report zero write speed in case of invalid write values
  if last_write == 0 or last_write >= write or past_secs <= 0:
    write_speed = 0
  else:
    delta = write - last_write
    write_speed = delta / past_secs

  # Save last read and write values
  last_read = read
  last_write = write

  data = {
    'read': {
      'bytes': integer(MB(read)),
      'speed': decimal(MB(read_speed), 1)
    },
    'write': {
      'bytes': integer(MB(write)),
      'speed': decimal(MB(write_speed), 1)
    }
  }

  # Use psutil to get all disk partitions
  partitions = psutil.disk_partitions()

  # Match only partitions mounted at root and home paths
  for partition in partitions:
    mountpoint = partition.mountpoint

    if mountpoint == '/' or mountpoint == '/home':
      fstype = partition.fstype
      disk = psutil.disk_usage(mountpoint)
      util = disk.percent
      used = disk.used
      free = disk.free

      data[mountpoint] = {
        'type': fstype,
        'util': decimal(util, 1),
        'used': integer(MB(used)),
        'free': integer(MB(free))
      }

  return data