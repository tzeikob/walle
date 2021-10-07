#!/usr/bin/env bash
# A script to install walle

VERSION="0.1.0"

ROOT_DIR="/home/$USER/.tzkb/walle"
BIN_DIR="$ROOT_DIR/bin"
LOGS_DIR="$ROOT_DIR/logs"
AUTOSTART_DIR="/home/$USER/.config/autostart"

INDEX_FILE="$BIN_DIR/index.sh"
MAIN_LUA_FILE="$BIN_DIR/main.lua"
ENV_FILE="$ROOT_DIR/.envrc"
CONFIG_FILE="$ROOT_DIR/.conkyrc"

SYMLINK="/usr/local/bin/walle"
EXEC_NAME="walle"
AUTOSTART_FILE="$AUTOSTART_DIR/walle.desktop"

INDEX_URL="https://raw.githubusercontent.com/tzeikob/walle/master/bin/index.sh"
MAIN_LUA_URL="https://raw.githubusercontent.com/tzeikob/walle/master/bin/main.lua"
CONFIG_URL="https://raw.githubusercontent.com/tzeikob/walle/master/.conkyrc"

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

  # Remove conky deps as well if already installed
  sudo apt-get -y purge conky conky-all >> $LOG_FILE 2>&1

  # Remove environment variables hook from user's bashrc
  sed -i "/source $(echo $ENV_FILE | sed 's_/_\\/_g')/d" ~/.bashrc
}

# Downloads the given url: <url> <filename>
wg () {
  local url=$1
  local filename=$2

  wget $url \
    --output-document $filename \
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

  wg $CONFIG_URL $CONFIG_FILE ||
    abort "failed to download the conky config file" $?

  log "Config file has been downloaded $CONFIG_FILE"

  log "Conky has been installed"
}

# Installs the executable file
installExecutable () {
  log "Installing the executable file" "\U1F4AC"

  wg $INDEX_URL $INDEX_FILE ||
    abort "failed to download the executable file" $?

  log "Executable file has been downloaded"

  log "Downloading the main lua file" "\U1F4AC"

  wg $MAIN_LUA_URL $MAIN_LUA_FILE ||
    abort "failed to download the main lua file" $?

  log "Main lua file has been downloaded"

  chmod +x $INDEX_FILE

  if [ -f $SYMLINK ]; then
    SYMLINK="/usr/local/bin/tzkb.walle"
    EXEC_NAME="tzkb.walle"
  fi

  sudo ln -s $INDEX_FILE $SYMLINK >> $LOG_FILE 2>&1 ||
    abort "failed to create symbolic link to the executable file" $?

  log "Executable symlink has been created to $SYMLINK"

  # Create autostart folder if not yet exists
  mkdir -p $AUTOSTART_DIR

  if [ -f $AUTOSTART_FILE ]; then
    AUTOSTART_FILE="$AUTOSTART_DIR/tzkb.walle.desktop"
  fi

  echo "[Desktop Entry]" >> $AUTOSTART_FILE
  echo "Type=Application" >> $AUTOSTART_FILE
  echo "Exec=$EXEC_NAME start" >> $AUTOSTART_FILE
  echo "Hidden=false" >> $AUTOSTART_FILE
  echo "NoDisplay=false" >> $AUTOSTART_FILE
  echo "Name[en_US]=Walle" >> $AUTOSTART_FILE
  echo "Name=Walle" >> $AUTOSTART_FILE
  echo "Comment[en_US]=Walle Start Up" >> $AUTOSTART_FILE
  echo "Comment=Walle Start Up" >> $AUTOSTART_FILE

  log "Autostart has been set at system start-up"

  log "Executable has been installed"
}

# Creates the environment variables file and hooks it to user's bashrc
setEnvironmentVariables () {
  touch $ENV_FILE

  local NS="TZKB_WALLE"

  echo "export ${NS}_VERSION=$VERSION" >> $ENV_FILE
  echo "" >> $ENV_FILE

  echo "export ${NS}_ROOT_DIR=$ROOT_DIR" >> $ENV_FILE
  echo "export ${NS}_BIN_DIR=$BIN_DIR" >> $ENV_FILE
  echo "export ${NS}_LOGS_DIR=$LOGS_DIR" >> $ENV_FILE
  echo "export ${NS}_AUTOSTART_DIR=$AUTOSTART_DIR" >> $ENV_FILE
  echo "" >> $ENV_FILE

  echo "export ${NS}_INDEX_FILE=$INDEX_FILE" >> $ENV_FILE
  echo "export ${NS}_MAIN_LUA_FILE=$MAIN_LUA_FILE" >> $ENV_FILE
  echo "export ${NS}_ENV_FILE=$ENV_FILE" >> $ENV_FILE
  echo "export ${NS}_CONFIG_FILE=$CONFIG_FILE" >> $ENV_FILE
  echo "" >> $ENV_FILE

  echo "export ${NS}_SYMLINK=$SYMLINK" >> $ENV_FILE
  echo "export ${NS}_EXEC_NAME=$EXEC_NAME" >> $ENV_FILE
  echo "export ${NS}_AUTOSTART_FILE=$AUTOSTART_FILE" >> $ENV_FILE

  # Hook env file to bashrc file removing previous installed hooks
  sed -i "/source $(echo $ENV_FILE | sed 's_/_\\/_g')/d" ~/.bashrc

  echo -e "\nsource $ENV_FILE" >> ~/.bashrc
  source ~/.bashrc

  log "Env variables has been hooked into ~/.bashrc"
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
log "Walle v$VERSION"
log "Running on $(lsb_release -si) $(lsb_release -sr) $(lsb_release -sc)"
log "Logged in as $USER@$HOSTNAME with kernel $(uname -r)"
log "Script spawn a process with PID $$"
log "Installation folder has been created under $ROOT_DIR"
log "Logs have been redirected to $LOG_FILE"
log "Script initialization has been completed\n"

installDependencies
installConky
installExecutable
setEnvironmentVariables

log "\nInstallation has been completed successfully" "\U1F389"

# Start walle process
$EXEC_NAME start

log "Try $EXEC_NAME --help to get more help"
log "Have a nice walle time, $USER!\n"

exit 0