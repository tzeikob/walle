-- A lua script exposes utilities to draw the ui

-- Viewport's width and height
local width = 0
local height = 0

-- Edges of the drawing area
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

  -- Margin between viewport and drawing area
  local margin = 10

  -- Set top left bottom right viewport edges
  top =  margin
  left = margin
  bottom = height - delta_height - margin
  right = width - delta_width - margin

  -- Move edges with respect to the given panning
  top = top + pan["top"]
  left = left + pan["left"]
  bottom = bottom + pan["bottom"]
  right = right + pan["right"]
end

-- Draws the outer border corners
function draw_border (viewport)
  local line_width = 6
  local offset = (line_width / 2) + 2
  local border_length = 30

  cairo_set_line_width (viewport, line_width)
  cairo_set_line_cap (viewport, CAIRO_LINE_CAP_SQUARE)
  cairo_set_source_rgba (viewport, 0, 0, 0, 0.7)

  -- Draw the vertical edge of the top left corner
  local start_x = left + offset
  local start_y = top + offset
  local end_x = left + offset
  local end_y = start_y + border_length

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the horizontal edge of the top left corner
  start_x = left + offset
  start_y = top + offset
  end_x = start_x + border_length
  end_y = top + offset

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the vertical edge of the top right corner
  start_x = right - offset
  start_y = top + offset
  end_x = right - offset
  end_y = start_y + border_length

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the horizontal edge of the top right corner
  start_x = right - offset
  start_y = top + offset
  end_x = start_x - border_length
  end_y = top + offset

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the vertical edge of the bottom right corner
  start_x = right - offset
  start_y = bottom - offset
  end_x = right - offset
  end_y = start_y - border_length

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the horizontal edge of the bottom right corner
  start_x = right - offset
  start_y = bottom - offset
  end_x = start_x - border_length
  end_y = bottom - offset

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the vertical edge of the botom left corner
  start_x = left + offset
  start_y = bottom - offset
  end_x = left + offset
  end_y = start_y - border_length

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)

  -- Draw the horizontal edge of the bottom left corner
  start_x = left + offset
  start_y = bottom - offset
  end_x = start_x + border_length
  end_y = bottom - offset

  cairo_move_to (viewport, start_x, start_y)
  cairo_line_to (viewport, end_x, end_y)
  cairo_stroke (viewport)
end

-- Draws the dotted grid
function draw_grid (viewport)
  local step = 20
  local radius = 1
  local start_angle = 0
  local end_angle = 2 / math.pi

  cairo_set_line_width (viewport, 1)
  cairo_set_source_rgba (viewport, 0, 0, 0, 0.5)

  -- Draw circles in a grid layout stepped in fixed gaps
  for x = left, right, step do
    for y = top, bottom, step do
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