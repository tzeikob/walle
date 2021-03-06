-- A component to render simple text

local Text = {
  canvas = nil
}

function Text:new (canvas, value, face, size, slanted, bold, color)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value
  o.face = face
  o.size = size * o.canvas.scale
  o.slanted = slanted
  o.bold = bold
  o.color = color

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