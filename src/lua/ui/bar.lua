-- A ui component to render a scalar metric as horizontal bar

local Bar = {
  canvas = nil,
  value = nil,
  max = nil,
  color = { 1, 1, 1, 0.8 },
  x = 0,
  y = 0,
  width = 0,
  height = 0
}

function Bar:new (canvas, value, max, width, height, color)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value
  o.max = max
  o.color = color

  o.x = 0
  o.y = 0
  o.width = width
  o.height = height

  return o
end

function Bar:locate (x, y)
  self.x = x
  self.y = y
end

function Bar:render ()
  local scale = self.canvas.scale

  self.canvas:draw_rectangle (
    self.x + (2 * scale),
    self.y + (2 * scale),
    self.width,
    self.height,
    { 1, 1, 1, 0.4 })

  local ratio = self.value / self.max

  self.canvas:draw_rectangle (self.x, self.y, self.width * ratio, self.height, self.color)
end

return Bar