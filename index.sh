#!/usr/bin/env bash
# An opinionated tool to manage and configure conky for developers

source ../release

PID_FILE="$ROOT_DIR/pid"
CONFIG_FILE="$ROOT_DIR/conkyrc"
LOG_FILE="$LOGS_DIR/all.log"

# Aborts process on fatal errors: <message> <errcode>
abort () {
  local message=$1
  local errcode=$2

  echo -e "Error: $message \U1F480" | tee -a $LOG_FILE
  echo -e "\nProcess exited with code: $errcode" | tee -a $LOG_FILE

  exit $errcode
}

# Resolves and updates the network interface in config file
resolveAndUpdateNetwork () {
  # Resolve the network interface currently in use
  local networkName=$(ip route get 8.8.8.8 | awk -- '{printf $5}')

  # Update the config file with the resolved network
  sed -i "s/ \${upspeedf.*}KiB / \${upspeedf $networkName}KiB /" $CONFIG_FILE
  sed -i "s/\${downspeedf.*}/\${downspeedf $networkName}/" $CONFIG_FILE
  sed -i "s/\${if_up.*}Connected/\${if_up $networkName}Connected/" $CONFIG_FILE
}

# Prints a short help report
help () {
  echo -e "$NAME v$VERSION"
  echo -e "An opinionated tool to manage and configure conky for developers\n"

  echo -e "Usage:"
  echo -e "  $NAME --help                       Print this help message"
  echo -e "  $NAME --version                    Print the installed version"
  echo -e "  $NAME start [--config <file>]      Start conky with the given config file"
  echo -e "  $NAME stop                         Stop conky service"

  echo -e "\n Example:"
  echo -e "  $NAME start --config ~/.conkyrc    Starts conky with the given config file"
  echo -e "  $NAME stop                         Stops conky by killing it's running service"

  echo -e "\nNote:"
  echo -e "  to remove or uninstall $NAME, just run the remove.sh script"
}

# Prints the version number
version () {
  echo -e "v$VERSION"
}

# Starts or restarts conky service in background: <config>
startConky () {
  local config=$1

  # Try to kill process if already running
  if [ -f "$PID_FILE" ]; then
    kill $(cat $PID_FILE) >> $LOG_FILE 2>&1
  fi

  # Make sure any other conky processes are killed
  local conkyPids=($(pgrep -f conky))

  for id in "${conkyPids[@]}"; do
    if [[ $id != $$ ]]; then
      kill "$id" >> $LOG_FILE 2>&1
    fi
  done

  # Resolve and update the network interface currently in use
  resolveAndUpdateNetwork

  # Start a new conky process as child process
  conky -b -p 1 -c $config >> $LOG_FILE 2>&1 &

  # Save child process id
  local pid=$!

  # Give time to child process to spawn
  sleep 1

  # Check if child process spawn successfully
  ps -p $pid >> $LOG_FILE 2>&1 ||
    abort "conky process failed to be spawn $pid" $?

  # Save the child process id to the disk
  echo $pid > $PID_FILE

  echo -e "Conky is now up and running" | tee -a $LOG_FILE
}

# Stops and kills any conky running process
stopConky () {
  pkill -f conky >> $LOG_FILE 2>&1 ||
    abort "failed to stop conky process" $?

  # Remove process id file
  rm -f $PID_FILE

  echo -e "Conky has been shut down" | tee -a $LOG_FILE
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
          abort "Error: option $opt is not supported \U1F480";;
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
    abort "Error: command $cmd is not supported \U1F480";;
esac

exit 0