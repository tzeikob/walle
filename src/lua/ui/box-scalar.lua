-- A component for scalar values drawn as a shaded box with a glyph facade

local Glyph = require "glyph"

local BoxScalar = {
  canvas = nil,
  style = {
    base = { 1, 1, 1, 0.8 },
    scalar = { 1, 0.6, 0, 0.6 },
    glyph = { 0.2, 0.2, 0.2, 1 },
    tag = { 1, 1, 1, 0.4 }
  }
}

function BoxScalar:new (canvas, value, size, glyph)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value
  o.size = size

  o.base = Glyph:new (canvas, Glyph.Box, size, o.style.base)

  if value > 0 then
    o.scalar = Glyph:new (canvas, Glyph.Scalars[value], size, o.style.scalar)
  end

  o.glyph = Glyph:new (canvas, glyph, size, o.style.glyph)

  if value >= 5 then
    o.tag = Glyph:new (canvas, Glyph.High, size, o.style.tag)
  elseif value <= 1 then
    o.tag = Glyph:new (canvas, Glyph.Low, size, o.style.tag)
  end

  o.x = 0
  o.y = 0

  o.width = o.base.width
  o.height = o.base.height

  return o
end

function BoxScalar:locate (x, y)
  self.x = x
  self.y = y
end

function BoxScalar:render ()
  self.base:locate (self.x, self.y)
  self.base:render ()

  if self.scalar then
    self.scalar:locate (self.x, self.y)
    self.scalar:render ()
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