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
  viewport.extents = cairo_text_extents_t:create ()
  tolua.takeownership (viewport.extents)

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

-- Renders all the ui components
function render ()
  if debug_mode then
    local grid = grid.Grid:new ({ 1, 1, 1, 0.8 })
    grid:render ()
  end
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
  render = render,
  destroy = destroy
}