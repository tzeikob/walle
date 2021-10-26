#!/usr/bin/env bash
# A script to build the project as debian package

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

# Source utility methods
source $BASE_DIR/../src/util/core.sh
source $BASE_DIR/../src/util/text.sh

# Clean any build files
rm -rf $DIST_DIR

echo -e "Debian build process started for '$PKG_NAME v$PKG_VERSION'"
echo -e "Creating debian files \U1F4AC"

DEBIAN_DIR=$DIST_DIR/build/DEBIAN
mkdir -p $DEBIAN_DIR

echo -e "Creating the debian control file \U1F4AC"

CONTROL_FILE=$DEBIAN_DIR/control
cp $BASE_DIR/control $CONTROL_FILE

# Inject the package metadata into the control file
sed -i "s/#PKG_NAME/$(esc "$PKG_NAME")/g" $CONTROL_FILE
sed -i "s/#PKG_VERSION/$(esc "$PKG_VERSION")/g" $CONTROL_FILE
sed -i "s/#PKG_DEPENDS/$(esc "$PKG_DEPENDS")/g" $CONTROL_FILE
sed -i "s/#PKG_ARCHITECTURE/$(esc "$PKG_ARCHITECTURE")/g" $CONTROL_FILE
sed -i "s/#PKG_MAINTAINER/$(esc "$PKG_MAINTAINER")/g" $CONTROL_FILE
sed -i "s/#PKG_HOMEPAGE/$(esc "$PKG_HOMEPAGE")/g" $CONTROL_FILE
sed -i "s/#PKG_DESCRIPTION/$(esc "$PKG_DESCRIPTION")/g" $CONTROL_FILE

echo -e "Control file has been created"

echo -e "Copying apt pre/post installation scripts \U1F4AC"

POSTINST_FILE=$DEBIAN_DIR/postinst
cp $BASE_DIR/hooks/postinst.sh $POSTINST_FILE

sed -i "s/#PKG_NAME/$(esc "$PKG_NAME")/g" $POSTINST_FILE

POSTRM_FILE=$DEBIAN_DIR/postrm
cp $BASE_DIR/hooks/postrm.sh $POSTRM_FILE

sed -i "s/#PKG_NAME/$(esc "$PKG_NAME")/g" $POSTRM_FILE

echo -e "Installation scripts have been set in place"
echo -e "Debian files have been created successfully"

echo -e "Bundling the package files \U1F4AC"

BIN_DIR=$DIST_DIR/build/usr/bin
mkdir -p $BIN_DIR

BIN_FILE=$BIN_DIR/$PKG_NAME
cp $BASE_DIR/../src/index.py $BIN_FILE

sed -i "s/#PKG_NAME/$(esc "$PKG_NAME")/g" $BIN_FILE

echo -e "Executable file has been created"

CONFIG_DIR=$DIST_DIR/build/tmp/$PKG_NAME
mkdir -p $CONFIG_DIR

cp $BASE_DIR/../src/main.lua $CONFIG_DIR/main.lua

echo -e "Main lua file has been created"

CONKYRC_FILE=$CONFIG_DIR/.conkyrc
cp $BASE_DIR/../src/.conkyrc $CONKYRC_FILE

sed -i "s/#PKG_NAME/$(esc "$PKG_NAME")/g" $CONKYRC_FILE

echo -e "Conkyrc file has been created"

CONFIG_FILE=$CONFIG_DIR/config.yml
cp $BASE_DIR/../src/config.yml $CONFIG_FILE

sed -i "s/#PKG_VERSION/$(esc "$PKG_VERSION")/g" $CONFIG_FILE

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