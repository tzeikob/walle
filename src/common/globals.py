# A module exporting global constants and variables

import os

PKG_VERSION = '#PKG_VERSION'
PKG_NAME = '#PKG_NAME'
BASE_DIR = os.path.expanduser('~/.config') + '/' + PKG_NAME

CONFIG_FILE_PATH = BASE_DIR + '/config.yml'
CONKYRC_FILE_PATH = BASE_DIR + '/.conkyrc'
LOG_FILE_PATH = BASE_DIR + '/all.log'
CONKY_PID_FILE_PATH = BASE_DIR + '/conky.pid'
RESOLVER_FILE_PATH = '/usr/share/' + PKG_NAME + '/bin/resolver.py'
RESOLVER_PID_FILE_PATH = BASE_DIR + '/resolver.pid'
DATA_FILE_PATH = BASE_DIR + '/.data'
TIME_FORMAT='%Y-%m-%dT%H:%M:%S.%s'