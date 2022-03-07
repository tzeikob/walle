-- A lua module exporting logging utilities

local Logger = {
  file_path = nil
}

function Logger:new (file_path)
  local o = setmetatable ({}, self)
  self.__index = self

  o.file_path = file_path or nil

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
  self:log (message)
end

function Logger:debug (message)
  if debug_mode then
    self:log (message)
  end
end

return {
  Logger = Logger
}