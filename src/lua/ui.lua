-- A lua script exposes utilities to draw the ui

local cairo = require "cairo"

-- Conky's window width and height
local conky_width = 0
local conky_height = 0

-- Margin between conky's window and viewport
local margin = 10

-- Edges of the viewport drawing area
local top = 0
local left = 0
local bottom = 0
local right = 0

-- Viewport and surface cairo objects
local viewport = nil
local surface = nil

-- Initializes the drawing viewport given the conky window
function init (window, offsets)
  -- Read conky window properties
  local display = window.display
  local drawable = window.drawable
  local visual = window.visual
  local width = window.width
  local height = window.height

  -- Create the surface cairo object
  surface = cairo_xlib_surface_create (display, drawable, visual, width, height)

  -- Create the drawing viewport object
  viewport = cairo_create (surface)

  -- Store the width and height of the conky window
  conky_width = width
  conky_height = height

  -- Set top left bottom and right viewport edges
  top = margin
  left = margin
  bottom = conky_height - margin
  right = conky_width - margin

  -- Move viewport edges with respect to the given offsets
  top = top + offsets["top"]
  left = left + offsets["left"]
  bottom = bottom + offsets["bottom"]
  right = right + offsets["right"]
end

-- Destroys the viewport
function destroy ()
  cairo_destroy (viewport)
  cairo_surface_destroy (surface)

  -- Release object references from memory
  viewport = nil
  surface = nil
end

-- Draws the outer border module
function draw_border ()
  local line_width = 6
  local offset = math.floor (line_width / 2) + 2
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

-- Draws the dotted grid module
function draw_grid ()
  local step = 20
  local radius = 1
  local start_angle = 0
  local end_angle = 2 * math.pi

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

-- Renders ui modules into the viewport
function render (debug)
  if debug ~= nil and debug == "enabled" then
    draw_border ()
    draw_grid ()
  end
end

return {
  init = init,
  destroy = destroy,
  render = render
}