#!/usr/bin/env bash
# An opinionated tool to manage and configure conky for developers

NAME="PKG_NAME"
VERSION="PKG_VERSION"

CONFIG_DIR=~/.config/$NAME
CONFIG_FILE=$CONFIG_DIR/.wallerc
CONKYRC_FILE=$CONFIG_DIR/.conkyrc
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

# Asserts a value is not empty: <value>, <message>
notEmpty () {
  local value=$1
  local message=$2

  if [ -z "$value" ]; then
    abort "$message" 1
  fi
}

# Asserts a value matches either one of the given values: <value> <message> <value1> <value2> [valueN]
shouldBe () {
  local value=$1
  local message=$2

  # Collect the rest of the arguments
  shift
  shift
  local list=($@)

  # If you find a match return
  for item in "${list[@]}"; do
    if [[ $value == $item ]]; then
      return
    fi
  done

  abort "$message ${list[*]}" 1
}

# Prints a short help report
help () {
  echo -e "$NAME v$VERSION"
  echo -e "An opinionated tool to manage and configure conky for developers\n"

  echo -e "Usage:"
  echo -e "  $NAME --help                       Print this help message"
  echo -e "  $NAME --version                    Print the installed version"
  echo -e "  $NAME start                        Start the conky process"
  echo -e "  $NAME stop                         Stop the conky process"
  echo -e "  $NAME config [options]             Update the given options in the config file"

  echo -e "\nOptions:"
  echo -e "  -t, --theme <mode>                 Theme mode could be either 'light' or 'dark'"
  echo -e "  -w, --wallpaper <mode>             Wallpaper mode could be either 'static' or 'slide'"
  echo -e "  -c, --clock <font>                 Font name and style for the clock section"
  echo -e "  -d, --date <font>                  Font name and style for the date section"
  echo -e "  -x, --text <font>                  Font name and style for the text section"
  echo -e "  --debug <mode>                     Debug mode could be either 'disabled' or 'enabled'"

  echo -e "\nExamples:"
  echo -e "  $NAME start                        Starts conky process"
  echo -e "  $NAME stop                         Stops conky process"
  echo -e "  $NAME config --theme dark          Sets the theme to dark mode"

  echo -e "\nNotes:"
  echo -e "  -font options must be given as strings in form \"Font Name:bold:italic:size=14\""
  echo -e "  -to remove the package just run sudo apt-get remove $NAME"
}

# Prints the version number
version () {
  echo -e "v$VERSION"
}

# Starts the conky as child process
start () {
  # Try to kill conky process if already running
  if [ -f "$PID_FILE" ]; then
    kill $(cat $PID_FILE) >> $LOG_FILE 2>&1
  fi

  # Start a new conky process as child process
  conky -b -p 1 -c $CONKYRC_FILE >> $LOG_FILE 2>&1 &
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

# Returns if the conky process is up and running
isUp () {
  if [ -f "$PID_FILE" ]; then
    local pid=$(cat $PID_FILE)

    ps -p $pid >> $LOG_FILE 2>&1 ||
      abort "failed to resolve status, invalid pid: $pid" $?

    echo "true"
  else
    echo "false"
  fi
}

# Updates the given properties in config file: <opts>
config () {
  # Properties must be given as an associated array
  local -n opts=$1

  # For each property update and save the config file
  for key in "${!opts[@]}"; do
    local value=${opts[$key]}

    local contents=$(jq ".\"${key}\" = \"$value\"" $CONFIG_FILE) && \
      echo "${contents}" > $CONFIG_FILE && \
      echo "Option $key has been changed to $value"
  done

  # If conky is up and running do a restart
  if [ "$(isUp)" == "true" ]; then
    echo -e "Restarting the conky process..."
    start
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
    start
    exit 0;;

  "stop")
    stop
    exit 0;;

  "config")
    shift

    declare -A options

    # Iterate to gather command's option values
    while [ "$#" -gt 0 ]; do
      opt="${1-}"

      case "$opt" in
        "--theme" | "-t")
          shift
          value="${1-}"
          notEmpty "$value" "option $opt should not be empty"
          shouldBe "$value" "option $opt should be either" "light" "dark"
          options['theme']="${1-}";;

        "--wallpaper" | "-w")
          shift
          value="${1-}"
          notEmpty "$value" "option $opt should not be empty"
          shouldBe "$value" "option $opt should be either" "static" "slide"
          options['wallpaper']="$value";;
        
        "--clock" | "-c")
          shift
          value="${1-}"
          notEmpty "$value" "option $opt should not be empty"
          options['clock']="$value";;
        
        "--date" | "-d")
          shift
          value="${1-}"
          notEmpty "$value" "option $opt should not be empty"
          options['date']="$value";;
        
        "--text" | "-x")
          shift
          value="${1-}"
          notEmpty "$value" "option $opt should not be empty"
          options['text']="$value";;
        
        "--debug")
          shift
          value="${1-}"
          notEmpty "$value" "option $opt should not be empty"
          shouldBe "$value" "option $opt should be either" "disabled" "enabled"
          options['debug']="$value";;

        *)
          abort "option $opt is not supported" 1;;
      esac

      shift
    done

    config options
    exit 0;;

  *)
    abort "command $cmd is not supported" 1;;
esac

exit 0