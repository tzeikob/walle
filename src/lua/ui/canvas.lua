-- A cairo based 2d canvas to draw ui components on

local cairo = require "cairo"

local Canvas = {}

function Canvas:new (window, dark, scale, offsets)
  local o = setmetatable ({}, self)
  self.__index = self

  -- Read conky window properties
  o.display = window.display
  o.drawable = window.drawable
  o.visual = window.visual
  o.window_width = window.width
  o.window_height = window.height

  -- Create the surface cairo object
  o.surface = cairo_xlib_surface_create (o.display, o.drawable, o.visual, o.window_width, o.window_height)

  -- Create the context object to draw on
  o.context = cairo_create (o.surface)

  -- Create a text processor to resolve text size in pixels
  o.extents = cairo_text_extents_t:create ()

  -- Set dark mode
  o.dark = dark

  o.scale = scale

  -- Set the boundary edges of the drawing area
  o.left = 0
  o.top = 0
  o.right = o.window_width
  o.bottom = o.window_height

  -- Shift boudnary edges with respect to the given offsets
  o.left = o.left + offsets.left
  o.top = o.top + offsets.top
  o.right = o.right + offsets.right
  o.bottom = o.bottom + offsets.bottom

  -- Set the dims of the actual drawing area
  o.width = o.right - o.left
  o.height = o.bottom - o.top

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

function Canvas:set_font (face, size, slanted, bold)
  local slant = CAIRO_FONT_SLANT_NORMAL

  if slanted then
    slant = CAIRO_FONT_SLANT_ITALIC
  end

  local weight = CAIRO_FONT_WEIGHT_NORMAL

  if bold then
    weight = CAIRO_FONT_WEIGHT_BOLD
  end

  cairo_select_font_face (self.context, face, slant, weight)
  self:set_font_size (size)
end

function Canvas:set_font_size (size)
  cairo_set_font_size (self.context, size)
end

function Canvas:set_color (color)
  cairo_set_source_rgba (self.context, unpack (color))
end

function Canvas:apply_transform (xx, yx, xy, yy, x0, y0)
  cairo_save (self.context)

  local matrix = cairo_matrix_t:create ()
  cairo_matrix_init (matrix, xx, yx, xy, yy, x0, y0)

  cairo_transform (self.context, matrix)
end

function Canvas:restore_transform ()
  cairo_restore (self.context)
end

function Canvas:resolve_text (text)
  cairo_text_extents (self.context, text, self.extents)

  return {
    width = self.extents.width,
    height = self.extents.height
  }
end

function Canvas:draw_text (x, y, text)
  cairo_move_to (self.context, x, y)

  cairo_text_path (self.context, text)
  cairo_fill (self.context)
end

function Canvas:draw_line (x1, y1, x2, y2, width, color)
  cairo_move_to (self.context, x1, y1)
  cairo_line_to (self.context, x2, y2)

  cairo_set_line_width (self.context, width)
  cairo_set_line_cap (self.context, CAIRO_LINE_CAP_SQUARE)

  self:set_color (color)
  cairo_stroke (self.context)
end

function Canvas:draw_rectangle (x, y, width, height, color)
  cairo_rectangle (self.context, x, y, width, height)

  self:set_color (color)
  cairo_fill (self.context)
end

function Canvas:draw_dot (x, y, radius, color)
  cairo_arc (self.context, x, y, radius, 0, 2 * math.pi)

  self:set_color (color)
  cairo_fill (self.context)
end

return Canvas