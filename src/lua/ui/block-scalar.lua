-- A component for scalar values drawn as horizontally aligned colored blocks

local convert = require "convert"

local BlockScalar = {
  canvas = nil,
  data = {
    value = 0,
    max = 0
  },
  style = {
    blocks = 20,
    padding = 2,
    dim = { 1, 1, 1, 0.4 },
    normal = { 1, 1, 1, 0.8 },
    low = { 0.8, 0, 0.1, 0.8 },
    high = { 1, 0.9, 0, 0.8 },
  },
  x = 0,
  y = 0,
  width = 0,
  height = 0
}

function BlockScalar:new (canvas, value, max, width, height)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.data.value = value
  o.data.max = max

  o.style.padding = o.style.padding * o.canvas.scale

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
  local ratio = self.data.value / self.data.max
  local scalar = convert.round (ratio * self.style.blocks)

  -- Calculate the width each block should occupate
  local padding_space = (self.style.blocks - 1) * self.style.padding
  local block_width = (self.width - padding_space) / self.style.blocks

  for block = 1, self.style.blocks, 1 do
    local color = self.style.dim

    -- Color only blocks rated lower than current scalar
    if block <= scalar then
      if block <= 2 then
        -- Use low color for the first 2 blocks at low scalar
        if scalar <= 2 then
          color = self.style.low
        else
          color = self.style.normal
        end
      elseif block >= 3 and block <= self.style.blocks - 3 then
        color = self.style.normal
      else
        -- Use high color for the last 3 blocks
        color = self.style.high
      end
    end

    -- Make sure no padding space is drawn for the first block
    local x = self.x + (block_width + self.style.padding) * (block - 1)

    self.canvas:draw_rectangle (x, self.y, block_width, self.height, color)
  end
end

return BlockScalar