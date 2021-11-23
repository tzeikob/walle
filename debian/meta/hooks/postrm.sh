#!/usr/bin/env bash
# A script to be run after apt remove

set -e

PKG_NAME="#PKG_NAME"
HOME_DIR=/home/$SUDO_USER
CONFIG_DIR=$HOME_DIR/.config/$PKG_NAME
AUTOSTART_DIR=$HOME_DIR/.config/autostart

echo -e "Startig post remove script"

rm -f /usr/bin/$PKG_NAME
rm -rf /usr/share/$PKG_NAME

echo -e "Installation remnant files have been removed"

# Remove config folder
rm -rf $CONFIG_DIR

echo -e "Config folder has been removed"

# Remove autostart desktop file
rm -f $AUTOSTART_DIR/$PKG_NAME.desktop

echo -e "Autostart desktop file has been removed"

# Remove sudoer rule file set for service calls
rm -f /etc/sudoers.d/$PKG_NAME

echo -e "Sudoers rule file has been removed"

echo -e "Exiting post remove script"

exit 0