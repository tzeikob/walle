#!/usr/bin/env bash
# A script to build the package file

DIST_DIR="./dist"

PKG_INFO_FILE="./package.json"

PKG_NAME=""
PKG_VERSION=""
PKG_MAINTAINER=""
PKG_DEPENDS=""
PKG_ARCHITECTURE=""
PKG_HOMEPAGE=""
PKG_DESCRIPTION=""

# Logs message to console: <message> <emoji>
log () {
  echo -e "$1 $2"
}

# Aborts build on fatal errors rolling any files back: <message> <errcode>
abort () {
  local message=$1
  local errcode=$2

  log "Error: $message" "\U1F480"
  log "Cleaning up build files" "\U1F4AC"

  clean

  log "Build files has been removed"
  log "Process exited with code: $errcode"

  exit $errcode
}

# Cleans any build files up
clean () {
  rm -rf $DIST_DIR
}

# Escape slashes in paths: path
escape () {
  local path=$1

  echo $path | sed 's_/_\\/_g'
}

# Loads package info
loadPackageInfo () {
  log "Reading package info file" "\U1F4AC"

  if [ ! -f $PKG_INFO_FILE ]; then
    abort "missing package.json file" 1
  fi

  PKG_NAME=$(jq --raw-output '.package' $PKG_INFO_FILE)
  PKG_VERSION=$(jq --raw-output '.version' $PKG_INFO_FILE)
  PKG_MAINTAINER=$(jq --raw-output '.maintainer' $PKG_INFO_FILE)
  PKG_DEPENDS=$(jq --raw-output '.depends' $PKG_INFO_FILE)
  PKG_ARCHITECTURE=$(jq --raw-output '.architecture' $PKG_INFO_FILE)
  PKG_HOMEPAGE=$(jq --raw-output '.homepage' $PKG_INFO_FILE)
  PKG_DESCRIPTION=$(jq --raw-output '.description' $PKG_INFO_FILE)

  log "Package info has been loaded"
}

# Create the debian control file
createDebianFiles () {
  log "Creating debian files" "\U1F4AC"

  local debianDir="$DIST_DIR/build/DEBIAN"
  mkdir -p $debianDir

  local controlFile="$debianDir/control"
  touch $controlFile

  local info="Package: $PKG_NAME\n"
  info+="Version: $PKG_VERSION\n"
  info+="Maintainer: $PKG_MAINTAINER\n"
  info+="Depends: $PKG_DEPENDS\n"
  info+="Architecture: $PKG_ARCHITECTURE\n"
  info+="Homepage: $PKG_HOMEPAGE\n"
  info+="Description: $PKG_DESCRIPTION"
  
  echo -e $info > $controlFile

  log "Control file has been created"

  log "Copying hook installation scripts" "\U1F4AC"

  local postinstFile="$debianDir/postinst"
  cp ./src/hooks/postinst.sh $postinstFile

  # Set the package name in the postinst file
  sed -i "s/PKG_NAME/$PKG_NAME/g" $postinstFile

  local postrmFile="$debianDir/postrm"
  cp ./src/hooks/postrm.sh $postrmFile

  # Set the package name in the postrm file
  sed -i "s/PKG_NAME/$PKG_NAME/g" $postrmFile

  log "Installation scripts have been set in place"

  log "Debian files have been created"
}

# Bundles binary and config files
bundlePackageFiles () {
  log "Bundling binary and config files" "\U1F4AC"

  local binDir="$DIST_DIR/build/usr/bin"
  mkdir -p $binDir

  local binFile="$binDir/$PKG_NAME"
  cp ./src/walle.sh $binFile

  # Set the package name and version in the executable file
  sed -i "s/PKG_NAME/$PKG_NAME/g" $binFile
  sed -i "s/PKG_VERSION/$PKG_VERSION/g" $binFile

  log "Executable file has been saved to '$binFile'"

  local tempConfigDir="$DIST_DIR/build/tmp/$PKG_NAME"
  mkdir -p $tempConfigDir

  local luaFile="$tempConfigDir/main.lua"
  cp ./src/main.lua $luaFile

  log "Main lua file has been saved to '$luaFile'"

  local conkyrcFile="$tempConfigDir/.conkyrc"
  cp ./src/.conkyrc $conkyrcFile

  # Set the package name in the conky config file
  sed -i "s/PKG_NAME/$PKG_NAME/g" $conkyrcFile

  log "Conky config has been saved to '$conkyrcFile'"

  local desktopFile="$tempConfigDir/$PKG_NAME.desktop"
  cp ./src/walle.desktop $desktopFile

  # Set the package name in the start up desktop file
  sed -i "s/PKG_NAME/$PKG_NAME/g" $desktopFile

  log "Desktop file has been saved to '$desktopFile'"

  log "Bundling has been completed"
}

# Builds the debian package file
buildPackageFile () {
  log "Building the debian package file" "\U1F4AC"

  local debFile="$DIST_DIR/$PKG_NAME-$PKG_VERSION.deb"

  dpkg-deb --build --root-owner-group $DIST_DIR/build $debFile ||
    abort "failed to build package file" "$?"

  log "Package '$PKG_NAME' saved in '$debFile'"

  log "Debian package file has been built"
}

# Disallow to run this script as root or with sudo
if [[ "$UID" == "0" ]]; then
  echo -e "Error: don't run this script as root or using sudo \U1F480"
  echo -e "Process exited with code: 1"
  exit 1
fi

# Clean previous build files
clean

log "Build process started"

loadPackageInfo
createDebianFiles
bundlePackageFiles
buildPackageFile

log "Build has completed successfully" "\U1F389"