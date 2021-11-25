#!/usr/bin/env bash
# A script to be run before apt remove

set -e

PKG_NAME="#PKG_NAME"

echo -e "Starting pre remove script"

echo -e "Trying to stop processes..."

su $SUDO_USER -c "$PKG_NAME stop"

echo -e "Processes have been stopped"

echo -e "Exiting pre remove script"

exit 0