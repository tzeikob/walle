-- A lua module exporting logging functions

-- Initialize the debug mode to off
local debug_mode = false

-- Initialize the log file path to nil
local log_file_path = nil

-- Enables or disables the debug mode
function set_debug_mode (mode)
  debug_mode = mode
end

-- Sets the log file path
function set_log_file (path)
  log_file_path = path
end

-- Write the given log message to the log file
function log (message)
  if log_file_path then
    local file = io.open(log_file_path, "a")
    file:write("lua: " .. message .. "\n")
    file:close()
  end
end

-- Logs a message
function info (message)
  log (message)
end

-- Logs a message only if debug mode is enabled
function debug (message)
  if debug_mode then
    log (message)
  end
end

return {
  set_debug_mode = set_debug_mode,
  set_log_file = set_log_file,
  info = info,
  debug = debug
}