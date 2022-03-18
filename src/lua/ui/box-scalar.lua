-- A ui component to render a scalar box with a glyph facade

local Glyph = require "glyph"

local BoxScalar = {
  canvas = nil,
  data = {
    value = 0
  },
  style = {
    size = 48,
    back = { 1, 1, 1, 0.8 },
    shade = { 0.9, 0.6, 0, 0.6 },
    front = { 0.2, 0.2, 0.2, 1 },
    dim = { 1, 1, 1, 0.4 }
  },
  box = nil,
  shade = nil,
  glyph = nil,
  tag = nil,
  x = 0,
  y = 0,
  width = 0,
  height = 0
}

function BoxScalar:new (canvas, value, glyph, size)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.data.value = value

  o.style.size = size or o.style.size

  o.box = Glyph:new (o.canvas, Glyph.Box, o.style.size, o.style.back)

  if o.data.value > 0 then
    o.shade = Glyph:new (o.canvas, Glyph.Scalars[o.data.value], o.style.size, o.style.shade)
  end

  o.glyph = Glyph:new (o.canvas, glyph, o.style.size, o.style.front)

  if o.data.value >= 5 then
    o.tag = Glyph:new (o.canvas, Glyph.High, o.style.size, o.style.dim)
  elseif o.data.value <= 1 then
    o.tag = Glyph:new (o.canvas, Glyph.Low, o.style.size, o.style.dim)
  end

  o.x = 0
  o.y = 0

  o.width = o.box.width
  o.height = o.box.height

  return o
end

function BoxScalar:locate (x, y)
  self.x = x
  self.y = y
end

function BoxScalar:render ()
  self.box:locate (self.x, self.y)
  self.box:render ()

  if self.shade then
    self.shade:locate (self.x, self.y)
    self.shade:render ()
  end

  self.glyph:locate (self.x, self.y)
  self.glyph:render ()

  if self.tag then
    local y = self.y + (20 * self.canvas.scale) + self.tag.height

    self.tag:locate (self.x, y)
    self.tag:render ()
  end
end

return BoxScalar