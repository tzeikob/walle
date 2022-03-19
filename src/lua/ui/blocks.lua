-- A component for scalar values drawn as horizontally aligned blocks

local convert = require "convert"

local Blocks = {
  canvas = nil,
  style = {
    padding = 2,
    normal = { 1, 1, 1, 0.8 },
    low = { 0.8, 0, 0.1, 0.8 },
    high = { 1, 0.9, 0, 0.8 },
    dim = { 1, 1, 1, 0.4 }
  }
}

function Blocks:new (canvas, value, max, splits, width, height)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value
  o.max = max
  o.splits = splits

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
  -- Reduce current value to an integer scalar of split blocks
  local ratio = self.value / self.max
  local scalar = convert.round (ratio * self.splits)

  -- Calculate the width each split block should occupate
  local padding = self.style.padding * self.canvas.scale
  local padding_space = (self.splits - 1) * padding
  local block_width = (self.width - padding_space) / self.splits

  for block = 1, self.splits, 1 do
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
      elseif block >= 3 and block <= self.splits - 3 then
        color = self.style.normal
      else
        -- Use high color for the last 3 blocks
        color = self.style.high
      end
    end

    -- Make sure no padding space is drawn for the first block
    local x = self.x + (block_width + padding) * (block - 1)

    self.canvas:draw_rectangle (x, self.y, block_width, self.height, color)
  end
end

return Blocks