#!/usr/bin/env bash
# A script to build the project as debian package

PKG_NAME=$1
PKG_VERSION=$2
PKG_DEPENDS="wget, jq, conky, conky-all"
PKG_ARCHITECTURE="all"
PKG_MAINTAINER="Jake Ob <iakopap@gmail.com>"
PKG_HOMEPAGE="https://github.com/tzeikob/walle"
PKG_DESCRIPTION="An opinionated tool to manage and configure conky for developers"

# Resolve base and dist folder paths
BASE_DIR=$(dirname "$0")
DIST_DIR=$BASE_DIR/../dist/debian

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

# Disallow to run this script as root or with sudo
if [[ "$UID" == "0" ]]; then
  abort "don't run this script as root user" 1
fi

# Abort build process if arguments are missing
if [[ $PKG_NAME == "" || $PKG_VERSION == "" ]]; then
  abort "name or version arguments is missing" 1
fi

# Clean any build files
rm -rf $DIST_DIR

echo -e "Debian build process started for '$PKG_NAME v$PKG_VERSION'"
echo -e "Creating debian files \U1F4AC"

DEBIAN_DIR=$DIST_DIR/build/DEBIAN
mkdir -p $DEBIAN_DIR

CONTROL_FILE=$DEBIAN_DIR/control

echo "Package: $PKG_NAME" >> $CONTROL_FILE
echo "Version: $PKG_VERSION" >> $CONTROL_FILE
echo "Depends: $PKG_DEPENDS" >> $CONTROL_FILE
echo "Architecture: $PKG_ARCHITECTURE" >> $CONTROL_FILE
echo "Maintainer: $PKG_MAINTAINER" >> $CONTROL_FILE
echo "Homepage: $PKG_HOMEPAGE" >> $CONTROL_FILE
echo "Description: $PKG_DESCRIPTION" >> $CONTROL_FILE

echo -e "Control file has been created"

echo -e "Copying apt pre/post installation scripts \U1F4AC"

cp $BASE_DIR/hooks/postinst.sh $DEBIAN_DIR/postinst
cp $BASE_DIR/hooks/postrm.sh $DEBIAN_DIR/postrm

echo -e "Installation scripts have been set in place"
echo -e "Debian files have been created successfully"

echo -e "Bundling the package files \U1F4AC"

BIN_DIR=$DIST_DIR/build/usr/bin
mkdir -p $BIN_DIR

cp $BASE_DIR/../src/walle.sh $BIN_DIR/$PKG_NAME

# Set the package name and version to the executable file
sed -i "s/#PKG_NAME/$PKG_NAME/g" $BIN_DIR/$PKG_NAME
sed -i "s/#PKG_VERSION/$PKG_VERSION/g" $BIN_DIR/$PKG_NAME

echo -e "Executable file has been created"

CONFIG_DIR=$DIST_DIR/build/tmp/$PKG_NAME
mkdir -p $CONFIG_DIR

cp $BASE_DIR/../src/main.lua $CONFIG_DIR/main.lua

echo -e "Main lua file has been created"

cp $BASE_DIR/../src/.conkyrc $CONFIG_DIR/.conkyrc

echo -e "Conkyrc file has been created"

CONFIG_FILE=$CONFIG_DIR/.wallerc
cp $BASE_DIR/../src/.wallerc $CONFIG_FILE

# Set the version in the config file
sed -i "s/#PKG_VERSION/$PKG_VERSION/g" $CONFIG_FILE

echo -e "Config file has been created"

LANGS_DIR=$CONFIG_DIR/langs
mkdir -p $LANGS_DIR
cp $BASE_DIR/../src/langs/*.dict $LANGS_DIR

echo -e "Language files have been created"
echo -e "Package files have been bundled successfully"

echo -e "Building the debian package file \U1F4AC"

DEB_FILE=$DIST_DIR/$PKG_NAME-$PKG_VERSION.deb

dpkg-deb --build --root-owner-group $DIST_DIR/build $DEB_FILE ||
  abort "dpkg-deb failed to build the deb file" $?

echo -e "Package file saved in '$DEB_FILE'"
echo -e "Build process has completed successfully \U1F389"

exit 0