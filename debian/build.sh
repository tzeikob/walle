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
cp $BASE_DIR/meta/hooks/* $DEBIAN_DIR

echo -e "Meta files have been created"

echo -e "Bundling the package files \U1F4AC"

INSTALLATION_DIR=$BUILD_DIR/usr/share/$PKG_NAME
mkdir -p $INSTALLATION_DIR

BIN_DIR=$INSTALLATION_DIR/bin
mkdir -p $BIN_DIR

cp $BASE_DIR/../src/*.py $BIN_DIR
mv $BIN_DIR/bin.py $BIN_DIR/$PKG_NAME.py

echo -e "Binary files have been added"

LIB_DIR=$BIN_DIR/lib
mkdir -p $LIB_DIR

cp $BASE_DIR/../src/lib/*.py $LIB_DIR

echo -e "Resolver modules have been added"

LUA_DIR=$INSTALLATION_DIR/lua
mkdir -p $LUA_DIR

cp $BASE_DIR/../src/lua/*.lua $LUA_DIR
cp $BASE_DIR/impl/desktop.lua $LUA_DIR/desktop.lua

echo -e "Lua script files have been added"

cp -a $BASE_DIR/../resources/. $INSTALLATION_DIR

echo -e "Config and resource files have been set"

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

echo -e "Package global variables have been restored"

echo -e "Building the debian package file \U1F4AC"

DEB_FILE=$DIST_DIR/$PKG_NAME-$PKG_VERSION.deb

dpkg-deb --build --root-owner-group $DIST_DIR/build $DEB_FILE ||
  abort "dpkg-deb failed to build the deb file" $?

echo -e "Package file saved in '$DEB_FILE'"
echo -e "Build process has completed successfully \U1F389"

exit 0