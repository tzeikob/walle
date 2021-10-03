#!/usr/bin/env bash
# A script to install walle

NAME="walle"
VERSION="0.1.0"
ROOT_DIR="/home/$USER/.tzkb/$NAME"
BIN_DIR="$ROOT_DIR/bin"
LOGS_DIR="$ROOT_DIR/logs"

SYMLINK="/usr/local/bin/$NAME"
AUTOSTART_DIR="/home/$USER/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/$NAME.desktop"

INDEX_URL="https://raw.githubusercontent.com/tzeikob/$NAME/master/index.sh"
CONFIG_URL="https://raw.githubusercontent.com/tzeikob/$NAME/master/conkyrc"

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
  sudo rm -f $SYMLINK
  rm -f $AUTOSTART_FILE
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
  log "Installing third-party dependencies" "\U1F4AC"

  sudo apt-get -y update >> $LOG_FILE 2>&1 ||
    abort "failed to update repositories" $?

  sudo apt-get -y install wget jq >> $LOG_FILE 2>&1 ||
    abort "failed to install dependencies" $?

  log "Dependencies have been installed"
}

# Installs the conky along with lua and cairo deps
installConky () {
  log "Installing conky packages" "\U1F4AC"

  sudo apt-get -y install conky conky-all >> $LOG_FILE 2>&1 ||
    abort "failed to install conky packages" $?

  log "Conky packages have been installed"

  # Print the default built-in configuration in logs
  conky -C >> $LOG_FILE 2>&1 ||
    abort "failed to print the default configuration" $?

  log "Downloading the conky config file" "\U1F4AC"

  wg $CONFIG_URL $ROOT_DIR "conkyrc" ||
    abort "failed to download the conky config file" $?

  log "Config file has been downloaded"

  log "Conky has been installed"
}

# Installs the executable file
installExecutable () {
  log "Installing the $NAME executable file" "\U1F4AC"

  wg $INDEX_URL $BIN_DIR "$NAME.sh" ||
    abort "failed to download the executable file" $?

  log "Executable file has been downloaded"

  # Set global variables in the executable file
  sed -i "s/#NAME#/$NAME/" $BIN_DIR/$NAME.sh
  sed -i "s/#VERSION#/$VERSION/" $BIN_DIR/$NAME.sh
  sed -i "s/#ROOT_DIR#/$(echo $ROOT_DIR | sed 's_/_\\/_g')/" $BIN_DIR/$NAME.sh
  sed -i "s/#BIN_DIR#/$(echo $BIN_DIR | sed 's_/_\\/_g')/" $BIN_DIR/$NAME.sh
  sed -i "s/#LOGS_DIR#/$(echo $LOGS_DIR | sed 's_/_\\/_g')/" $BIN_DIR/$NAME.sh

  log "Global variables have been set"

  chmod +x $BIN_DIR/$NAME.sh

  sudo ln -s $BIN_DIR/$NAME.sh $SYMLINK >> $LOG_FILE 2>&1 ||
    abort "failed to create symbolic link to the executable file" $?

  log "Executable symlink has been created to $SYMLINK"

  # Create autostart folder if not yet exists
  mkdir -p $AUTOSTART_DIR

  echo "[Desktop Entry]" >> $AUTOSTART_FILE
  echo "Type=Application" >> $AUTOSTART_FILE
  echo "Exec=$NAME start" >> $AUTOSTART_FILE
  echo "Hidden=false" >> $AUTOSTART_FILE
  echo "NoDisplay=false" >> $AUTOSTART_FILE
  echo "Name[en_US]=$NAME" >> $AUTOSTART_FILE
  echo "Name=$NAME" >> $AUTOSTART_FILE
  echo "Comment[en_US]=$NAME Start Up" >> $AUTOSTART_FILE
  echo "Comment=$NAME Start Up" >> $AUTOSTART_FILE

  log "Autostart has been set at system start-up"

  log "Executable has been installed"
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
mkdir -p $LOGS_DIR

# Echoing welcome messages
log "$NAME v$VERSION"
log "Running on $(lsb_release -si) $(lsb_release -sr) $(lsb_release -sc)"
log "Logged in as $USER@$HOSTNAME with kernel $(uname -r)"
log "Script spawn a process with PID $$"
log "Installation folder has been created under $ROOT_DIR"
log "Logs have been redirected to $LOG_FILE"
log "Script initialization has been completed\n"

installDependencies
installConky
installExecutable

log "\nInstallation has been completed successfully" "\U1F389"

$NAME start

log "Try $NAME --help to get more help"
log "Have a nice conky time, $USER!\n"

exit 0