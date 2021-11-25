# A module to export global constants and variables

import os

PKG_NAME = '#PKG_NAME'
BASE_DIR = os.path.expanduser('~/.config/') + PKG_NAME

CONFIG_FILE_PATH = BASE_DIR + '/config.yml'
CONKYRC_FILE_PATH = BASE_DIR + '/.conkyrc'
LOG_FILE_PATH = BASE_DIR + '/logs/' + PKG_NAME + '.log'
CONKY_LOG_FILE_PATH = BASE_DIR + '/logs/conky.log'
CONKY_PID_FILE_PATH = BASE_DIR + '/conky.pid'