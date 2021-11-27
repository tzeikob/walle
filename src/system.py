# A module exporting system utility methods

import sys
import os
import time
import subprocess
import getpass
import globals

# Abort if user in context is root or sudo used
if getpass.getuser() == 'root':
  print("[Errno 13] Don't run as root user")
  exit(1)

# Aborts the process in fatal error
def exit (errcode):
  sys.exit(errcode)

# Returns if the process with the given pid is up and running
def isUp (pid):
  return os.path.exists('/proc/' + str(pid))

# Spawns a new process given the command
def spawn (command):
  with open(globals.LOG_FILE_PATH, 'a') as log_file:
    process = subprocess.Popen(
      command.split(),
      stdout=log_file,
      stderr=log_file,
      universal_newlines=True)

  # Give time to the process to be spawn
  time.sleep(2)

  # Check if the process has failed to be spawn
  code = process.poll()

  if code != None and code != 0:
    raise Exception(f"[Errno 3] Failed to spawn process: '{str(command)}'")

  return process.pid

# Kills the process identified by the given pid
def kill (pid):
  if not isUp(pid):
    return False

  with open(globals.LOG_FILE_PATH, 'a') as log_file:
    process = subprocess.run(
      ['kill', str(pid)],
      stdout=log_file,
      stderr=log_file,
      universal_newlines=True)

  if process.returncode != 0:
    raise Exception(f"[Errno 3] Failed to kill process: '{str(pid)}'")

  return True

# Writes the given data to the file with the given path
def write (path, data):
  with open(path, 'w') as output_file:
    output_file.write(str(data))

# Reads the contents of file with the given path
def read (path):
  if os.path.exists(path):
    with open(path) as input_file:
      return input_file.read().strip()
  else:
    return None

# Removes the file with the given path
def remove (path):
  os.remove(path)