-- A dotted grid ui component

local Grid = {
  canvas = nil,
  x = 0,
  y = 0,
  width = 0,
  height = 0,
  thickness = 4,
  length = 30,
  radius = 1,
  step = 20,
  dot_color = { 1, 1, 1, 0.6 },
  border_color = { 1, 1, 1, 1 }
}

function Grid:new (canvas, x, y, width, height)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.x = x
  o.y = y
  o.width = width
  o.height = height
  o.thickness = o.thickness * o.canvas.scale
  o.length = o.length * o.canvas.scale
  o.radius = o.radius * o.canvas.scale
  o.step = o.step * o.canvas.scale

  return o
end

function Grid:render ()
  -- Calculate the actual width and height the dots should be drawn within
  local dots_width = self.width - self.thickness * 2
  local dots_height = self.height - self.thickness * 2

  -- Calculate the remaining empty space given the step gap
  local shift_x = math.fmod (dots_width, self.step) / 2
  local shift_y = math.fmod (dots_height, self.step) / 2

  -- Draw the dots of the grid
  for x = self.x + self.thickness + shift_x, self.width + self.thickness * 2, self.step do
    for y = self.y + self.thickness + shift_y, self.height + self.thickness * 2, self.step do
      self.canvas:draw_dot (x, y, self.radius, self.dot_color)
    end
  end

  -- Calculate the offset each line should be shifted
  local offset = self.thickness / 2

  -- Draw the vertical edge of the top left corner
  local x1 = self.x + offset
  local y1 = self.y + offset
  local x2 = x1
  local y2 = y1 + self.length

  self.canvas:draw_line (x1, y1, x2, y2, self.thickness, self.border_color)

  -- Draw the horizontal edge of the top left corner
  x1 = self.x + offset
  y1 = self.y + offset
  x2 = x1 + self.length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, self.thickness, self.border_color)

  -- Draw the vertical edge of the top right corner
  x1 = self.x + self.width - offset
  y1 = self.y + offset
  x2 = x1
  y2 = y1 + self.length

  self.canvas:draw_line (x1, y1, x2, y2, self.thickness, self.border_color)

  -- Draw the horizontal edge of the top right corner
  x1 = self.x + self.width - offset
  y1 = self.y + offset
  x2 = x1 - self.length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, self.thickness, self.border_color)

  -- Draw the vertical edge of the bottom right corner
  x1 = self.x + self.width - offset
  y1 = self.y + self.height - offset
  x2 = x1
  y2 = y1 - self.length

  self.canvas:draw_line (x1, y1, x2, y2, self.thickness, self.border_color)

  -- Draw the horizontal edge of the bottom right corner
  x1 = self.x + self.width - offset
  y1 = self.y + self.height - offset
  x2 = x1 - self.length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, self.thickness, self.border_color)

  -- Draw the vertical edge of the botom left corner
  x1 = self.x + offset
  y1 = self.y + self.height - offset
  x2 = x1
  y2 = y1 - self.length

  self.canvas:draw_line (x1, y1, x2, y2, self.thickness, self.border_color)

  -- Draw the horizontal edge of the bottom left corner
  x1 = self.x + offset
  y1 = self.y + self.height - offset
  x2 = x1 + self.length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, self.thickness, self.border_color)
end

return {
  Grid = Grid
}