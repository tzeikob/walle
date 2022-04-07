-- A component for scalar values drawn as a shaded box with a glyph facade

local Glyph = require "glyph"

local Box = {
  canvas = nil,
  style = {
    roundness = 2,
    offset = 3,
    space = 20,
    background = { 1, 1, 1, 0.8 },
    dim = { 1, 1, 1, 0.1 },
    shade = { 1, 0.6, 0.1, 0.8 },
    color = { 0.2, 0.2, 0.2, 1 },
    tag = { 1, 1, 1, 0.4 }
  }
}

function Box:new (canvas, value, size, glyph)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value

  o.glyph = Glyph:new (o.canvas, glyph, size, o.style.color)

  if o.value >= 0.9 then
    o.tag = Glyph:new (o.canvas, Glyph.High, size, o.style.tag)
  elseif value <= 0.1 then
    o.tag = Glyph:new (o.canvas, Glyph.Low, size, o.style.tag)
  end

  o.x = 0
  o.y = 0

  o.width = size * 0.8 * o.canvas.scale
  o.height = o.width

  return o
end

function Box:locate (x, y)
  self.x = x
  self.y = y
end

function Box:render ()
  local scale = self.canvas.scale

  local roundness = self.style.roundness * scale
  local offset = self.style.offset * scale
  local space = self.style.space * scale

  local x = self.x
  local y = self.y - self.height

  self.canvas:draw_round_rectangle (x + offset, y + offset, self.width, self.height, roundness, self.style.dim, 1)
  self.canvas:draw_round_rectangle (x, y, self.width, self.height, roundness, self.style.background)

  if self.value > 0.05 then
    local shade_height = self.value * self.height
    y = self.y - shade_height

    self.canvas:draw_round_rectangle (x, y, self.width, shade_height, roundness, self.style.shade)
  end

  x = self.x
  y = self.y

  self.glyph:locate (x, y)
  self.glyph:render ()

  if self.tag then
    y = self.y + (space * self.canvas.scale) + self.tag.height

    self.tag:locate (x, y)
    self.tag:render ()
  end
end

return Box