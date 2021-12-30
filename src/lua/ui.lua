-- A lua script exposes utilities to draw the ui

-- Global viewport width and height
local width = 0
local height = 0

-- Initializes global ui properties
function init (screen_width, screen_height)
  width = screen_width
  height = screen_height
end

-- Draws the outer frame corner borders
function draw_frame (viewport)
  local length = 30
  local line_width = 4
  local line_cap = CAIRO_LINE_CAP_SQUARE
  local red, green, blue, alpha = 1, 1, 1, 1

  cairo_set_line_width (viewport, line_width)
  cairo_set_line_cap  (viewport, line_cap)
  cairo_set_source_rgba (viewport, red, green, blue, alpha)

  -- Draw top left corner
  local startx = 8
  local starty = 35
  local endx = 8
  local endy = starty + length

  cairo_move_to (viewport, startx, starty)
  cairo_line_to (viewport, endx, endy)
  cairo_stroke (viewport)

  startx = 8
  starty = 35
  endx = startx + length
  endy = 35

  cairo_move_to (viewport, startx, starty)
  cairo_line_to (viewport, endx, endy)
  cairo_stroke (viewport)

  -- Draw top right corner
  startx = width - 8
  starty = 35
  endx = width - 8
  endy = starty + length

  cairo_move_to (viewport, startx, starty)
  cairo_line_to (viewport, endx, endy)
  cairo_stroke (viewport)

  startx = width - 8
  starty = 35
  endx = startx - length
  endy = 35

  cairo_move_to (viewport, startx, starty)
  cairo_line_to (viewport, endx, endy)
  cairo_stroke (viewport)

  -- Draw bottom right corner
  startx = width - 8
  starty = height - 8
  endx = width - 8
  endy = starty - length

  cairo_move_to (viewport, startx, starty)
  cairo_line_to (viewport, endx, endy)
  cairo_stroke (viewport)

  startx = width - 8
  starty = height - 8
  endx = startx - length
  endy = height - 8

  cairo_move_to (viewport, startx, starty)
  cairo_line_to (viewport, endx, endy)
  cairo_stroke (viewport)

  -- Draw bottom left corner
  startx = 8
  starty = height - 8
  endx = 8
  endy = starty - length

  cairo_move_to (viewport, startx, starty)
  cairo_line_to (viewport, endx, endy)
  cairo_stroke (viewport)

  startx = 8
  starty = height - 8
  endx = startx + length
  endy = height - 8

  cairo_move_to (viewport, startx, starty)
  cairo_line_to (viewport, endx, endy)
  cairo_stroke (viewport)
end

return {
  init = init,
  draw_frame = draw_frame
}