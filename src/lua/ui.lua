-- A lua script exposes utilities to draw the ui

local width = 0
local height = 0

local top = 0
local left = 0
local bottom = 0
local right = 0

-- Initializes global ui properties
function init (conky_width, conky_height, screen_width, screen_height, pan)
  -- Set the width and height equal to the conky viewport
  width = conky_width
  height = conky_height

  -- Calculate deltas between conky and actual screen size
  local delta_width = width - screen_width
  local delta_height = height - screen_height

  -- Calibrate top left position of the viewport origin
  local origin = 0

  if delta_width < delta_height then
    origin = delta_width
  elseif delta_width > delta_height then
    origin = delta_height
  end

  -- Set top left viewport edges
  top = origin
  left = origin

  -- Move top left edges with respect to the given pan
  top = top + pan['top']
  left = left + pan['left']

  -- Set bottom right viewport edges
  bottom = height - delta_height
  right = width - delta_width

  -- Move bottom right edges with respect to the given pan
  bottom = bottom + pan['bottom']
  right = right + pan['right']
end

-- Draws the outer border corners
function draw_border (viewport)
  cairo_set_line_width (viewport, 4)
  cairo_set_line_cap (viewport, CAIRO_LINE_CAP_SQUARE)
  cairo_set_source_rgba (viewport, 1, 0, 0, 0.5)

  local border_length = 30

  -- Draw the vertical edge of the top left corner
  local start_x = left
  local start_y = top
  local end_x = left
  local end_y = start_y + border_length

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the horizontal edge of the top left corner
  start_x = left
  start_y = top
  end_x = start_x + border_length
  end_y = top

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the vertical edge of the top right corner
  start_x = right
  start_y = top
  end_x = right
  end_y = start_y + border_length

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the horizontal edge of the top right corner
  start_x = right
  start_y = top
  end_x = start_x - border_length
  end_y = top

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the vertical edge of the bottom right corner
  start_x = right
  start_y = bottom
  end_x = right
  end_y = start_y - border_length

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the horizontal edge of the bottom right corner
  start_x = right
  start_y = bottom
  end_x = start_x - border_length
  end_y = bottom

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the vertical edge of the botom left corner
  start_x = left
  start_y = bottom
  end_x = left
  end_y = start_y - border_length

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the horizontal edge of the bottom left corner
  start_x = left
  start_y = bottom
  end_x = start_x + border_length
  end_y = bottom

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)
end

-- Draws the dotted grid
function draw_grid (viewport)
  cairo_set_line_width (viewport, 1)
  cairo_set_source_rgba (viewport, 1, 0, 0, 0.4)

  local step = 20
  local padding = 15

  -- Draw circles in a grid layout stepped in fixed gaps
  for x = left + padding, right, step do
    for y = top + padding, bottom, step do
      local radius = 1
      local start_angle = 0
      local end_angle = 2 / math.pi

      cairo_arc (viewport, x, y, radius, start_angle, end_angle)
      cairo_stroke (viewport)
    end
  end
end

return {
  init = init,
  draw_border = draw_border,
  draw_grid = draw_grid
}