#!/bin/bash
# A script to install walle and conky executables

VERSION="0.1.0"
INSTALLATION_HOME="/home/$USER/.walle"
TEMP="/tmp/walle.$(date +%s)"
LOG_FILE="$TEMP/stdout.log"

# Logs a normal info message, <message> <emoji>
log () {
  echo -e "\e[97m$1\e[0m $2"
  echo -e "$1" >> $LOG_FILE
}

# Logs an error and exit the process, <message>
abort () {
  echo -e "\n\e[97m$1\e[0m \U1F480"
  echo -e "\n$1" >> $LOG_FILE

  echo -e "Process exited with code: 1"
  echo -e "Process exited with code: 1" >> $LOG_FILE

  exit 1
}

# Installs third-party dependencies
installDependencies () {
  log "Updating the apt repositories" "\U1F4AC"

  sudo apt-get -y update >> $LOG_FILE 2>&1

  log "Repositories have been updated"

  log "Installing third-party dependencies" "\U1F4AC"

  sudo apt-get -y install wget jq >> $LOG_FILE 2>&1

  log "Dependencies have been installed"
}

# Installs the latest version of the conky
installConky () {
  log "Downloading conky release info" "\U1F4AC"

  local releaseInfoURL='https://api.github.com/repos/brndnmtthws/conky/releases/latest'

  wget --no-show-progress -P $TEMP -O $TEMP/conky-latest.info $releaseInfoURL >> $LOG_FILE 2>&1

  log "Conky's release info has been downloaded"

  log "Downloading the latest conky executable file" "\U1F4AC"

  # Extract the URL to the conky executable file
  local executableURL=$(cat $TEMP/conky-latest.info | jq --raw-output '.assets[0] | .browser_download_url')

  wget --no-show-progress -P $TEMP -O $TEMP/conky-x86_64.AppImage $executableURL >> $LOG_FILE 2>&1

  log "Conky executable file has been downloaded"

  mv $TEMP/conky-x86_64.AppImage $INSTALLATION_HOME/conky-x86_64.AppImage
  chmod +x $INSTALLATION_HOME/conky-x86_64.AppImage

  log "Conky executable has been installed ($INSTALLATION_HOME/conky-x86_64.AppImage)"
}

# Installs the latest version of the walle
installWalle () {
  log "Downloading the latest version of the walle executable" "\U1F4AC"

  local executableURL="https://raw.githubusercontent.com/tzeikob/walle/master/bin/walle.sh"

  wget --no-show-progress -P $TEMP -O $TEMP/walle.sh $executableURL >> $LOG_FILE 2>&1

  log "Walle executable file has been downloaded"

  mv $TEMP/walle.sh $INSTALLATION_HOME/walle.sh
  chmod +x $INSTALLATION_HOME/walle.sh

  local symlink="/usr/local/bin/walle"

  sudo ln -s $INSTALLATION_HOME/walle.sh $symlink

  log "Executable symbolic link has been created ($symlink)"

  log "Walle executable has been installed ($INSTALLATION_HOME/walle.sh)"
}

# Create the temporary folder
mkdir -p $TEMP

# Echoing welcome messages
log "Walle v$VERSION"
log "Running on $(lsb_release -si) $(lsb_release -sr) $(lsb_release -sc)"
log "Logged in as $USER@$HOSTNAME with kernel $(uname -r)"
log "Script spawn process with PID $$"
log "Temporary folder has been created ($TEMP)"
log "Logs have been routed to $LOG_FILE"

# Disallow to run this script as root or with sudo
if [[ "$UID" == "0" ]]; then
  abort "Error: Do not run this script as root or using sudo"
  exit 1
fi

log "Script initialization hase been completed\n"

installDependencies

mkdir -p $INSTALLATION_HOME

log "Walle installation folder has been created ($INSTALLATION_HOME)"

installConky
installWalle

# Start walle service
walle

log "\nInstallation has been completed successfully" "\U1F389"
log "Have a nice conky time, $USER!\n"