#!/usr/bin/env bash
# An opinionated tool to manage and configure conky for developers

VERSION="0.1.0"
ROOT_DIR="/home/$USER/.tzkb/walle"
BIN_DIR="$ROOT_DIR/bin"
PID_FILE="$ROOT_DIR/pid"
LOGS_DIR="$ROOT_DIR/logs"
LOG_FILE="$LOGS_DIR/all.log"
SYMLINK="/usr/local/bin/walle"
AUTOSTART_FILE="/home/$USER/.config/autostart/walle.sh.desktop"
CONFIG_FILE="$ROOT_DIR/conkyrc"

# Logs stdout/err message to console and log file: <message> <emoji>
log () {
  echo -e "$1 $2"
  echo -e "$1" >> $LOG_FILE
}

# Aborts process on fatal errors: <message> <errcode>
abort () {
  local message=$1
  local errcode=$2

  log "Error: $message" "\U1F480"
  log "\nProcess exited with code: $errcode"

  exit $errcode
}

# Prints a short help report
help () {
  echo -e "Walle v$VERSION"
  echo -e "An opinionated tool to manage and configure conky for developers\n"

  echo -e "Usage:"
  echo -e "  walle --help                       Print this help message"
  echo -e "  walle --version                    Print the installed version of walle"
  echo -e "  walle start [--config <file>]      Start conky with config file, defaults to .conkyrc"
  echo -e "  walle stop                         Stop conky service"

  echo -e "\n Example:"
  echo -e "  walle start --config ~/.wallerc    Starts conky with the given config file"
  echo -e "  walle stop                         Stops conky by killing it's running service"

  echo -e "\nNote:"
  echo -e "  to remove, delete or uninstall walle, just remove:"
  echo -e "    - the installation folder $ROOT_DIR"
  echo -e "    - the start up desktop file $AUTOSTART_FILE"
  echo -e "    - the symlink file $SYMLINK"
}

# Prints the version number
version () {
  echo -e "v$VERSION"
}

# Starts or restarts conky service in background: <config>
startConky () {
  local config=$1

  # Try to kill an already running process
  if [ -f "$PID_FILE" ]; then
    kill $(cat $PID_FILE) >> $LOG_FILE 2>&1
  fi

  # Try to kill any other conky running processes
  pkill -f conky >> $LOG_FILE 2>&1

  # Start conky process as a child process
  $BIN_DIR/conky-x86_64.AppImage -b -p 3 -c $config >> $LOG_FILE 2>&1 &

  # Save child process id
  local pid=$!

  # Give time to child process to spawn
  sleep 1

  # Check if child process spawn successfully
  ps -p $pid >> $LOG_FILE 2>&1 ||
    abort "conky process failed to be spawn $pid" $?

  # Save the child process id to the disk
  echo $pid > $PID_FILE

  log "Conky is now up and running"
}

# Stops and kills any conky running process
stopConky () {
  pkill -f conky >> $LOG_FILE 2>&1 ||
    abort "failed to stop conky process" $?

  # Remove process id file
  rm -f $PID_FILE

  log "Conky has been shut down"
}

# Disallow to run this script as root or with sudo
if [[ "$UID" == "0" ]]; then
  echo -e "Error: don't run this script as root or using sudo \U1F480"
  echo -e "\nProcess exited with code: 1"
  exit 1
fi

# Create logs folder if not yet created
mkdir -p $LOGS_DIR

# Print help if script called without arguments
if [ "$#" -lt 1 ]; then
  help
  exit 0
fi

# Give priority to print help or version and exit
for arg in "$@"; do
  case $arg in
    "-h" | "--help")
      help
      exit 0;;
    "-v" | "--version")
      version
      exit 0;;
  esac
done

# Expect the first argument to be a command operation
cmd="${1-}"

case $cmd in
  "start")
    shift

    # Initialize start command options
    config=$CONFIG_FILE

    # Iterate to gather command's option values
    while [ "$#" -gt 0 ]; do
      opt="${1-}"

      case "$opt" in
        "-c" | "--config")
          shift
          config="${1-}";;
        *)
          log "Error: option $opt is not supported" "\U1F480"
          log "\nProcess exited with code: 1"
          exit 1;;
      esac

      shift
    done

    # Start conky service with the given opts
    startConky $config
    exit 0;;
  "stop")
    stopConky
    exit 0;;
  *)
    log "Error: command $cmd is not supported" "\U1F480"
    log "\nProcess exited with code: 1"
    exit 1;;
esac

exit 0