-- A ui component to render a scalar box with a glyph facade

local Glyph = require "glyph"

local Scalar = {
  canvas = nil,
  value = 0,
  size = 0,
  box = nil,
  shade = nil,
  glyph = nil,
  tag = nil,
  x = 0,
  y = 0,
  width = 0,
  height = 0
}

function Scalar:new (canvas, glyph, size, value)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas

  o.size = size or 0
  o.value = value or 0

  o.box = Glyph:new (o.canvas, Glyph.Box, o.size, { 1, 1, 1, 0.8 })
  o.shade = Glyph:new (o.canvas, Glyph.Scalars[o.value], o.size, { 1, 0.6, 0, 0.8 })
  o.glyph = Glyph:new (o.canvas, glyph, o.size, { 0.2, 0.2, 0.2, 1 })

  if o.value >= 5 then
    o.tag = Glyph:new (o.canvas, Glyph.High, o.size, { 1, 1, 1, 0.4 })
  elseif o.value <= 1 then
    o.tag = Glyph:new (o.canvas, Glyph.Low, o.size, { 1, 1, 1, 0.4 })
  end

  o.x = 0
  o.y = 0

  o.width = o.box.width
  o.height = o.box.height

  return o
end

function Scalar:locate (x, y)
  self.x = x
  self.y = y
end

function Scalar:render ()
  self.box:locate (self.x, self.y)
  self.box:render ()

  self.shade:locate (self.x, self.y)
  self.shade:render ()

  self.glyph:locate (self.x, self.y)
  self.glyph:render ()

  if self.tag then
    local y = self.y + (20 * self.canvas.scale) + self.tag.height

    self.tag:locate (self.x, y)
    self.tag:render ()
  end
end

return Scalar