-- A component for scalar values drawn as a horizontal bar

local Bar = {
  canvas = nil,
  style = {
    offset = 2,
    background = { 1, 1, 1, 0.4 },
    forecolor = { 1, 0.6, 0.1, 0.8 }
  }
}

function Bar:new (canvas, value, max, width, height)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value
  o.max = max

  o.x = 0
  o.y = 0

  o.width = width * o.canvas.scale
  o.height = height * o.canvas.scale

  return o
end

function Bar:locate (x, y)
  self.x = x
  self.y = y
end

function Bar:render ()
  local offset = self.style.offset * self.canvas.scale

  self.canvas:draw_rectangle (
    self.x + offset,
    self.y + offset,
    self.width,
    self.height,
    self.style.background)

  local ratio = self.value / self.max

  self.canvas:draw_rectangle (
    self.x,
    self.y,
    self.width * ratio,
    self.height,
    self.style.forecolor)
end

return Bar