-- A lua module to expose cairo 2d canvas to draw ui components on

local cairo = require "cairo"

local Canvas = {
  display = nil,
  drawable = nil,
  visual = nil,
  context = nil,
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

function Canvas:new (window, dark, scale, offsets)
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
  o.context = cairo_create (o.surface)

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
  o.left = o.margin
  o.top = o.margin
  o.right = o.width - o.margin
  o.bottom = o.height - o.margin

  -- Move boudnary edges with respect to the given offsets
  o.left = o.left + offsets.left
  o.top = o.top + offsets.top
  o.right = o.right + offsets.right
  o.bottom = o.bottom + offsets.bottom

  return o
end

function Canvas:dispose ()
  cairo_destroy (self.context)
  cairo_surface_destroy (self.surface)

  -- Release object references from memory
  self.context = nil
  self.surface = nil
  self.extents = nil
end

function Canvas:draw_line (x1, y1, x2, y2, width, color)
  cairo_set_source_rgba (self.context, unpack (color))

  cairo_set_line_width (self.context, width)
  cairo_set_line_cap (self.context, CAIRO_LINE_CAP_SQUARE)

  cairo_move_to (self.context, x1, y1)
  cairo_line_to (self.context, x2, y2)
  cairo_stroke (self.context)
end

function Canvas:draw_dot (x, y, radius, color)
  cairo_set_source_rgba (self.context, unpack (color))

  cairo_set_line_width (self.context, 1 * self.scale)

  cairo_arc (self.context, x, y, radius, 0, 2 * math.pi)
  cairo_fill (self.context)
end

return {
  Canvas = Canvas
}