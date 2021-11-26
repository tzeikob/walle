# A module exporting system utility methods

import sys
import os
import time
import subprocess
import globals

# Aborts the process in fatal error
def exit (errcode):
  sys.exit(errcode)

# Returns if the process with the given pid is up and running
def isUp (pid):
  return os.path.exists('/proc/' + str(pid))

# Spawns a new process given the command
def spawn (command):
  with open(globals.LOG_FILE_PATH, 'a') as log_file:
    try:
      process = subprocess.Popen(
        command.split(),
        stdout=log_file,
        stderr=log_file,
        universal_newlines=True)
    except Exception as error:
      raise Exception('Failed to execute command: ' + str(error))

  # Give time to the process to be spawn
  time.sleep(2)

  # Check if the process has failed to be spawn
  returncode = process.poll()

  if returncode != None and returncode != 0:
    raise Exception('Failed to spawn the process: ' + str(command))

  return process.pid

# Kills the process identified by the given pid
def kill (pid):
  if isUp(pid):
    with open(globals.LOG_FILE_PATH, 'a') as log_file:
      try:
        process = subprocess.run(
          ['kill', str(pid)],
          stdout=log_file,
          stderr=log_file,
          universal_newlines=True)
      except Exception as error:
        raise Exception('Failed to execute kill command: ' + str(error))

    if process.returncode != 0:
      raise Exception('Failed to kill the process: ' + str(pid))

    return True
  else:
    return False

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