-- A component to render a numerical value

local Text = require "text"

local Metric = {
  canvas = nil,
  style = {
    face = "Walle Digits"
  }
}

function Metric:new (canvas, value, max, format, size, color)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value
  o.max = max
  o.format = format
  o.size = size
  o.color = color

  value = string.format (format, value)
  o.left = Text:new (canvas, value, o.style.face, size, false, false, color)

  if max and max > 0 then
    max = " / " .. max
    o.right = Text:new (canvas, max, o.style.face, size * 0.6, false, false, color)
  end

  o.x = 0
  o.y = 0

  o.width = o.left.width
  o.height = o.left.height

  if o.right then
    o.width = o.width + (2 * canvas.scale) + o.right.width
  end

  return o
end

function Metric:locate (x, y)
  self.x = x
  self.y = y
end

function Metric:render ()
  self.left:locate (self.x, self.y)
  self.left:render ()

  if self.right then
    local x = self.x + self.left.width + (2 * self.canvas.scale)

    self.right:locate (x, self.y)
    self.right:render ()
  end
end

return Metric