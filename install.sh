#!/usr/bin/env bash
# A script to install walle

VERSION="0.1.0"
ROOT_DIR="/home/$USER/.tzkb/walle"
BIN_DIR="$ROOT_DIR/bin"
LOG_FILE="./install.log"

# Logs stdout/err message to console and log file: <message> <emoji>
log () {
  echo -e "$1 $2"
  echo -e "$1" >> $LOG_FILE
}

# Aborts process on fatal errors rolling installation back: <message> <errcode>
abort () {
  local message=$1
  local errcode=$2

  log "Error: $message" "\U1F480"
  log "Cleaning up installation files" "\U1F4AC"

  rollback

  log "Installation has been rolled back"
  log "\nProcess exited with code: $errcode"

  exit $errcode
}

# Cleans any installation files up
rollback () {
  rm -rf $ROOT_DIR
  sudo rm -f /usr/local/bin/walle
}

# Downloads the given url: <url> <prefix> <filename>
wg () {
  local url=$1
  local prefix=$2
  local filename=$3

  wget $url \
    --directory-prefix $prefix \
    --output-document $prefix/$filename \
    --no-show-progress \
    --retry-connrefused \
    --retry-on-http-error=404,500,503,504,599 \
    --waitretry=10 \
    --tries=3 >> $LOG_FILE 2>&1
}

# Installs third-party dependencies
installDependencies () {
  log "Updating apt repositories" "\U1F4AC"

  sudo apt-get -y update >> $LOG_FILE 2>&1 ||
    abort "failed to update repositories" $?

  log "Repositories have been updated"

  log "Installing third-party dependencies" "\U1F4AC"

  sudo apt-get -y install wget jq >> $LOG_FILE 2>&1 ||
    abort "failed to install dependencies" $?

  log "Dependencies have been installed"
}

# Installs the latest version of the conky
installConky () {
  log "Downloading conky release info" "\U1F4AC"

  local releaseInfoURL="https://api.github.com/repos/brndnmtthws/conky/releases/latest"

  wg $releaseInfoURL $ROOT_DIR conky-release.info ||
    abort "failed to download conky release info" $?

  log "Conky's release info has been downloaded"

  log "Downloading the latest conky executable file" "\U1F4AC"

  # Extract the URL to the conky executable file
  read executableURL < <(cat $ROOT_DIR/conky-release.info | jq --raw-output ".assets[0] | .browser_download_url" >> $LOG_FILE 2>&1) ||
    abort "failed to extract the URL to the executable file" $?

  read versionNumber < <(cat $ROOT_DIR/conky-release.info | jq --raw-output ".tag_name" >> $LOG_FILE 2>&1) ||
    abort "failed to extract the tag name" $?

  wg $executableURL $BIN_DIR conky-x86_64.AppImage ||
    abort "failed to download conky executable file" $?

  log "Conky $versionNumber executable file has been downloaded"

  chmod +x $BIN_DIR/conky-x86_64.AppImage

  # Print the default configuration in logs
  $BIN_DIR/conky-x86_64.AppImage -C >> $LOG_FILE 2>&1 ||
    abort "failed to print the default configuration" $?

  log "Conky set to use default configuration"

  log "Conky has been installed successfully"
}

# Installs the latest version of the walle
installWalle () {
  log "Downloading the latest version of the walle executable" "\U1F4AC"

  local executableURL="https://raw.githubusercontent.com/tzeikob/walle/master/walle.sh"

  wg $executableURL $BIN_DIR "walle.sh" ||
    abort "failed to download the walle executable file" $?

  log "Walle executable file has been downloaded"

  chmod +x $BIN_DIR/walle.sh

  local symlink="/usr/local/bin/walle"

  sudo ln -s $BIN_DIR/walle.sh $symlink >> $LOG_FILE 2>&1 ||
    abort "failed to create symbolic link to the executable file" $?

  log "Executable symlink has been created to $symlink"

  log "Walle has been installed successfully"
}

# Disallow to run this script as root or with sudo
if [[ "$UID" == "0" ]]; then
  echo -e "Error: don't run this script as root or using sudo \U1F480"
  echo -e "\nProcess exited with code: 1"
  exit 1
fi

# Create installation folders
mkdir -p $ROOT_DIR
mkdir -p $BIN_DIR

# Echoing welcome messages
log "Walle v$VERSION"
log "Running on $(lsb_release -si) $(lsb_release -sr) $(lsb_release -sc)"
log "Logged in as $USER@$HOSTNAME with kernel $(uname -r)"
log "Script spawn a process with PID $$"
log "Installation folder has been created under $ROOT_DIR"
log "Logs have been redirected to $LOG_FILE"
log "Script initialization has been completed\n"

installDependencies
installConky
installWalle

log "\nInstallation has been completed successfully" "\U1F389"
log "Try walle --help to start using it"
log "Have a nice conky time, $USER!\n"

exit 0