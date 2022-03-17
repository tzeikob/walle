-- A ui component to render a scalar metric as blocks aligned horizontally

local convert = require "convert"

local Blocks = {
  canvas = nil,
  value = nil,
  max = nil,
  pots = 12,
  padding = 2,
  x = 0,
  y = 0,
  width = 0,
  height = 0
}

function Blocks:new (canvas, value, max, width, height)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value
  o.max = max

  o.padding = o.padding * o.canvas.scale

  o.x = 0
  o.y = 0
  o.width = width
  o.height = height

  return o
end

function Blocks:locate (x, y)
  self.x = x
  self.y = y
end

function Blocks:render ()
  local ratio = self.value / self.max
  local scalar = convert.round (ratio * self.pots)

  local space = (self.pots - 1) * self.padding
  local width = (self.width - space) / self.pots

  for i = 0, self.pots - 1, 1 do
    local color = { 1, 1, 1, 0.4 }

    if i < scalar then
      if scalar <= 2 then
        color = { 0.8, 0, 0.1, 0.8 }
      elseif scalar > 2 and scalar < 10 then
        color = { 1, 1, 1, 0.8 }
      else
        color = { 1, 0.8, 0, 0.8 }
      end
    end

    local x = self.x + (width + self.padding) * i

    self.canvas:draw_rectangle (x, self.y, width, self.height, color)
  end
end

return Blocks