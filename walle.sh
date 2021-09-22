#!/usr/bin/env bash
# An opinionated tool to manage and configure conky for developers

VERSION="0.1.0"
INSTALLATION_HOME="/home/$USER/.tzkb/walle"
DEFAULT_CONFIG="$INSTALLATION_HOME/.conkyrc"
LOG_FILE="$INSTALLATION_HOME/stdout.log"

# Logs a normal info message, <message> <emoji>
log () {
  echo -e "\e[97m$1\e[0m $2"
  echo -e "$1" >> $LOG_FILE
}

# Logs an error and exit the process, <message>
abort () {
  echo -e "\e[97m$1\e[0m \U1F480"
  echo -e "$1" >> $LOG_FILE

  echo -e "Process exited with code: 1"
  echo -e "Process exited with code: 1" >> $LOG_FILE

  exit 1
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
  echo -e "  to remove, delete or uninstall walle, just remove the folder ~/.tzkb/walle"
}

# Prints the version number
version () {
  echo -e "v$VERSION"
}

# Starts conky service in background, <config>
startConky () {
  local config=$1

  $INSTALLATION_HOME/conky-x86_64.AppImage -b -c $config >> $LOG_FILE &

  log "Conky is up and running"
}

# Disallow to run this script as root or with sudo
if [[ "$UID" == "0" ]]; then
  abort "Error: Do not run this script as root or using sudo"
fi

# Print help if script called without arguments
if [ "$#" -lt 1 ]; then
  help
  exit 1
fi

# Give priority to print help or version and exit
for arg in "$@"; do
  case $arg in
    "-h" | "--help")
      help
      exit;;
    "-v" | "--version")
      version
      exit;;
  esac
done

# Expect the first argument to be a command operation
cmd="${1-}"

case $cmd in
  "start")
    shift

    # Initialize start command options
    config=$DEFAULT_CONFIG

    # Iterate to gather command's option values
    while [ "$#" -gt 0 ]; do
      opt="${1-}"

      case "$opt" in
        "-c" | "--config")
          shift
          config="${1-}";;
        *)
          abort "Error: Option $opt is not supported";;
      esac

      shift
    done

    # Start conky service with the given opts
    startConky $config
    exit;;
  *)
    abort "Error: Command operation $cmd is not supported"
    exit;;
esac