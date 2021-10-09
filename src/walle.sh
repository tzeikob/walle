#!/usr/bin/env bash
# An opinionated tool to manage and configure conky for developers

NAME="PKG_NAME"
VERSION="PKG_VERSION"

CONFIG_DIR=~/.config/$NAME
CONFIG_FILE=$CONFIG_DIR/.conkyrc
PID_FILE=$CONFIG_DIR/pid
LOG_FILE=$CONFIG_DIR/all.log

# Aborts process on fatal errors: <message> <errcode>
abort () {
  local message=$1
  local errcode=$2

  echo -e "Error: $message \U1F480" | tee -a $LOG_FILE
  echo -e "Process exited with code: $errcode" | tee -a $LOG_FILE

  exit $errcode
}

# Prints a short help report
help () {
  echo -e "$NAME v$VERSION"
  echo -e "An opinionated tool to manage and configure conky for developers\n"

  echo -e "Usage:"
  echo -e "  $NAME --help                       Print this help message"
  echo -e "  $NAME --version                    Print the installed version"
  echo -e "  $NAME start [--config <file>]      Start conky process with the given config file"
  echo -e "  $NAME stop                         Stop conky process"

  echo -e "\nExample:"
  echo -e "  $NAME start --config ~/.conkyrc    Starts conky process with the given config file"
  echo -e "  $NAME stop                         Stops conky process"

  echo -e "\nNote:"
  echo -e "  to remove the package just run sudo apt-get remove $NAME"
}

# Prints the version number
version () {
  echo -e "v$VERSION"
}

# Starts the conky as child process: <config>
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

  echo -e "Conky is now up and running" | tee -a $LOG_FILE
}

# Stops and kills the running conky process
stop () {
  # Check if the pid file exists
  if [ -f "$PID_FILE" ]; then
    local pid=$(cat $PID_FILE)

    kill $pid >> $LOG_FILE 2>&1 ||
    abort "failed to stop conky, unknown or invalid pid: $pid" $?

    # Remove process id file
    rm -f $PID_FILE

    echo -e "Conky has been shut down" | tee -a $LOG_FILE
  else
    abort "failed to stop conky, no pid file found" $?
  fi
}

# Disallow to run this script as root or with sudo
if [[ "$UID" == "0" ]]; then
  echo -e "Error: don't run this script as root or using sudo \U1F480"
  echo -e "Process exited with code: 1"
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
          abort "Error: option $opt is not supported" 1;;
      esac

      shift
    done

    start $config
    exit 0;;
  "stop")
    stop
    exit 0;;
  *)
    abort "Error: command $cmd is not supported" 1;;
esac

exit 0