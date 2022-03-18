-- A component to render a grid of dots

local Grid = {
  canvas = nil,
  style = {
    thickness = 4,
    length = 30,
    radius = 1,
    step = 20,
    margin = 10,
    color = { 1, 1, 1, 1 },
    dim = { 1, 1, 1, 0.7 }
  }
}

function Grid:new (canvas, width, height)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas

  o.x = 0
  o.y = 0

  o.width = width
  o.height = height

  return o
end

function Grid:locate (x, y)
  self.x = x
  self.y = y
end

function Grid:render ()
  local scale = self.canvas.scale

  local thickness = self.style.thickness * scale
  local length = self.style.length * scale
  local radius = self.style.radius * scale
  local step = self.style.step * scale
  local margin = self.style.margin * scale

  -- Calculate the actual width and height the dots should be drawn within
  local dots_width = self.width - (thickness * 2) - (margin * 2)
  local dots_height = self.height - (thickness * 2) - (margin * 2)

  -- Adjust the step to the actual space between 2 dots
  step = step + (radius * 2)

  -- Calculate the half of the remaining space left after any drawn dot
  local shift_x = math.fmod (dots_width, step) / 2
  local shift_y = math.fmod (dots_height, step) / 2

  -- Calculate the number of dot columns and rows
  local cols = math.floor (dots_width / step)
  local rows = math.floor (dots_height / step)

  -- Set the starting point for the first dot
  local start_x = self.x + thickness + margin + shift_x
  local start_y = self.y + thickness + margin + shift_y

  -- Draw the dots of the grid
  local x, y = start_x, start_y

  for i = 1, rows + 1, 1 do
    for j = 1, cols + 1, 1 do
      self.canvas:draw_dot (x, y, radius, self.style.dim)

      x = x + step
    end

    x = start_x
    y = y + step
  end

  -- Calculate the offset each edge line should be shifted
  local offset = thickness / 2

  -- Draw the vertical edge of the top left corner
  local x1 = self.x + offset
  local y1 = self.y + offset
  local x2 = x1
  local y2 = y1 + length

  self.canvas:draw_line (x1, y1, x2, y2, thickness, self.style.color)

  -- Draw the horizontal edge of the top left corner
  x1 = self.x + offset
  y1 = self.y + offset
  x2 = x1 + length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, thickness, self.style.color)

  -- Draw the vertical edge of the top right corner
  x1 = self.x + self.width - offset
  y1 = self.y + offset
  x2 = x1
  y2 = y1 + length

  self.canvas:draw_line (x1, y1, x2, y2, thickness, self.style.color)

  -- Draw the horizontal edge of the top right corner
  x1 = self.x + self.width - offset
  y1 = self.y + offset
  x2 = x1 - length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, thickness, self.style.color)

  -- Draw the vertical edge of the bottom right corner
  x1 = self.x + self.width - offset
  y1 = self.y + self.height - offset
  x2 = x1
  y2 = y1 - length

  self.canvas:draw_line (x1, y1, x2, y2, thickness, self.style.color)

  -- Draw the horizontal edge of the bottom right corner
  x1 = self.x + self.width - offset
  y1 = self.y + self.height - offset
  x2 = x1 - length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, thickness, self.style.color)

  -- Draw the vertical edge of the botom left corner
  x1 = self.x + offset
  y1 = self.y + self.height - offset
  x2 = x1
  y2 = y1 - length

  self.canvas:draw_line (x1, y1, x2, y2, thickness, self.style.color)

  -- Draw the horizontal edge of the bottom left corner
  x1 = self.x + offset
  y1 = self.y + self.height - offset
  x2 = x1 + length
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, thickness, self.style.color)
end

return Grid