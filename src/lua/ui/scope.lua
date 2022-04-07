-- A component to render an FPS weapon scope

local Scope = {
  canvas = nil,
  style = {
    thickness = 1,
    space = 10,
    color = { 1, 1, 1, 0.4 }
  }
}

function Scope:new (canvas, size)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.size = size * o.canvas.scale

  o.x = 0
  o.y = 0

  o.width = o.size
  o.height = o.width

  return o
end

function Scope:locate (x, y)
  self.x = x
  self.y = y
end

function Scope:render ()
  local scale = self.canvas.scale

  local thickness = self.style.thickness * scale
  local space = self.style.space * scale
  local extention = (thickness / 2) + space

  self.canvas:draw_dot (self.x, self.y, thickness, self.style.color)

  local x = self.x + extention
  local y = self.y

  self.canvas:draw_line (x, y, x + self.width, y, thickness, self.style.color)

  x = self.x
  y = self.y + extention

  self.canvas:draw_line (x, y, x, y + self.height, thickness, self.style.color)

  x = self.x - extention
  y = self.y

  self.canvas:draw_line (x, y, x - self.width, y, thickness, self.style.color)

  x = self.x
  y = self.y - extention

  self.canvas:draw_line (x, y, x, y - self.height, thickness, self.style.color)
end

return Scope