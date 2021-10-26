#!/usr/bin/env bash
# A script to start the build process of the project

PKG_FILE=./package.yml

# Aborts build process on fatal errors: <message> <errcode>
abort () {
  local message=$1
  local errcode=$2

  echo -e "Error: $message"
  echo -e "Process exited with code: $errcode"

  exit $errcode
}

# Disallow to run this script outside the root folder
if [[ ! "$(dirname "$0")" == "." ]]; then
  abort "don't run this script outside the root folder" 1
fi

# Disallow to run this script as root or with sudo
if [[ "$UID" == "0" ]]; then
  abort "don't run this script as root user" 1
fi

# Source utility methods
source ./src/util/core.sh
source ./src/util/text.sh

# Load package yaml file into global variables
eval $(yaml $PKG_FILE "PKG_")

# Read the first given argument
opt="${1-}"

# Abort if no option is given
if [[ $opt == "" ]]; then
  abort "no option is given, try again with --distro <name>" 1
fi

# Launch the build process given the distro
case $opt in
  "--distro" | "-d")
    shift
    name="${1-}"

    case "$name" in
      "debian")
        ./debian/build.sh "$PKG_NAME" \
          "$PKG_VERSION" \
          "$PKG_BUILDS_DEBIAN_DEPENDS" \
          "$PKG_BUILDS_DEBIAN_ARCH" \
          "$PKG_AUTHOR" \
          "$PKG_HOMEPAGE" \
          "$PKG_DESCRIPTION" || exit $?;;
      *)
        abort "distro '$name' is not yet supported" 1;;
    esac;;
  *)
    abort "option '$opt' is not supported" 1;;
esac

exit 0