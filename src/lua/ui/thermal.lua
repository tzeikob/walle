-- A component to render a thermal value as colored square

local Thermal = {
  canvas = nil,
  style = {
    roundness = 1,
    blank = { 1, 1, 1, 0 },
    low = { 0, 0.8, 0, 0.8 },
    warm = { 0.9, 0.4, 0.1, 0.8 },
    high = { 0.8, 0, 0.2, 0.8 },
    extreme = { 0.8, 0, 0.8, 0.8 }
  }
}

function Thermal:new (canvas, value, size)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value

  o.x = 0
  o.y = 0

  o.width = size * o.canvas.scale
  o.height = o.width

  return o
end

function Thermal:locate (x, y)
  self.x = x
  self.y = y
end

function Thermal:render ()
  local scale = self.canvas.scale
  local roundness = self.style.roundness * scale

  local value = self.value
  local color = self.style.low

  if value > 35 and value <= 75 then
    color = self.style.warm
  elseif value > 75 and value <= 90 then
    color = self.style.hot
  elseif value > 90 then
    color = self.style.extreme
  end

  self.canvas:draw_round_rectangle (self.x, self.y, self.width, self.height, roundness, color)
end

return Thermal