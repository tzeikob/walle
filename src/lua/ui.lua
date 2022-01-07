-- A lua script exposes utilities to draw the ui

local cairo = require "cairo"

-- Boundary edges of the drawing area
local top = 0
local left = 0
local bottom = 0
local right = 0

-- Viewport rendering object
local viewport = {
  canvas = nil,
  surface = nil,
  scale = 1
}

-- Initializes the drawing viewport given the conky window
function init (window, scale, offsets)
  -- Read conky window properties
  local display = window.display
  local drawable = window.drawable
  local visual = window.visual
  local width = window.width
  local height = window.height

  -- Create the surface cairo object
  viewport.surface = cairo_xlib_surface_create (display, drawable, visual, width, height)

  -- Create the drawing context object
  viewport.canvas = cairo_create (viewport.surface)

  -- Set the scaling factor
  viewport.scale = scale

  -- Set the margin between conky's window and viewport
  local margin = 10 * viewport.scale

  -- Set the boundary edges of the drawing area
  top = margin
  left = margin
  bottom = height - margin
  right = width - margin

  -- Move boudnary edges with respect to the given offsets
  top = top + offsets.top
  left = left + offsets.left
  bottom = bottom + offsets.bottom
  right = right + offsets.right
end

-- Draws the outer border module
function draw_border ()
  local canvas = viewport.canvas
  local scale = viewport.scale

  local line_width = 6 * scale
  local offset = (math.floor (line_width / 2) + 2) * scale
  local border_length = 30 * scale

  cairo_set_line_width (canvas, line_width)
  cairo_set_line_cap (canvas, CAIRO_LINE_CAP_SQUARE)
  cairo_set_source_rgba (canvas, 0, 0, 0, 0.7)

  -- Draw the vertical edge of the top left corner
  local start_x = left + offset
  local start_y = top + offset
  local end_x = left + offset
  local end_y = start_y + border_length

  cairo_move_to (canvas, start_x, start_y)
  cairo_line_to (canvas, end_x, end_y)
  cairo_stroke (canvas)

  -- Draw the horizontal edge of the top left corner
  start_x = left + offset
  start_y = top + offset
  end_x = start_x + border_length
  end_y = top + offset

  cairo_move_to (canvas, start_x, start_y)
  cairo_line_to (canvas, end_x, end_y)
  cairo_stroke (canvas)

  -- Draw the vertical edge of the top right corner
  start_x = right - offset
  start_y = top + offset
  end_x = right - offset
  end_y = start_y + border_length

  cairo_move_to (canvas, start_x, start_y)
  cairo_line_to (canvas, end_x, end_y)
  cairo_stroke (canvas)

  -- Draw the horizontal edge of the top right corner
  start_x = right - offset
  start_y = top + offset
  end_x = start_x - border_length
  end_y = top + offset

  cairo_move_to (canvas, start_x, start_y)
  cairo_line_to (canvas, end_x, end_y)
  cairo_stroke (canvas)

  -- Draw the vertical edge of the bottom right corner
  start_x = right - offset
  start_y = bottom - offset
  end_x = right - offset
  end_y = start_y - border_length

  cairo_move_to (canvas, start_x, start_y)
  cairo_line_to (canvas, end_x, end_y)
  cairo_stroke (canvas)

  -- Draw the horizontal edge of the bottom right corner
  start_x = right - offset
  start_y = bottom - offset
  end_x = start_x - border_length
  end_y = bottom - offset

  cairo_move_to (canvas, start_x, start_y)
  cairo_line_to (canvas, end_x, end_y)
  cairo_stroke (canvas)

  -- Draw the vertical edge of the botom left corner
  start_x = left + offset
  start_y = bottom - offset
  end_x = left + offset
  end_y = start_y - border_length

  cairo_move_to (canvas, start_x, start_y)
  cairo_line_to (canvas, end_x, end_y)
  cairo_stroke (canvas)

  -- Draw the horizontal edge of the bottom left corner
  start_x = left + offset
  start_y = bottom - offset
  end_x = start_x + border_length
  end_y = bottom - offset

  cairo_move_to (canvas, start_x, start_y)
  cairo_line_to (canvas, end_x, end_y)
  cairo_stroke (canvas)
end

-- Draws the dotted grid module
function draw_grid ()
  local canvas = viewport.canvas
  local scale = viewport.scale

  local step = 20 * scale
  local radius = 1 * scale
  local start_angle = 0
  local end_angle = 2 * math.pi

  cairo_set_line_width (canvas, 1 * scale)
  cairo_set_source_rgba (canvas, 0, 0, 0, 0.5)

  -- Draw circles in a grid layout stepped in fixed gaps
  for x = left, right, step do
    for y = top, bottom, step do
      cairo_arc (canvas, x, y, radius, start_angle, end_angle)
      cairo_fill (canvas)
    end
  end
end

-- Renders ui modules into the viewport
function render (debug_mode)
  if debug_mode then
    draw_border ()
    draw_grid ()
  end
end

-- Destroys the viewport
function destroy ()
  cairo_destroy (viewport.canvas)
  cairo_surface_destroy (viewport.surface)

  -- Release object references from memory
  viewport.canvas = nil
  viewport.surface = nil
end

return {
  init = init,
  render = render,
  destroy = destroy
}