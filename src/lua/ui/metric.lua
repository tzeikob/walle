-- A ui component to render a metric value

local Text = require "text"

local Metric = {
  canvas = nil,
  face = "Ubuntu Mono",
  value = 0,
  size = 0,
  color = { 1, 1, 1, 1 },
  format = "",
  current = nil,
  max = nil,
  x = 0,
  y = 0,
  width = 0,
  height = 0
}

function Metric:new (canvas, value, max, size, color, format)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas

  o.value = value or 0
  o.size = size or 0
  o.color = color or { 1, 1, 1, 1 }
  o.format = format or "%03d"

  value = string.format (o.format, o.value)
  o.current = Text:new (o.canvas, o.face, value, o.size, false, false, o.color)

  if max and max > 0 then
    max = " / " .. max
    o.max = Text:new (o.canvas, o.face, max, o.size * 0.6, false, false, o.color)
  end

  o.x = 0
  o.y = 0

  o.width = o.current.width
  o.height = o.current.height

  if o.max then
    o.width = o.width + (2 * o.canvas.scale) + o.max.width
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
    local x = self.x + (2 * self.canvas.scale) + self.current.width

    self.max:locate (x, self.y)
    self.max:render ()
  end
end

return Metric