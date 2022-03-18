-- A component to render a glyph icon

local Glyph = {
  canvas = nil,
  style = {
    face = "Walle Glyphs"
  },
  Box = "0",
  Scalars = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},
  Stroke = "K",
  Click = "C",
  Move = "M",
  Scroll = "S",
  Low = "<",
  High = ">",
  Hand = "H",
  Infinity = "&"
}

function Glyph:new (canvas, char, size, color)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.char = char
  o.size = size
  o.color = color

  o.x = 0
  o.y = 0

  canvas:set_font (o.style.face, size, false, false)
  local dims = canvas:resolve_text (char)

  o.width = dims.width
  o.height = dims.height

  return o
end

function Glyph:locate (x, y)
  self.x = x
  self.y = y
end

function Glyph:render ()
  self.canvas:set_font (self.style.face, self.size, false, false)
  self.canvas:set_color (self.color)

  self.canvas:draw_text (self.x, self.y, self.char)
end

return Glyph