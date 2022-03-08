-- A lua module to expose cairo graphics utility methods

local cairo = require "cairo"

local Graphics = {
  display = nil,
  drawable = nil,
  visual = nil,
  canvas = nil,
  surface = nil,
  extents = nil,
  dark = false,
  scale = 1,
  width = 0,
  height = 0,
  margin = 10,
  left = 0,
  top = 0,
  right = 0,
  bottom = 0
}

function Graphics:new (window, dark, scale, offsets)
  local o = setmetatable ({}, self)
  self.__index = self

  -- Read conky window properties
  o.display = window.display
  o.drawable = window.drawable
  o.visual = window.visual
  o.width = window.width
  o.height = window.height

  -- Create the surface cairo object
  o.surface = cairo_xlib_surface_create (o.display, o.drawable, o.visual, o.width, o.height)

  -- Create the drawing context object
  o.canvas = cairo_create (o.surface)

  -- Initialize the processor to resolve text size in pixels
  o.extents = cairo_text_extents_t:create ()
  tolua.takeownership (o.extents)

  -- Set dark mode
  o.dark = dark or false

  -- Set the scaling factor
  o.scale = scale or 1

  -- Apply scaliing to the margins
  o.margin = o.margin * o.scale

  -- Set the boundary edges of the drawing area
  o.top = o.margin
  o.left = o.margin
  o.bottom = o.height - o.margin
  o.right = o.width - o.margin

  -- Move boudnary edges with respect to the given offsets
  o.top = o.top + offsets.top
  o.left = o.left + offsets.left
  o.bottom = o.bottom + offsets.bottom
  o.right = o.right + offsets.right

  return o
end

function Graphics:dispose ()
  cairo_destroy (self.canvas)
  cairo_surface_destroy (self.surface)

  -- Release object references from memory
  self.canvas = nil
  self.surface = nil
  self.extents = nil
end

function Graphics:draw_line (x1, y1, x2, y2, width, color)
  cairo_set_source_rgba (self.canvas, unpack (color))

  cairo_set_line_width (self.canvas, width)
  cairo_set_line_cap (self.canvas, CAIRO_LINE_CAP_SQUARE)

  cairo_move_to (self.canvas, x1, y1)
  cairo_line_to (self.canvas, x2, y2)
  cairo_stroke (self.canvas)
end

function Graphics:draw_dot (x, y, radius, color)
  cairo_set_source_rgba (self.canvas, unpack (color))

  cairo_set_line_width (self.canvas, 1 * self.scale)

  cairo_arc (self.canvas, x, y, radius, 0, 2 * math.pi)
  cairo_fill (self.canvas)
end

return {
  Graphics = Graphics
}