#!/usr/bin/env bash
# An opinionated tool to manage and configure conky for developers

VERSION="0.1.0"
ROOT_DIR="/home/$USER/.tzkb/walle"
BIN_DIR="$ROOT_DIR/bin"
LOGS_DIR="$ROOT_DIR/logs"
LOG_FILE="$LOGS_DIR/all.log"

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
  echo -e "  to remove, delete or uninstall walle, just remove the folder $ROOT_DIR and /usr/local/bin/walle symlink"
}

# Prints the version number
version () {
  echo -e "v$VERSION"
}

# Starts conky service in background: <config>
startConky () {
  local config=$1

  $BIN_DIR/conky-x86_64.AppImage -b >> $LOG_FILE 2>&1 &

  log "Conky is now up and running"
}

# Stops and kills any conky running process
stopConky () {
  pkill -f conky >> $LOG_FILE 2>&1 ||
    abort "failed to stop conky process" $?

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
    config=""

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