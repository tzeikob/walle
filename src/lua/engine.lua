-- A lua module to expose cairo graphics utility methods

local function line (x1, y1, x2, y2, width, color)
  local canvas = viewport.canvas

  cairo_set_source_rgba (canvas, unpack (color))

  cairo_set_line_width (canvas, width)
  cairo_set_line_cap (canvas, CAIRO_LINE_CAP_SQUARE)

  cairo_move_to (canvas, x1, y1)
  cairo_line_to (canvas, x2, y2)
  cairo_stroke (canvas)
end

local function dot (x, y, radius, color)
  local canvas = viewport.canvas
  local scale = viewport.scale

  cairo_set_source_rgba (canvas, unpack (color))

  cairo_set_line_width (canvas, 1 * scale)

  cairo_arc (canvas, x, y, radius, 0, 2 * math.pi)
  cairo_fill (canvas)
end

return {
  line = line,
  dot = dot
}