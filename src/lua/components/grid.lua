local engine = require "engine"

local Grid = {
  color = { 1, 1, 1, 0.6 }
}

function Grid:new (color)
  local o = setmetatable ({}, self)
  self.__index = self

  o.color = color or { 1, 1, 1, 1 }

  return o
end

function Grid:render ()
  local scale = viewport.scale

  local left = viewport.left
  local top = viewport.top
  local right = viewport.right
  local bottom = viewport.bottom

  local width = 6 * scale
  local offset = (math.floor (width / 2) + 2) * scale
  local length = 30 * scale

  -- Draw the vertical edge of the top left corner
  local x1 = left + offset
  local y1 = top + offset
  local x2 = x1
  local y2 = y1 + length

  engine.line (x1, y1, x2, y2, width, self.color)

  -- Draw the horizontal edge of the top left corner
  x1 = left + offset
  y1 = top + offset
  x2 = x1 + length
  y2 = y1

  engine.line (x1, y1, x2, y2, width, self.color)

  -- Draw the vertical edge of the top right corner
  x1 = right - offset
  y1 = top + offset
  x2 = x1
  y2 = y1 + length

  engine.line (x1, y1, x2, y2, width, self.color)

  -- Draw the horizontal edge of the top right corner
  x1 = right - offset
  y1 = top + offset
  x2 = x1 - length
  y2 = y1

  engine.line (x1, y1, x2, y2, width, self.color)

  -- Draw the vertical edge of the bottom right corner
  x1 = right - offset
  y1 = bottom - offset
  x2 = x1
  y2 = y1 - length

  engine.line (x1, y1, x2, y2, width, self.color)

  -- Draw the horizontal edge of the bottom right corner
  x1 = right - offset
  y1 = bottom - offset
  x2 = x1 - length
  y2 = y1

  engine.line (x1, y1, x2, y2, width, self.color)

  -- Draw the vertical edge of the botom left corner
  x1 = left + offset
  y1 = bottom - offset
  x2 = x1
  y2 = y1 - length

  engine.line (x1, y1, x2, y2, width, self.color)

  -- Draw the horizontal edge of the bottom left corner
  x1 = left + offset
  y1 = bottom - offset
  x2 = x1 + length
  y2 = y1

  engine.line (x1, y1, x2, y2, width, self.color)

  -- Draw the grid's dots
  local step = 20 * scale

  for x = left, right, step do
    for y = top, bottom, step do
      engine.dot (x, y, 1 * scale, self.color)
    end
  end
end

return {
  Grid = Grid
}