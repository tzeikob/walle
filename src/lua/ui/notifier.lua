-- A component to render a stack of notification messages

local Message = require "message"

local Notifier = {
  canvas = nil,
  style = {
    margin_top = 120,
    space = 10
  }
}

function Notifier:new (canvas, messages)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.messages = messages

  o.stack = {}

  for i = 1, table.getn (o.messages), 1 do
    table.insert (o.stack, Message:new (o.canvas, o.messages[i], 22))
  end

  o.x = 0
  o.y = 0

  return o
end

function Notifier:locate (x, y)
  self.x = x
  self.y = y
end

function Notifier:render ()
  local scale = self.canvas.scale

  local margin_top = self.style.margin_top * scale
  local space = self.style.space * scale

  local y = self.y + margin_top

  for i = 1, table.getn (self.stack), 1 do
    local x = self.x - (self.stack[i].width / 2)

    self.stack[i]:locate (x, y)
    self.stack[i]:render ()

    y = y + self.stack[i].height + space
  end
end

return Notifier