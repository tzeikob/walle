-- A ui component to render a scalar metric as blocks aligned horizontally

local convert = require "convert"

local Blocks = {
  canvas = nil,
  value = nil,
  max = nil,
  pots = 12,
  padding = 2,
  dim = { 1, 1, 1, 0.4 },
  normal = { 1, 1, 1, 0.8 },
  low = { 0.8, 0, 0.1, 0.8 },
  high = { 1, 0.9, 0, 0.8 },
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
  -- Reduce current value to an integer scalar of pots
  local ratio = self.value / self.max
  local scalar = convert.round (ratio * self.pots)

  -- Calculate the width each pot should occupate
  local padding_space = (self.pots - 1) * self.padding
  local pot_width = (self.width - padding_space) / self.pots

  for pot = 1, self.pots, 1 do
    local color = self.dim

    -- Color only pots rated lower than current scalar
    if pot <= scalar then
      if pot <= 2 then
        -- Use low color for the first 2 pots at low scalar
        if scalar <= 2 then
          color = self.low
        else
          color = self.normal
        end
      elseif pot >= 3 and pot <= 9 then
        color = self.normal
      else
        -- Use high color for the last 3 pots
        color = self.high
      end
    end

    -- Make sure no padding space is drawn for the first pot
    local x = self.x + (pot_width + self.padding) * (pot - 1)

    self.canvas:draw_rectangle (x, self.y, pot_width, self.height, color)
  end
end

return Blocks