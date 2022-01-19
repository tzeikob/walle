# A module exporting the arguments parser

import argparse
import re

# Asserts if the given value is an integer
def any_int (value):
  try:
    number = int(value)
  except ValueError:
    raise argparse.ArgumentTypeError("'%s' is not an integer value" % value)

  return number

# Asserts if the given value is a zero positive integer
def zero_pos_int (value):
  try:
    number = int(value)
  except ValueError:
    raise argparse.ArgumentTypeError("'%s' is not an integer value" % value)
  
  if number < 0:
    raise argparse.ArgumentTypeError("'%s' is not a zero positive integer value" % value)

  return number

# Asserts if the given value is a positive integer
def pos_int (value):
  try:
    number = int(value)
  except ValueError:
    raise argparse.ArgumentTypeError("'%s' is not an integer value" % value)
  
  if number <= 0:
    raise argparse.ArgumentTypeError("'%s' is not a positive integer value" % value)

  return number

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

  startParser = subparsers.add_parser('start', help='launch %(prog)s widget')

  startParser.add_argument(
    '--debug',
    dest='debug',
    action='store_true',
    help='enable debug mode')

  startParser.add_argument(
    '--no-debug',
    dest='debug',
    action='store_false',
    help='disabled debug mode')

  startParser.set_defaults(debug=False)

  subparsers.add_parser('restart', help='restart %(prog)s widget')
  subparsers.add_parser('stop', help='stop %(prog)s widget')
  subparsers.add_parser('reset', help='reset %(prog)s back to its default settings')

  configParser = subparsers.add_parser('config', help='change configuration settings and restart')

  configParser.add_argument(
    '--head',
    metavar='text',
    help='the text which will appear as head line')

  configParser.add_argument(
    '--dark',
    dest='dark',
    action='store_true',
    help='enable dark mode')

  configParser.add_argument(
    '--no-dark',
    dest='dark',
    action='store_false',
    help='disabled dark mode')

  configParser.set_defaults(dark=False)

  configParser.add_argument(
    '--scale',
    type=pos_int,
    metavar='number',
    help="an integer factor the viewport should be scaled by")

  configParser.add_argument(
    '--top',
    type=any_int,
    metavar='pixels',
    help="the offset the viewport's top edge should be shifted by")

  configParser.add_argument(
    '--left',
    type=any_int,
    metavar='pixels',
    help="the offset the viewport's left edge should be shifted by")

  configParser.add_argument(
    '--bottom',
    type=any_int,
    metavar='pixels',
    help="the offset the viewport's bottom edge should be shifted by")

  configParser.add_argument(
    '--right',
    type=any_int,
    metavar='pixels',
    help="the offset the viewport's right edge should be shifted by")

  configParser.add_argument(
    '--monitor',
    type=zero_pos_int,
    metavar='index',
    help='the monitor index the widget should render on (experimental)')

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