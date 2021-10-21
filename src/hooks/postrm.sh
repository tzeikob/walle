#!/usr/bin/env bash
# A script to be run after apt remove

set -e

NAME="#PKG_NAME"
USER_HOME=/home/$SUDO_USER
CONFIG_DIR=$USER_HOME/.config/$NAME
AUTOSTART_DIR=$USER_HOME/.config/autostart

echo -e "Startig post remove script"

# Delete config folder
rm -rf $CONFIG_DIR

echo -e "Config folder has been removed"

# Remove autostart desktop file
rm -f $AUTOSTART_DIR/$NAME.desktop

echo -e "Autostart desktop file has been removed"

echo -e "Exiting post remove script"

exit 0