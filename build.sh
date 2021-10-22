#!/usr/bin/env bash
# A script to start the build process of the project

PKG_NAME="walle"
PKG_VERSION="0.1.0"

# Resolve the base folder of the script
BASE_DIR=$(dirname "$0")

# Aborts build process on fatal errors: <message> <errcode>
abort () {
  local message=$1
  local errcode=$2

  echo -e "Error: $message"
  echo -e "Process exited with code: $errcode"

  exit $errcode
}

# Disallow to run this script as root or with sudo
if [[ "$UID" == "0" ]]; then
  abort "don't run this script as root user" 1
fi

# Disallow to run this script outside the root folder
if [[ ! $BASE_DIR == "." ]]; then
  abort "don't run this script outside the root folder" 1
fi

# Read the first given argument
opt="${1-}"

# Abort if no option is given
if [[ $opt == "" ]]; then
  abort "no option is given, try again with --distro" 1
fi

# Launch the build process given the distro
case $opt in
  "--distro" | "-d")
    shift
    distro="${1-}"

    case "$distro" in
      "debian")
        ./debian/build.sh $PKG_NAME $PKG_VERSION || exit $?;;
      *)
        abort "distro '$distro' is not yet supported" 1;;
    esac;;
  *)
    abort "option '$opt' is not supported" 1;;
esac

exit 0