#!/usr/bin/env python3
# An opinionated tool to manage and configure conky for developers

import sys
import os
import subprocess
import time
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
CONKYRC_FILE_PATH = BASE_DIR + '/.conkyrc'
LOG_FILE_PATH = BASE_DIR + '/all.log'
PID_FILE_PATH = BASE_DIR + '/pid'

# Logger with stdout/err and file handlers
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

# Aborts the process in fatal error: message, errcode
def abort (message, errcode):
  logger.error('Error: ' + message)
  sys.exit(errcode)

# Asserts if the given value is a zero positive integer: value
def zeroPosInt (value):
  try:
    number = int(value)
    if number < 0:
      raise argparse.ArgumentTypeError("'%s' is not a zero positive int value" % value)

    return number
  except ValueError:
    raise argparse.ArgumentTypeError("'%s' is not a zero positive int value" % value)

# Asserts if the given value is a positive integer: value
def posInt (value):
  try:
    number = int(value)
    if number <= 0:
      raise argparse.ArgumentTypeError("'%s' is not a positive int value" % value)

    return number
  except ValueError:
    raise argparse.ArgumentTypeError("'%s' is not a positive int value" % value)

# Asserts if the given value is a conky valid font style value: value
def fontStyle (value):
  if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9_\- ])*(:bold)?(:italic)?(:size=[1-9][0-9]?[0-9]?)?$', value):
    raise argparse.ArgumentTypeError("'%s' is not a valid conky font style value" % value)

  return value

# Reads and parses the config file to an object
def readConfig ():
  try:
    with open(CONFIG_FILE_PATH) as config_file:
      cfg = yaml.load(config_file)

      # Recover string scalar values
      cfg['version'] = scalar(cfg['version'])

      for i, line in enumerate(cfg['theme']['lines']):
        cfg['theme']['lines'][i]['font'] = scalar(line['font'])
        cfg['theme']['lines'][i]['text'] = scalar(line['text'])

      return cfg
  except EnvironmentError:
    abort('failed to read the config file', 1)

# Dumps the config object to a yaml file: config
def writeConfig (config):
  try:
    with open(CONFIG_FILE_PATH, 'w') as config_file:
      yaml.dump(config, config_file)
  except EnvironmentError:
    abort('failed to write to config file', 1)

# Resolves the given arguments schema: prog
def resolveArgs (prog):
  parser = argparse.ArgumentParser(
    prog=prog,
    description='An opinionated tool to manage and configure conky for developers.',
    epilog='Have a nice %(prog)s time!')

  parser.add_argument(
    '-v', '--version',
    action='version',
    version=config['version'],
    help='show the version number and exit')

  subparsers = parser.add_subparsers(metavar='command', dest='command')
  subparsers.required = True

  subparsers.add_parser('start', help='start %(prog)s spawning the conky process')
  subparsers.add_parser('restart', help='restart %(prog)s respawning the conky process')
  subparsers.add_parser('stop', help='stop %(prog)s killing the conky process')

  configParser = subparsers.add_parser('config', help='configure %(prog)s and restart the conky process')

  configParser.add_argument(
    '-m', '--mode',
    choices=['light', 'dark'],
    metavar='mode',
    help="set the theme color mode to 'light' or 'dark'")

  configParser.add_argument(
    '-w', '--wallpaper',
    type=zeroPosInt,
    metavar='secs',
    help='set the interval time the wallpaper should rotate by')

  configParser.add_argument(
    '--monitor',
    type=zeroPosInt,
    metavar='index',
    help='set the monitor index the conky should render at')

  configParser.add_argument(
    '--debug',
    choices=['enabled', 'disabled'],
    metavar='mode',
    help="set debug mode to 'enabled' or 'disabled'")

  addParser = subparsers.add_parser('add', help='add a conky text line')

  addParser.add_argument(
    '-t', '--text',
    metavar='text',
    required=True,
    help='a conky text line')

  addParser.add_argument(
    '-f', '--font',
    type=fontStyle,
    metavar='font',
    help='a font style the text line should appear with')

  updateParser = subparsers.add_parser('update', help='update a conky text line')

  updateParser.add_argument(
    '-l', '--line',
    type=posInt,
    metavar='index',
    required=True,
    help='the index of the text line to update')

  updateParser.add_argument(
    '-t', '--text',
    metavar='text',
    help='a conky text line')
  
  updateParser.add_argument(
    '-f', '--font',
    type=fontStyle,
    metavar='font',
    help='a font style the text line should appear with')

  removeParser = subparsers.add_parser('remove', help='remove a conky text line')

  removeParser.add_argument(
    '-l', '--line',
    type=posInt,
    metavar='index',
    required=True,
    help='the index of the text line to remove')

  return parser.parse_args()

# Read the pid of the pid file
def readPid ():
  if os.path.exists(PID_FILE_PATH):
    with open(PID_FILE_PATH) as pid_file:
      return pid_file.read().strip()
  else:
    return None

# Returns if the conky process is up and running
def isUp ():
  pid = readPid()
  return os.path.exists('/proc/' + str(pid))

# Spawns the conky process: silent
def start (silent=False):
  if isUp():
    if not silent: logger.info('Conky is already up and running')
    return

  # Launch the conky process
  with open(LOG_FILE_PATH, 'a') as log_file:
    try:
      process = subprocess.Popen(
        ['conky', '-b', '-p', '1', '-c', CONKYRC_FILE_PATH],
        stdout=log_file,
        stderr=log_file,
        universal_newlines=True)
    except:
      abort('failed to spawn the conky process', 1)

    # Give time to conky to be spawn
    time.sleep(2)

    # Check if the process has failed to spawn
    returncode = process.poll()
    if returncode != None and returncode != 0:
      abort('failed to spawn the conky process', 1)

    # Save the conky process id in the file system
    with open(PID_FILE_PATH, 'w') as pid_file:
      pid_file.write(str(process.pid))

  if isUp():
    if not silent: logger.info('Conky is up and running')
  else:
    abort('failed to spawn the conky process', 1)

# Stops the running conky process: silent
def stop (silent=False):
  if isUp():
    pid = readPid()

    # Kill conky process given the pid
    with open(LOG_FILE_PATH, 'a') as log_file:
      try:
        process = subprocess.run(
          ['kill', str(pid)],
          stdout=log_file,
          stderr=log_file,
          universal_newlines=True)
      except:
        abort('failed to kill the conky process', 1)

    if process.returncode != 0:
      abort('failed to kill the conky process', 1)

    os.remove(PID_FILE_PATH)

    if not silent: logger.info('Conky is now shut down')
  else:
    if not silent: logger.info('Conky is already shut down')

# Restart the conky process
def restart():
  if isUp():
    stop(True)
    time.sleep(1)
    start(True)

    logger.info('Conky has been restarted')
  else:
    start()

# Write the conky monitor directly to the conkyrc file
def writeConkyMonitor (index):
  if not os.path.exists(CONKYRC_FILE_PATH):
    abort('failed to write monitor index: missing conkyrc file', 1)

  newContent = ''

  with open(CONKYRC_FILE_PATH, 'r') as conkyrc_file:
    for line in conkyrc_file:
      if re.match(r'^[ ]*xinerama_head[ ]*=[ ]*[0-9]+[ ]*,[ ]*$', line):
        line = '    xinerama_head = ' + str(index) + ',\n'
      newContent += line

  with open(CONKYRC_FILE_PATH, 'w') as conkyrc_file:
    conkyrc_file.write(newContent)

# Initialize logger
logger = Logger(LOG_FILE_PATH)

# Initialize yaml parser
yaml = ruamel.yaml.YAML()

# Load the configuration file
config = readConfig()

# Resolve given arguments
args = resolveArgs(PKG_NAME)

# Disalow calling this script as root user or sudo
if getpass.getuser() == 'root':
  abort("don't run this script as root user", 1)

if args.command == 'start':
  start()
elif args.command == 'stop':
  stop()
elif args.command == 'restart':
  restart()
elif args.command == 'config':
  if args.mode != None:
    config['theme']['mode'] = args.mode

  if args.wallpaper != None:
    config['theme']['wallpaper'] = args.wallpaper

  if args.monitor != None:
    config['system']['monitor'] = args.monitor
    writeConkyMonitor(args.monitor)

  if args.debug != None:
    config['system']['debug'] = args.debug

  writeConfig(config)

  if isUp():
    restart()
elif args.command == 'add':
  config['theme']['lines'].append({
    'font': scalar(args.font) if args.font else scalar(''),
    'text': scalar(args.text)
  })

  writeConfig(config)
elif args.command == 'update':
  idx = args.line - 1

  if idx < len(config['theme']['lines']):
    if not args.font and not args.text:
      abort('at least one of --text or --font arg must be given', 1)

    if args.font:
      config['theme']['lines'][idx]['font'] = scalar(args.font)
    
    if args.text:
      config['theme']['lines'][idx]['text'] = scalar(args.text)
  else:
    abort("no text line with index '" + str(args.line) + "'", 1)

  writeConfig(config)
elif args.command == 'remove':
  idx = args.line - 1

  if idx < len(config['theme']['lines']):
    del config['theme']['lines'][idx]
  else:
    abort("no text line with index '" + str(args.line) + "'", 1)

  writeConfig(config)

sys.exit(0)