#!/usr/bin/env bash
# A script to build the project as debian package

set -e

PKG_NAME="$1"
PKG_VERSION="$2"
PKG_DEPENDS="$3"
PKG_ARCHITECTURE="$4"
PKG_MAINTAINER="$5"
PKG_HOMEPAGE="$6"
PKG_DESCRIPTION="$7"

# Resolve base and dist folder paths
BASE_DIR=$(dirname "$0")
DIST_DIR=$BASE_DIR/../dist/debian
BUILD_DIR=$DIST_DIR/build

# Aborts build process on fatal errors: <message> <errcode>
abort () {
  local message=$1
  local errcode=$2

  # Clean up build files
  rm -rf $DIST_DIR

  echo -e "Error: $message"
  echo -e "Process exited with code: $errcode"

  exit $errcode
}

# Escapes slashes in the given path: path
esc () {
  local path=$1

  echo $path | sed 's/\//\\\//g'
}

# Restores any key with the given value in all build files: key, value
restore () {
  local key=$1
  local value=$2

  # Replace only keys prefixed with sharp # char
  find $BUILD_DIR -type f -print0 | xargs -0 sed -i "s/#$key/$(esc "$value")/g"
}

# Disallow to run this script as root or with sudo
if [[ "$UID" == "0" ]]; then
  abort "don't run this script as root user" 1
fi

# Clean any build files
rm -rf $DIST_DIR

echo -e "Debian build process started for '$PKG_NAME v$PKG_VERSION'"

DEBIAN_DIR=$BUILD_DIR/DEBIAN
mkdir -p $DEBIAN_DIR

echo -e "Processing the debian meta files \U1F4AC"

cp $BASE_DIR/meta/control $DEBIAN_DIR/control
cp $BASE_DIR/meta/hooks/postinst.sh $DEBIAN_DIR/postinst
cp $BASE_DIR/meta/hooks/postrm.sh $DEBIAN_DIR/postrm
cp $BASE_DIR/meta/hooks/prerm.sh $DEBIAN_DIR/prerm

echo -e "Meta files have been created"

echo -e "Bundling the package files \U1F4AC"

INSTALLATION_DIR=$BUILD_DIR/usr/share/$PKG_NAME
mkdir -p $INSTALLATION_DIR

BIN_DIR=$INSTALLATION_DIR/bin
mkdir -p $BIN_DIR

cp $BASE_DIR/../src/bin.py $BIN_DIR/$PKG_NAME.py
cp $BASE_DIR/../src/service.py $BIN_DIR/service.py
cp $BASE_DIR/../src/util.py $BIN_DIR/util.py
cp $BASE_DIR/../src/args.py $BIN_DIR/args.py

# Copy the resolver core impl for debian
cp $BASE_DIR/core/resolver.py $BIN_DIR/core.py

echo -e "Binary files have been added"

SYSTEMD_DIR=$BUILD_DIR/etc/systemd/system
mkdir -p $SYSTEMD_DIR

cp $BASE_DIR/../resources/systemd $SYSTEMD_DIR/$PKG_NAME.service

echo -e "Service file has been set in place"

cp $BASE_DIR/../resources/sudoers $INSTALLATION_DIR/sudoers

echo -e "Sudoers file has been added"

LUA_DIR=$INSTALLATION_DIR/lua
mkdir -p $LUA_DIR

cp $BASE_DIR/../src/lua/main.lua $LUA_DIR/main.lua
cp $BASE_DIR/../src/lua/util.lua $LUA_DIR/util.lua
cp $BASE_DIR/../src/lua/core.lua $LUA_DIR/core.lua
cp $BASE_DIR/ui/gnome.lua $LUA_DIR/ui.lua

echo -e "Lua script files have been added"

cp $BASE_DIR/../resources/.conkyrc $INSTALLATION_DIR/.conkyrc
cp $BASE_DIR/../resources/config.yml $INSTALLATION_DIR/config.yml

echo -e "Config files have been set"

echo -e "Bundling process has been completed"

echo -e "Calculating package file size \U1F4AC"

PKG_FILE_SIZE=$(find $DIST_DIR/build/ -type f -exec du -ch {} + | grep total$ | awk '{print $1}')

echo -e "Package file size is $PKG_FILE_SIZE bytes"

echo -e "Restoring package global variables \U1F4AC"

restore "PKG_NAME" "$PKG_NAME"
restore "PKG_VERSION" "$PKG_VERSION"
restore "PKG_DEPENDS" "$PKG_DEPENDS"
restore "PKG_ARCHITECTURE" "$PKG_ARCHITECTURE"
restore "PKG_MAINTAINER" "$PKG_MAINTAINER"
restore "PKG_HOMEPAGE" "$PKG_HOMEPAGE"
restore "PKG_DESCRIPTION" "$PKG_DESCRIPTION"
restore "PKG_FILE_SIZE" "$PKG_FILE_SIZE"
restore "ALIAS_NAME" "$(echo $PKG_NAME | tr [:lower:] [:upper:])"

echo -e "Package global variables have been restored"

echo -e "Building the debian package file \U1F4AC"

DEB_FILE=$DIST_DIR/$PKG_NAME-$PKG_VERSION.deb

dpkg-deb --build --root-owner-group $DIST_DIR/build $DEB_FILE ||
  abort "dpkg-deb failed to build the deb file" $?

echo -e "Package file saved in '$DEB_FILE'"
echo -e "Build process has completed successfully \U1F389"

exit 0