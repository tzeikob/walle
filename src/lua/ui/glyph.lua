-- A basic ui component to render a glyph icon

local Glyph = {
  canvas = nil,
  face = "Wallecons",
  char = "",
  size = 0,
  color = { 1, 1, 1, 1 },
  x = 0,
  y = 0,
  width = 0,
  height = 0,
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

  o.char = char or ""
  o.size = size or 0
  o.color = color or { 1, 1, 1, 1 }

  o.x = 0
  o.y = 0

  o.canvas:set_font (o.face, o.size, false, false)
  local dims = o.canvas:resolve_text (o.char)

  o.width = dims.width
  o.height = dims.height

  return o
end

function Glyph:locate (x, y)
  self.x = x
  self.y = y
end

function Glyph:render ()
  self.canvas:set_font (self.face, self.size, false, false)
  self.canvas:set_color (self.color)

  self.canvas:draw_text (self.x, self.y, self.char)
end

return Glyph