#!/usr/bin/env python3

import argparse
import signal
from common import globals
from util.logger import Router
from resolvers import static
from resolvers import uptime
from resolvers import monitor
from resolvers import network
from listeners import keyboard, mouse
from render import ui, canvas

# Parse command line arguments schema
parser = argparse.ArgumentParser(prog='app')

parser.add_argument('--debug', dest='debug', action='store_true')
parser.add_argument('--no-debug', dest='debug', action='store_false')
parser.set_defaults(debug=False)

opts = parser.parse_args()

# Initialize logging router
logger = Router('app', globals.LOG_FILE_PATH)

if opts.debug:
  logger.set_level('DEBUG')

def main ():
  signal.signal(signal.SIGINT, signal.SIG_DFL)

  # Resolve once the system's static information
  static.resolve()

  # Start monitoring system uptime, loads and network
  uptime.start()
  monitor.start()
  network.start()

  # Start listening for keyboard and mouse events
  keyboard.start()
  mouse.start()

  win = ui.Window(canvas)
  win.launch()

if __name__ == '__main__':
  main()