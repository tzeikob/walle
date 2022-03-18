-- A component to render a numerical value

local Text = require "text"

local Metric = {
  canvas = nil,
  style = {
    face = "Walle Digits"
  }
}

function Metric:new (canvas, value, max, size, color, format)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value
  o.size = size
  o.color = color
  o.format = format

  value = string.format (format, value)
  o.current = Text:new (canvas, o.style.face, value, size, false, false, color)

  if max and max > 0 then
    max = " / " .. max
    o.max = Text:new (canvas, o.style.face, max, size * 0.6, false, false, color)
  end

  o.x = 0
  o.y = 0

  o.width = o.current.width
  o.height = o.current.height

  if o.max then
    o.width = o.width + (2 * canvas.scale) + o.max.width
  end

  return o
end

function Metric:locate (x, y)
  self.x = x
  self.y = y
end

function Metric:render ()
  self.current:locate (self.x, self.y)
  self.current:render ()

  if self.max then
    local x = self.x + self.current.width + (2 * self.canvas.scale)

    self.max:locate (x, self.y)
    self.max:render ()
  end
end

return Metric