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

  -- Set the horizontal and vertical middle lines
  o.center_x = o.left + (o.width / 2)
  o.center_y = o.top + (o.height / 2)

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

function Canvas:draw_round_rectangle (x, y, width, height, radius, color)
  local deg = math.pi / 180.0

  cairo_new_sub_path (self.context)

  cairo_arc (self.context, x + width - radius, y + radius, radius, -90 * deg, 0 * deg)
  cairo_arc (self.context, x + width - radius, y + height - radius, radius, 0 * deg, 90 * deg)
  cairo_arc (self.context, x + radius, y + height - radius, radius, 90 * deg, 180 * deg)
  cairo_arc (self.context, x + radius, y + radius, radius, 180 * deg, 270 * deg)

  cairo_close_path (self.context)

  self:set_color(color)
  cairo_fill (self.context)
end

function Canvas:draw_gradient (x, y, width, height, color)
  local context = self.context

  local pattern = cairo_pattern_create_linear (x, y, x + width, y)

  cairo_pattern_add_color_stop_rgba (pattern, 0, color[1], color[2], color[3], 0)
  cairo_pattern_add_color_stop_rgba (pattern, 0.25, unpack (color))
  cairo_pattern_add_color_stop_rgba (pattern, 0.75, unpack (color))
  cairo_pattern_add_color_stop_rgba (pattern, 1, color[1], color[2], color[3], 0)

  cairo_rectangle (context, x, y, width, height)
  cairo_set_source (context, pattern)
  cairo_fill (context)

  cairo_pattern_destroy (pattern)
end

function Canvas:draw_left_trapezoid (x, y, width, height, theta, portion, color)
  local tan = math.atan (theta)
  local adjacent = height / tan
  local fill_width = width * portion

  cairo_new_sub_path (self.context)
  cairo_line_to (self.context, x, y)

  if fill_width > adjacent then
    cairo_line_to (self.context, x + fill_width, y)
    cairo_line_to (self.context, x + fill_width, y + height)
    cairo_line_to (self.context, x + adjacent, y + height)
  else
    local opposite = fill_width * tan

    cairo_line_to (self.context, x + fill_width, y)
    cairo_line_to (self.context, x + fill_width, y + opposite)
  end

  cairo_close_path (self.context)

  self:set_color(color)
  cairo_fill (self.context)
end

function Canvas:draw_right_trapezoid (x, y, width, height, theta, portion, color)
  local tan = math.atan (theta)
  local adjacent = height / tan
  local fill_width = width * portion

  cairo_new_sub_path (self.context)

  cairo_line_to (self.context, x, y)

  if fill_width > width - adjacent then
    local opposite = (width - fill_width) * tan

    cairo_line_to (self.context, x + fill_width, y)
    cairo_line_to (self.context, x + fill_width, y + opposite)
    cairo_line_to (self.context, x + (width - adjacent), y + height)
    cairo_line_to (self.context, x, y + height)
  else
    cairo_line_to (self.context, x + fill_width, y)
    cairo_line_to (self.context, x + fill_width, y + height)
    cairo_line_to (self.context, x, y + height)
  end

  cairo_close_path (self.context)

  self:set_color(color)
  cairo_fill (self.context)
end

function Canvas:draw_dot (x, y, radius, color)
  cairo_arc (self.context, x, y, radius, 0, 2 * math.pi)

  self:set_color (color)
  cairo_fill (self.context)
end

function Canvas:create_image (file_path)
  local glob = {}

  glob.image = cairo_image_surface_create_from_png (file_path)
  glob.width = cairo_image_surface_get_width (glob.image)
  glob.height = cairo_image_surface_get_height (glob.image)

  return glob
end

function Canvas:paint_image (x, y, image)
  cairo_set_source_surface (self.context, image, x, y)

  cairo_paint (self.context)
end

return Canvas