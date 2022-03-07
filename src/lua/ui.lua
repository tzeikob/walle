-- A lua script exposes utilities to draw the ui

local cairo = require "cairo"
local grid = require "grid"

-- Viewport rendering object
viewport = {
  canvas = nil,
  surface = nil,
  extents = nil,
  dark = false,
  left = 0,
  top = 0,
  right = 0,
  bottom = 0,
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
  viewport.top = margin
  viewport.left = margin
  viewport.bottom = height - margin
  viewport.right = width - margin

  -- Move boudnary edges with respect to the given offsets
  viewport.top = viewport.top + offsets.top
  viewport.left = viewport.left + offsets.left
  viewport.bottom = viewport.bottom + offsets.bottom
  viewport.right = viewport.right + offsets.right
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
  local grid = grid.Grid:new ({ 1, 1, 1, 0.8 })
  grid:render ()

  local scale = viewport.scale

  local offset = 30 * scale
  local padding = 6 * scale

  local x = viewport.right - offset
  local y = viewport.top + offset

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
  attach = attach,
  render = render
}