#!/usr/bin/env python3
# An opinionated tool to manage and configure conky for developers

import sys
import os
import re
import getpass
import logging
import argparse
from pathlib import Path
import ruamel.yaml
from ruamel.yaml.scalarstring import SingleQuotedScalarString as scalar

PKG_NAME = '#PKG_NAME'
HOME = str(Path.home())
BASE_DIR = HOME + '/.config/' + PKG_NAME
CONFIG_FILE_PATH = BASE_DIR + '/config.yml'
LOG_FILE_PATH = BASE_DIR + '/all.log'
PID_FILE_PATH = BASE_DIR + '/pid'

# Initialize logger with stdout/err and file streams
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

logger = Logger(LOG_FILE_PATH)

# Initialize yaml parser
yaml = ruamel.yaml.YAML()

# Aborts the process in fatal error: message, errcode
def abort (message, errcode):
  logger.error('Error: ' + message)
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
  if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9_\- ])*(:bold)?(:italic)?(:size=[1-9][0-9]?[0-9]?)?$', value):
    raise argparse.ArgumentTypeError("'%s' is not a valid conky font style value" % value)

  return value

# Reads and parses the config file to an object
def readConfig ():
  try:
    with open(CONFIG_FILE_PATH) as input:
      return yaml.load(input)
  except EnvironmentError:
    abort('failed to read the config file: ' + CONFIG_FILE_PATH, 1)

# Dumps the config object to a yaml file: config
def writeConfig (config):
  try:
    with open(CONFIG_FILE_PATH, 'w') as output:
      yaml.dump(config, output)
  except EnvironmentError:
    abort('failed to write to config file: ' + CONFIG_FILE_PATH, 1)

# Resolves the given arguments schema: prog
def resolveArgs (prog):
  parser = argparse.ArgumentParser(
    prog = prog,
    description = 'An opinionated tool to manage and configure conky for developers.',
    epilog = 'Have a nice %(prog)s time!')

  parser.add_argument(
    '-v', '--version',
    action = 'version',
    version = config['version'],
    help = 'show the version number and exit')

  subparsers = parser.add_subparsers(metavar = 'command', dest = 'command')

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

  return parser.parse_args()

# Returns if the conky process is up and running
def isProcessUp():
  if os.path.exists(PID_FILE_PATH):
    with open(PID_FILE_PATH) as input:
      pid = input.read()

      return os.path.exists('/proc/' + pid)
  else:
    return False

# Disalow calling this script as root user or sudo
if getpass.getuser() == 'root':
  abort("don't run this script as root user", 1)

# Load the configuration file
config = readConfig()

# Resolve given arguments
args = resolveArgs(PKG_NAME)

if args.command == 'start':
  logger.info('Todo: start conky process')
elif args.command == 'restart':
  logger.info('Todo: restart conky process')
elif args.command == 'stop':
  logger.info('Todo: stop conky process')
elif args.command == 'config':
  config['version'] = scalar(config['version'])

  if args.color != None:
    config['theme']['color'] = args.color
  
  if args.wall != None:
    config['theme']['wall'] = args.wall

  if args.time != None:
    config['theme']['fonts']['time'] = scalar(args.time)
  else:
    config['theme']['fonts']['time'] = scalar(config['theme']['fonts']['time'])

  if args.date != None:
    config['theme']['fonts']['date'] = scalar(args.date)
  else:
    config['theme']['fonts']['date'] = scalar(config['theme']['fonts']['date'])

  if args.text != None:
    config['theme']['fonts']['text'] = scalar(args.text)
  else:
    config['theme']['fonts']['text'] = scalar(config['theme']['fonts']['text'])

  if args.lang != None:
    config['system']['lang'] = args.lang

  if args.monitor != None:
    config['system']['monitor'] = args.monitor

  if args.debug != None:
    config['system']['debug'] = args.debug

  writeConfig(config)

  logger.info('Todo: restart conky process')

sys.exit(0)