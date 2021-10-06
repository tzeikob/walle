#!/usr/bin/env bash
# An opinionated tool to manage and configure conky for developers

# Global variables set by the install script
VERSION=$TZKB_WALLE_VERSION
ROOT_DIR=$TZKB_WALLE_ROOT_DIR
BIN_DIR=$TZKB_WALLE_BIN_DIR
LOGS_DIR=$TZKB_WALLE_LOGS_DIR
CONFIG_FILE=$TZKB_WALLE_CONFIG_FILE

PID_FILE="$ROOT_DIR/pid"
LOG_FILE="$LOGS_DIR/all.log"

# Aborts process on fatal errors: <message> <errcode>
abort () {
  local message=$1
  local errcode=$2

  echo -e "Error: $message \U1F480" | tee -a $LOG_FILE
  echo -e "\nProcess exited with code: $errcode" | tee -a $LOG_FILE

  exit $errcode
}

# Prints a short help report
help () {
  echo -e "Walle v$VERSION"
  echo -e "An opinionated tool to manage and configure conky for developers\n"

  echo -e "Usage:"
  echo -e "  walle --help                       Print this help message"
  echo -e "  walle --version                    Print the installed version"
  echo -e "  walle start [--config <file>]      Start walle with the given conky config file"
  echo -e "  walle stop                         Stop walle and kill the conky process"

  echo -e "\n Example:"
  echo -e "  walle start --config ~/.conkyrc    Starts walle with the given conky config file"
  echo -e "  walle stop                         Stops walle and kills conky process"
}

# Prints the version number
version () {
  echo -e "v$VERSION"
}

# Starts executable and its conky process in the background: <config>
start () {
  local config=$1

  # Try to kill conky process if already running
  if [ -f "$PID_FILE" ]; then
    kill $(cat $PID_FILE) >> $LOG_FILE 2>&1
  fi

  # Start a new conky process as child process
  conky -b -p 1 -c $config >> $LOG_FILE 2>&1 &
  # Right after spawning conky read its process id
  local pid=$!

  # Give time to the child process to spawn
  sleep 2

  # Check if child process spawn successfully
  ps -p $pid >> $LOG_FILE 2>&1 ||
    abort "failed to be spawn conky process: $pid" $?

  # Save the child process id to the disk
  echo $pid > $PID_FILE

  echo -e "Walle is now up and running" | tee -a $LOG_FILE
}

# Stops executable and kills its running conky process
stop () {
  # Check if the pid file exists
  if [ -f "$PID_FILE" ]; then
    local pid=$(cat $PID_FILE)

    kill $pid >> $LOG_FILE 2>&1 ||
    abort "failed to stop walle, unknown or invalid pid: $pid" $?

    # Remove process id file
    rm -f $PID_FILE

    echo -e "Walle has been shut down" | tee -a $LOG_FILE
  else
    abort "failed to stop walle, no pid file found" $?
  fi
}

# Disallow to run this script as root or with sudo
if [[ "$UID" == "0" ]]; then
  echo -e "Error: don't run this script as root or using sudo \U1F480"
  echo -e "\nProcess exited with code: 1"
  exit 1
fi

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
  "start" | "restart")
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
          abort "Error: option $opt is not supported";;
      esac

      shift
    done

    start $config
    exit 0;;
  "stop")
    stop
    exit 0;;
  *)
    abort "Error: command $cmd is not supported";;
esac

exit 0