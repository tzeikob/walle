#!/usr/bin/env bash
# A script to be run after remove installation

set -e

NAME=PKG_NAME
CONFIG_DIR=/home/$SUDO_USER/.config/$NAME

echo -e "Startig post remove script"

echo -e "Deleting config and utility files in '$CONFIG_DIR'"

# Delete config and utility files
rm -rf $CONFIG_DIR

echo -e "Config files have been removed"

echo -e "Exiting post remove script"

exit 0