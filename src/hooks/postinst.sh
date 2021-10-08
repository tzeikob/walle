#!/usr/bin/env bash
# A script to be run after installation

set -e

NAME=PKG_NAME
CONFIG_DIR=/home/$SUDO_USER/.config/$NAME
AUTOSTART_DIR=/home/$SUDO_USER/.config/autostart

echo -e "Startig post installation script"

echo -e "Saving config and utility files"

# Create config folder
mkdir -p $CONFIG_DIR

# Copy config and unitlity files to the config folder
mv /tmp/$NAME/.conkyrc $CONFIG_DIR/.conkyrc
mv /tmp/$NAME/main.lua $CONFIG_DIR/main.lua

# Change permissions to sudo user
chown -R $SUDO_USER:$SUDO_USER $CONFIG_DIR

echo -e "Config files have been created under '$CONFIG_DIR'"

mkdir -p $AUTOSTART_DIR

mv /tmp/$NAME/$NAME.desktop $AUTOSTART_DIR/$NAME.desktop

echo -e "Autostart desktop file has been saved to $AUTOSTART_DIR"

echo -e "Exiting post installation script"

exit 0