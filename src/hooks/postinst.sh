#!/usr/bin/env bash
# A script to be run after apt install

set -e

NAME=PKG_NAME
USER_HOME=/home/$SUDO_USER
CONFIG_DIR=$USER_HOME/.config/$NAME
AUTOSTART_DIR=$USER_HOME/.config/autostart
TEMP_DIR=/tmp/$NAME

echo -e "Startig post installation script"

# Create config folder
mkdir -p $CONFIG_DIR

# Move config files to the config folder
mv $TEMP_DIR/.wallerc $CONFIG_DIR/.wallerc
mv $TEMP_DIR/.conkyrc $CONFIG_DIR/.conkyrc
mv $TEMP_DIR/main.lua $CONFIG_DIR/main.lua

# Change permissions to sudo user
chown -R $SUDO_USER:$SUDO_USER $CONFIG_DIR

echo -e "Config files have been moved to '$CONFIG_DIR'"

# Create autostart folder if no such exists
mkdir -p $AUTOSTART_DIR

# Move startup desktop file to the autostart folder
mv $TEMP_DIR/$NAME.desktop $AUTOSTART_DIR/$NAME.desktop

# Change permissions to sudo user
chown $SUDO_USER:$SUDO_USER $AUTOSTART_DIR/$NAME.desktop

echo -e "Autostart desktop file has been saved to '$AUTOSTART_DIR'"

echo -e "Exiting post installation script"

exit 0