-- A component for scalar values drawn a horizontal bar

local BarScalar = {
  canvas = nil,
  data =  {
    value = 0,
    max = 0,
  },
  style = {
    front = { 1, 1, 1, 0.8 },
    back = { 1, 1, 1, 0.4 },
    offset = 2
  },
  x = 0,
  y = 0,
  width = 0,
  height = 0
}

function BarScalar:new (canvas, value, max, width, height, color)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.data.value = value
  o.data.max = max

  o.style.front = color or o.style.front
  o.style.offset = o.style.offset * o.canvas.scale

  o.x = 0
  o.y = 0
  o.width = width
  o.height = height

  return o
end

function BarScalar:locate (x, y)
  self.x = x
  self.y = y
end

function BarScalar:render ()
  local scale = self.canvas.scale

  self.canvas:draw_rectangle (
    self.x + self.style.offset,
    self.y + self.style.offset,
    self.width,
    self.height,
    self.style.back)

  local ratio = self.data.value / self.data.max

  self.canvas:draw_rectangle (
    self.x,
    self.y,
    self.width * ratio,
    self.height,
    self.style.front)
end

return BarScalar