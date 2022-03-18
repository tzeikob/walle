-- A component for scalar values drawn as horizontally aligned colored blocks

local convert = require "convert"

local BlockScalar = {
  canvas = nil,
  value = nil,
  max = nil,
  blocks = 12,
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

function BlockScalar:new (canvas, value, max, width, height)
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

function BlockScalar:locate (x, y)
  self.x = x
  self.y = y
end

function BlockScalar:render ()
  -- Reduce current value to an integer scalar of blocks
  local ratio = self.value / self.max
  local scalar = convert.round (ratio * self.blocks)

  -- Calculate the width each block should occupate
  local padding_space = (self.blocks - 1) * self.padding
  local block_width = (self.width - padding_space) / self.blocks

  for block = 1, self.blocks, 1 do
    local color = self.dim

    -- Color only blocks rated lower than current scalar
    if block <= scalar then
      if block <= 2 then
        -- Use low color for the first 2 blocks at low scalar
        if scalar <= 2 then
          color = self.low
        else
          color = self.normal
        end
      elseif block >= 3 and block <= 9 then
        color = self.normal
      else
        -- Use high color for the last 3 blocks
        color = self.high
      end
    end

    -- Make sure no padding space is drawn for the first block
    local x = self.x + (block_width + self.padding) * (block - 1)

    self.canvas:draw_rectangle (x, self.y, block_width, self.height, color)
  end
end

return BlockScalar