#!/usr/bin/env python3
# An opinionated tool to manage and configure conky for developers

import sys
import os
import getpass
import argparse
import yaml
from yaml.loader import SafeLoader
from pathlib import Path

PKG_NAME = '#PKG_NAME'
HOME = str(Path.home())
BASE_DIR = HOME + '/.config/' + PKG_NAME
CONFIG_FILE_PATH = BASE_DIR + '/config.yml'
PID_FILE_PATH = BASE_DIR + '/pid'

# Aborts the process in fatal error: message, errcode
def abort (message, errcode):
  print('Error: ' + message)
  sys.exit(errcode)

# Reads and parses the config file to dict object
def readConfig ():
  with open(CONFIG_FILE_PATH) as input:
    return yaml.load(input, Loader = SafeLoader)

# Dumps the config object to a yaml file: config
def writeConfig (config):
  with open(CONFIG_FILE_PATH, 'w') as output:
    output.write(yaml.dump(config))

# Returns if the process is up and running
def isProcessUp():
  if os.path.exists(PID_FILE_PATH):
    with open(PID_FILE_PATH) as input:
      pid = input.read()

      return os.path.exists("/proc/" + pid)
  else:
    return False

# Disalow calling this script as root user or sudo
if getpass.getuser() == "root":
  abort("don't run this script as root user")

# Load the configuration file
config = readConfig()

# Build up the arguments schema
prs = argparse.ArgumentParser(description = 'An opinionated tool to manage and configure conky for developers')

prs.add_argument('operation', choices = ['start', 'stop', 'config'], help = 'Start, stop or configure the process')
prs.add_argument('-v', '--version', action = 'version', version = config['version'], help = 'Show the version number and exit')

grp = prs.add_argument_group('Configuration options')
grp.add_argument('-t', '--theme', choices = ['light', 'dark'], default = 'light', help = 'Set the theme color')
grp.add_argument('-w', '--wallpaper', type = int, default = 3600, help = 'Set the wallpaper rotation interval time in secs')

opts = prs.parse_args()

print(opts)