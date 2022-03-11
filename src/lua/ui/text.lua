-- A ui component to render simple text

local Text = {
  canvas = nil,
  face = "",
  value = "",
  size = 0,
  slanted = false,
  bold = false,
  color = { 1, 1, 1, 1 },
  x = 0,
  y = 0,
  width = 0,
  height = 0
}

function Text:new (canvas, face, value, size, slanted, bold, color)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas

  o.face = face or ""
  o.value = value or ""
  o.size = size or 0
  o.slanted = slanted or false
  o.bold = bold or false
  o.color = color or { 1, 1, 1, 1 }

  o.x = 0
  o.y = 0

  o.canvas:set_font (o.face, o.size, o.slanted, o.bold)
  local dims = o.canvas:resolve_text (o.value)

  o.width = dims.width
  o.height = dims.height

  return o
end

function Text:locate (x, y)
  self.x = x
  self.y = y
end

function Text:render ()
  self.canvas:set_font (self.face, self.size, self.slanted, self.bold)
  self.canvas:set_color (self.color)

  self.canvas:draw_text (self.x, self.y, self.value)
end

return Text