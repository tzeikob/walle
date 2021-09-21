#!/bin/bash
# A script to start the conky service

INSTALLATION_HOME="/opt/walle"
LOG_FILE="$INSTALLATION_HOME/stdout.log"

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

start () {
  log "Starting the conky service" "\U1F4AC"

  sudo $INSTALLATION_HOME/conky-x86_64.AppImage -C > $INSTALLATION_HOME/.conkyrc &

  log "Conky is up and running"
}

start