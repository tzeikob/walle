-- A lua module exporting logging functions

-- Set debug mode to off
debug_mode = "disabled"

-- Enables or disables the debug mode
function set_debug_mode (enabled)
  debug_mode = enabled
end

-- Logs a message
function info (message)
  print (message)
end

-- Logs an error message
function error (message)
  print ("Error: " .. message)
end

-- Logs a message only if debug mode is enabled
function debug (message)
  if debug_mode == "enabled" then
    print (message)
  end
end

return {
  set_debug_mode = set_debug_mode,
  info = info,
  error = error,
  debug = debug
}