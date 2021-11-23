#!/usr/bin/env bash
# A script to be run after apt install

set -e

PKG_NAME="#PKG_NAME"
INSTALLATION_DIR=/usr/share/$PKG_NAME
SYSTEMD_DIR=/etc/systemd/system
HOME_DIR=/home/$SUDO_USER
CONFIG_DIR=$HOME_DIR/.config/$PKG_NAME
AUTOSTART_DIR=$HOME_DIR/.config/autostart

echo -e "Startig post installation script"

# Set the current sudo user to files need user's name
sed -i "s/#USER/$SUDO_USER/g" $INSTALLATION_DIR/bin/service.py
sed -i "s/#USER/$SUDO_USER/g" $INSTALLATION_DIR/lua/main.lua
sed -i "s/#USER/$SUDO_USER/g" $SYSTEMD_DIR/$PKG_NAME.service

# Create the executable's symbolic link file
ln -s $INSTALLATION_DIR/bin/$PKG_NAME.py /usr/bin/$PKG_NAME

# Create config folders
mkdir -p $CONFIG_DIR
mkdir -p $CONFIG_DIR/logs

# Copy config files to config folder
cp $INSTALLATION_DIR/config.yml $CONFIG_DIR/config.yml
cp $INSTALLATION_DIR/.conkyrc $CONFIG_DIR/.conkyrc

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
luarocks install lua-cjson

echo -e "Lua dependencies have been installed"

echo -e "Setting up the $PKG_NAME service..."

systemctl daemon-reload
systemctl enable $PKG_NAME.service

echo -e "Service has been enabled"

echo -e "Adding the sudoers rule file for service calls"

# IMPORTANT: Before adding the sudoer rule don't forget
# to set the user name and CHECK the syntax of the file
sed -i "s/#USER/$SUDO_USER/g" $INSTALLATION_DIR/sudoers
visudo -cf $INSTALLATION_DIR/sudoers

mv $INSTALLATION_DIR/sudoers /etc/sudoers.d/$PKG_NAME

echo -e "Sudoers rule file has been set in place"

echo -e "Exiting post installation script"

exit 0