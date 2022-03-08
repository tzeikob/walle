-- A lua module to expose a dotted grid ui component

local Grid = {
  canvas = nil,
  color = { 1, 1, 1, 0.6 }
}

function Grid:new (canvas, color)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.color = color or { 1, 1, 1, 1 }

  return o
end

function Grid:render ()
  local scale = self.canvas.scale

  local left = self.canvas.left
  local top = self.canvas.top
  local right = self.canvas.right
  local bottom = self.canvas.bottom

  local width = 6 * scale
  local offset = (math.floor (width / 2) + 2) * scale
  local length = 30 * scale

  -- Draw the vertical edge of the top left corner
  local x1 = left + offset
  local y1 = top + offset
  local x2 = x1
  local y2 = y1 + length

  self.canvas:draw_line (x1, y1, x2, y2, width, self.color)

  -- Draw the horizontal edge of the top left corner
  x1 = left + offset
  y1 = top + offset
  x2 = x1 + length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, width, self.color)

  -- Draw the vertical edge of the top right corner
  x1 = right - offset
  y1 = top + offset
  x2 = x1
  y2 = y1 + length

  self.canvas:draw_line (x1, y1, x2, y2, width, self.color)

  -- Draw the horizontal edge of the top right corner
  x1 = right - offset
  y1 = top + offset
  x2 = x1 - length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, width, self.color)

  -- Draw the vertical edge of the bottom right corner
  x1 = right - offset
  y1 = bottom - offset
  x2 = x1
  y2 = y1 - length

  self.canvas:draw_line (x1, y1, x2, y2, width, self.color)

  -- Draw the horizontal edge of the bottom right corner
  x1 = right - offset
  y1 = bottom - offset
  x2 = x1 - length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, width, self.color)

  -- Draw the vertical edge of the botom left corner
  x1 = left + offset
  y1 = bottom - offset
  x2 = x1
  y2 = y1 - length

  self.canvas:draw_line (x1, y1, x2, y2, width, self.color)

  -- Draw the horizontal edge of the bottom left corner
  x1 = left + offset
  y1 = bottom - offset
  x2 = x1 + length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, width, self.color)

  -- Draw the grid's dots
  local step = 20 * scale

  for x = left, right, step do
    for y = top, bottom, step do
      self.canvas:draw_dot (x, y, 1 * scale, self.color)
    end
  end
end

return {
  Grid = Grid
}