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
  extents = nil,
  dark = false,
  scale = 1
}

-- List of the ui components to render
local components = {}

-- Initializes the viewport given the conky window
function init (window, dark, scale, offsets)
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

  -- Initialize the processor to resolve text size in pixels
  viewport.extents = cairo_text_extents_t:create()
  tolua.takeownership(viewport.extents)

  -- Set dark mode
  viewport.dark = dark

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
function render_borders ()
  local canvas = viewport.canvas
  local scale = viewport.scale

  local line_width = 6 * scale
  local offset = (math.floor (line_width / 2) + 2) * scale
  local border_length = 30 * scale

  cairo_set_line_width (canvas, line_width)
  cairo_set_line_cap (canvas, CAIRO_LINE_CAP_SQUARE)

  -- Set drawing color
  local r, g, b = 1, 1, 1

  if viewport.dark then
    r, g, b = 0, 0, 0
  end

  cairo_set_source_rgba (canvas, r, g, b, 0.7)

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
function render_grid ()
  local canvas = viewport.canvas
  local scale = viewport.scale

  local step = 20 * scale
  local radius = 1 * scale
  local start_angle = 0
  local end_angle = 2 * math.pi

  cairo_set_line_width (canvas, 1 * scale)

  -- Set drawing color
  local r, g, b = 1, 1, 1

  if viewport.dark then
    r, g, b = 0, 0, 0
  end

  cairo_set_source_rgba (canvas, r, g, b, 0.5)

  -- Draw circles in a grid layout stepped in fixed gaps
  for x = left, right, step do
    for y = top, bottom, step do
      cairo_arc (canvas, x, y, radius, start_angle, end_angle)
      cairo_fill (canvas)
    end
  end
end

-- Resolves the given text as a text ui component
function resolve_text (text, size)
  if text == nil or text == "" then
    return nil
  end

  local canvas = viewport.canvas
  local extents = viewport.extents

  local font = {
    name = "Ubuntu Mono",
    slant = CAIRO_FONT_SLANT_ITALIC,
    face = CAIRO_FONT_WEIGHT_BOLD,
    size = size * viewport.scale
  }

  -- Set font and styles
  cairo_select_font_face (canvas, font.name, font.slant, font.face)
  cairo_set_font_size (canvas, font.size)

  -- Resolve the size the text will take in canvas
  cairo_text_extents (canvas, text, extents)

  return {
    value = text,
    font = font,
    width = extents.width,
    height = extents.height
  }
end

-- Register the given values as a concrete ui component
function attach (label, val1, val2)
  -- Resolve any given argument into its text ui component
  label = resolve_text (label, 30)
  val1 = resolve_text (val1, 24)
  val2 = resolve_text (val2, 24)

  -- Compute the total width and height of the component
  local padding = 6 * viewport.scale

  -- Set as the width the lenghtiest line
  local width = label.width

  if width < val1.width + padding + val2.width then
    width = val1.width + padding + val2.width
  end

  local height = label.height + padding + val1.height

  -- Encapsulate the values into a concrete component
  local component = {
    label = label,
    val1 = val1,
    val2 = val2,
    val3 = val3,
    width = width,
    height = height
  }

  -- Add the component into the rendering list
  table.insert (components, component)
end

-- Renders the given text component at the given location in canvas
function draw_text (text, x, y)
  local canvas = viewport.canvas

  -- Set text font and styles
  local font = text.font

  cairo_select_font_face (canvas, font.name, font.slant, font.face)
  cairo_set_font_size (canvas, font.size)

  -- Set font color
  local r, g, b = 1, 1, 1

  if viewport.dark then
    r, g, b = 0, 0, 0
  end

  cairo_set_source_rgba (canvas, r, g, b, 1)

  -- Draw text at the location in canvas
  cairo_move_to (canvas, x, y)
  cairo_show_text (canvas, text.value)
  cairo_stroke (canvas)
end

-- Renders all the ui components
function render ()
  local scale = viewport.scale

  local offset = 30 * scale
  local padding = 6 * scale

  local x = right - offset
  local y = top + offset

  for i, component in ipairs (components) do
    x = x - component.width
    y = y + component.height

    draw_text (component.label, x, y)

    x = x + 4
    y = y - component.label.height - padding

    draw_text (component.val1, x, y)

    x = x + component.val1.width + padding

    draw_text (component.val2, x, y)

    x = x - 4 - component.val1.width - padding - offset
    y = y + component.label.height + padding - component.height
  end

  -- Clear the rendering list
  components = {}
end

-- Destroys the viewport references
function destroy ()
  cairo_destroy (viewport.canvas)
  cairo_surface_destroy (viewport.surface)

  -- Release object references from memory
  viewport.canvas = nil
  viewport.surface = nil
  viewport.extents = nil
end

return {
  init = init,
  destroy = destroy,
  render_borders = render_borders,
  render_grid = render_grid,
  attach = attach,
  render = render
}