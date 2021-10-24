#!/usr/bin/env python3
# An opinionated tool to manage and configure conky for developers

import sys
import os
import re
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

# Asserts if the given value is a seconds value
def posInt (value):
  try:
    number = int(value)
    if number < 0:
      raise argparse.ArgumentTypeError("'%s' is not a positive int value" % value)

    return number
  except ValueError:
    raise argparse.ArgumentTypeError("'%s' is not a positive int value" % value)

# Asserts if the given value is a conky valid font style value
def fontStyle (value):
  if not re.match(r'^([a-zA-Z0-9_\- ])+(:bold)?(:italic)?(:size=[1-9][0-9]?[0-9]?)?$', value):
    raise argparse.ArgumentTypeError("'%s' is not a valid conky font style value" % value)

  return value

# Reads and parses the config file to an object
def readConfig ():
  with open(CONFIG_FILE_PATH) as input:
    return yaml.load(input, Loader = SafeLoader)

# Dumps the config object to a yaml file: config
def writeConfig (config):
  with open(CONFIG_FILE_PATH, 'w') as output:
    output.write(yaml.dump(config, sort_keys = False))

# Returns if the process is up and running
def isProcessUp():
  if os.path.exists(PID_FILE_PATH):
    with open(PID_FILE_PATH) as input:
      pid = input.read()

      return os.path.exists('/proc/' + pid)
  else:
    return False

# Disalow calling this script as root user or sudo
if getpass.getuser() == 'root':
  abort("don't run this script as root user")

# Load the configuration file
config = readConfig()

# Build up the arguments schema
parser = argparse.ArgumentParser(
  prog = PKG_NAME,
  description = 'An opinionated tool to manage and configure conky for developers.',
  epilog = 'Have a nice %(prog)s time!')

parser.add_argument(
  '-v', '--version',
  action = 'version',
  version = config['version'],
  help = 'show the version number and exit')

subparsers = parser.add_subparsers(
  title = 'command',
  dest = 'command',
  metavar = 'start, restart, stop, config')

subparsers.add_parser('start', help = 'start %(prog)s spawning the conky process')
subparsers.add_parser('restart', help = 'restart %(prog)s respawning the conky process')
subparsers.add_parser('stop', help = 'stop %(prog)s killing the conky process')

configParser = subparsers.add_parser('config', help = 'configure %(prog)s and restart the conky process')

configParser.add_argument(
  '-c', '--color',
  choices = ['light', 'dark'],
  metavar = 'mode',
  help = "set the theme color mode to 'light' or 'dark'")

configParser.add_argument(
  '-w', '--wall',
  type = posInt,
  metavar = 'secs',
  help = 'set the interval time the wallpaper should rotate by')

configParser.add_argument(
  '-t', '--time',
  type = fontStyle,
  metavar = 'font',
  help = 'set the font and style used in time line')

configParser.add_argument(
  '-d', '--date',
  type = fontStyle,
  metavar = 'font',
  help = 'set the font and style used in date line')

configParser.add_argument(
  '-x', '--text',
  type = fontStyle,
  metavar = 'font',
  help = 'set the font and style used in the text lines')

configParser.add_argument(
  '-l', '--lang',
  choices = ['en', 'el'],
  metavar = 'code',
  help = 'set the language code texts should appear in')

configParser.add_argument(
  '--monitor',
  type = posInt,
  metavar = 'index',
  help = 'set the monitor index the conky should render at')

configParser.add_argument(
  '--debug',
  choices = ['enabled', 'disabled'],
  metavar = 'mode',
  help = "set debug mode to 'enabled' or 'disabled'")

args = parser.parse_args()

if args.command == 'start':
  print('Todo: start conky process')
elif args.command == 'restart':
  print('Todo: restart conky process')
elif args.command == 'stop':
  print('Todo: stop conky process')
elif args.command == 'config':
  if args.color: config['theme']['color'] = args.color
  if args.wall: config['theme']['wall'] = args.wall

  if args.time: config['theme']['fonts']['time'] = args.time
  if args.date: config['theme']['fonts']['date'] = args.date
  if args.text: config['theme']['fonts']['text'] = args.text

  if args.lang: config['system']['lang'] = args.lang
  if args.monitor: config['system']['monitor'] = args.monitor
  if args.debug: config['system']['debug'] = args.debug

  writeConfig(config)

  print('Todo: restart conky process')

sys.exit(0)