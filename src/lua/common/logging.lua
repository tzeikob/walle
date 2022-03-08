-- A module to export logging utilities

local Logger = {
  file_path = nil,
  debug_mode = false
}

function Logger:new (file_path, debug_mode)
  local o = setmetatable ({}, self)
  self.__index = self

  o.file_path = file_path or nil
  o.debug_mode = debug_mode or false

  return o
end

function Logger:log (message)
  if self.file_path then
    local file = io.open (self.file_path, "a")
    file:write ("lua: " .. message .. "\n")
    file:close ()
  else
    print ("lua: " .. message .. "\n")
  end
end

function Logger:info (message)
  self:log(message)
end

function Logger:debug (message)
  if self.debug_mode then
    self:log (message)
  end
end

return {
  Logger = Logger
}