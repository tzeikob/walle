# A module exporting the arguments parser

import argparse
import re

# Asserts if the given value is a zero positive integer
def zero_pos_int (value):
  try:
    number = int(value)
    if number < 0:
      raise argparse.ArgumentTypeError("'%s' is not a zero positive int value" % value)

    return number
  except ValueError:
    raise argparse.ArgumentTypeError("'%s' is not a zero positive int value" % value)

# Asserts if the given value is a positive integer
def pos_int (value):
  try:
    number = int(value)
    if number <= 0:
      raise argparse.ArgumentTypeError("'%s' is not a positive int value" % value)

    return number
  except ValueError:
    raise argparse.ArgumentTypeError("'%s' is not a positive int value" % value)

# Asserts if the given value is a conky valid font style value
def font_style (value):
  if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9_\- ])*(:bold)?(:italic)?(:size=[1-9][0-9]?[0-9]?)?$', value):
    raise argparse.ArgumentTypeError("'%s' is not a valid conky font style value" % value)

  return value

# Parses the args schema to the given args
def parse (name, version):
  parser = argparse.ArgumentParser(
    prog=name,
    description='An opinionated tool to manage and configure conky for developers.',
    epilog='Have a nice %(prog)s time!')

  parser.add_argument(
    '-v', '--version',
    action='version',
    version=version,
    help='show the version number and exit')

  subparsers = parser.add_subparsers(metavar='command', dest='command')
  subparsers.required = True

  subparsers.add_parser('start', help='start %(prog)s spawning the conky process')
  subparsers.add_parser('restart', help='restart %(prog)s respawning the conky process')
  subparsers.add_parser('stop', help='stop %(prog)s killing the conky process')
  subparsers.add_parser('reset', help='reset %(prog)s back to default settings')

  configParser = subparsers.add_parser('config', help='configure %(prog)s and restart the conky process')

  configParser.add_argument(
    '--head',
    metavar='text',
    help="set the text which will appear as head line")

  configParser.add_argument(
    '-m', '--mode',
    choices=['light', 'dark'],
    metavar='mode',
    help="set the theme color mode to 'light' or 'dark'")

  configParser.add_argument(
    '-f', '--font',
    type=font_style,
    metavar='font',
    help='set the font style the text should appear with')

  configParser.add_argument(
    '-w', '--wallpapers',
    metavar='path',
    help='set the path to a folder containing wallpaper image files')

  configParser.add_argument(
    '-i', '--interval',
    type=zero_pos_int,
    metavar='secs',
    help='set the interval in secs the wallpaper should randomly rotate by')

  configParser.add_argument(
    '--monitor',
    type=zero_pos_int,
    metavar='index',
    help='set the monitor index the conky should render at')

  configParser.add_argument(
    '--debug',
    choices=['enabled', 'disabled'],
    metavar='mode',
    help="set debug mode to 'enabled' or 'disabled'")

  presetParser = subparsers.add_parser('preset', help='save or load %(prog)s preset files')
  presetGroup = presetParser.add_mutually_exclusive_group()

  presetGroup.add_argument(
    '--save',
    metavar='path',
    help="set the file path the preset will be saved in")

  presetGroup.add_argument(
    '--load',
    metavar='path',
    help="set the file path the preset will be loaded from")

  return parser.parse_args()