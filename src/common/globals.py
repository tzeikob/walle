# A module exporting global constants and variables

import os

PKG_VERSION = '#PKG_VERSION'
PKG_NAME = '#PKG_NAME'
CONFIG_DIR = os.path.expanduser('~/.config') + '/' + PKG_NAME
INSTALL_DIR = '/usr/share/' + PKG_NAME

STYLE_FILE_PATH = INSTALL_DIR + '/style.css'
CONFIG_FILE_PATH = CONFIG_DIR + '/config.yml'
LOG_FILE_PATH = CONFIG_DIR + '/all.log'
PID_FILE_PATH = CONFIG_DIR + '/pid'
TIME_FORMAT='%Y-%m-%dT%H:%M:%S.%s'