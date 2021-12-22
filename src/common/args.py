# A module exporting the arguments parser

import argparse
import re

# Asserts if the given value is a zero positive integer
def zero_pos_int (value):
  try:
    number = int(value)
  except ValueError:
    raise argparse.ArgumentTypeError("'%s' is not an integer value" % value)
  
  if number < 0:
    raise argparse.ArgumentTypeError("'%s' is not a zero positive integer value" % value)

  return number

# Asserts if the given value is a conky valid font style value
def font_style (value):
  if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9_\- ])*(:bold)?(:italic)?(:size=[1-9][0-9]?[0-9]?)?$', value):
    raise argparse.ArgumentTypeError("'%s' is not a valid conky font style value" % value)

  return value

# Parses the args schema to the given args
def parse (name, version):
  parser = argparse.ArgumentParser(
    prog=name,
    description='An opinionated desktop widget for linux based developers.',
    epilog='Have a nice %(prog)s time!')

  parser.add_argument(
    '-v', '--version',
    action='version',
    version=version,
    help='show the version number and exit')

  subparsers = parser.add_subparsers(metavar='command', dest='command')
  subparsers.required = True

  subparsers.add_parser('start', help='launch %(prog)s widget')
  subparsers.add_parser('restart', help='restart %(prog)s widget')
  subparsers.add_parser('stop', help='stop %(prog)s widget')
  subparsers.add_parser('reset', help='reset %(prog)s back to its default settings')

  configParser = subparsers.add_parser('config', help='change configuration settings and restart')

  configParser.add_argument(
    '--head',
    metavar='text',
    help='the text which will appear as head line')

  configParser.add_argument(
    '-m', '--mode',
    choices=['light', 'dark'],
    metavar='mode',
    help="the theme color mode either 'light' or 'dark'")

  configParser.add_argument(
    '-f', '--font',
    type=font_style,
    metavar='font',
    help='the font style the text should appear with')

  configParser.add_argument(
    '--monitor',
    type=zero_pos_int,
    metavar='index',
    help='the monitor index the widget should render on (experimental)')

  configParser.add_argument(
    '--debug',
    choices=['enabled', 'disabled'],
    metavar='mode',
    help="the debug mode either 'enabled' or 'disabled'")

  presetParser = subparsers.add_parser('preset', help='save and load %(prog)s preset files')
  presetGroup = presetParser.add_mutually_exclusive_group()

  presetGroup.add_argument(
    '--save',
    metavar='path',
    help='the path the preset file will be saved to')

  presetGroup.add_argument(
    '--load',
    metavar='path',
    help='the path the preset file will be loaded from')

  return parser.parse_args()