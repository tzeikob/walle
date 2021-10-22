#!/usr/bin/env bash
# A script to be run after apt remove

set -e

PKG_NAME="walle"
CONFIG_DIR=/home/$SUDO_USER/.config/$PKG_NAME
AUTOSTART_DIR=/home/$SUDO_USER/.config/autostart

echo -e "Startig post remove script"

# Remove config folder
rm -rf $CONFIG_DIR

echo -e "Config folder has been removed"

# Remove autostart desktop file
rm -f $AUTOSTART_DIR/$PKG_NAME.desktop

echo -e "Autostart desktop file has been removed"

echo -e "Exiting post remove script"

exit 0