#!/usr/bin/env bash
# A script to be run after apt install

set -e

PKG_NAME="#PKG_NAME"
HOME_DIR=/home/$SUDO_USER
CONFIG_DIR=$HOME_DIR/.config/$PKG_NAME
AUTOSTART_DIR=$HOME_DIR/.config/autostart
TEMP_DIR=/tmp/$PKG_NAME

echo -e "Startig post installation script"

# Create config folder
mkdir -p $CONFIG_DIR

# Move config files to the config folder
mv $TEMP_DIR/config.yml $CONFIG_DIR/config.yml
mv $TEMP_DIR/.conkyrc $CONFIG_DIR/.conkyrc

# Move lua files
LUA_FILE=$CONFIG_DIR/main.lua
mv $TEMP_DIR/main.lua $LUA_FILE

# Set the user name in the main lua file
sed -i "s/#USER/$SUDO_USER/g" $LUA_FILE

mv $TEMP_DIR/ui.lua $CONFIG_DIR/ui.lua
mv $TEMP_DIR/util.lua $CONFIG_DIR/util.lua

# Change permissions to sudo user
chown -R $SUDO_USER:$SUDO_USER $CONFIG_DIR

echo -e "Config folder has been created"

# Create the autostart gnome desktop file
mkdir -p $AUTOSTART_DIR
DESKTOP_FILE=$AUTOSTART_DIR/$PKG_NAME.desktop

echo "[Desktop Entry]" >> $DESKTOP_FILE
echo "Type=Application" >> $DESKTOP_FILE
echo "Exec=$PKG_NAME start" >> $DESKTOP_FILE
echo "Hidden=false" >> $DESKTOP_FILE
echo "NoDisplay=false" >> $DESKTOP_FILE
echo "Name[en_US]=$PKG_NAME" >> $DESKTOP_FILE
echo "Name=$PKG_NAME" >> $DESKTOP_FILE
echo "Comment[en_US]=$PKG_NAME Start Up" >> $DESKTOP_FILE
echo "Comment=$PKG_NAME Start Up" >> $DESKTOP_FILE

# Change permissions to sudo user
chown $SUDO_USER:$SUDO_USER $DESKTOP_FILE

echo -e "Autostart desktop file created at '$DESKTOP_FILE'"

echo -e "Installing python third-party dependencies..."

su $SUDO_USER -c "pip3 install ruamel.yaml --upgrade"

echo -e "Python dependencies have been installed"

echo -e "Installing lua third-party dependencies..."

luarocks install luafilesystem
luarocks install yaml

echo -e "Lua dependencies have been installed"

echo -e "Starting $PKG_NAME executable..."

su $SUDO_USER -c "$PKG_NAME start"

echo -e "Exiting post installation script"

exit 0