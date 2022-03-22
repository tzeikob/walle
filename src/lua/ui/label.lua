-- A component to render a label of text

local Text = require "text"

local Label = {
  canvas = nil,
  style = {
    margin = 6,
    roundness = 2
  }
}

function Label:new (canvas, value, face, size, slanted, bold, color, width, background, align)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.width = width * o.canvas.scale
  o.background = background
  o.align = align

  o.text = Text:new (o.canvas, value, face, size, slanted, bold, color)

  o.x = 0
  o.y = 0

  local scale = o.canvas.scale

  if o.width < o.text.width then
    o.width = o.text.width + (o.style.margin * scale * 2)
  end

  o.height = o.text.height + (o.style.margin * scale * 2)

  return o
end

function Label:locate (x, y)
  self.x = x
  self.y = y
end

function Label:render ()
  local scale = self.canvas.scale
  local margin = self.style.margin * scale
  local roundness = self.style.roundness * scale

  local x = self.x
  local y = self.y - self.height

  self.canvas:draw_round_rectangle (x, y, self.width, self.height, roundness, self.background)

  x = self.x + (self.width / 2) - (self.text.width / 2)

  if self.align < 0 then
    x = self.x + margin
  elseif self.align > 0 then
    x = self.x + self.width - self.text.width - margin
  end

  y = y + self.height - margin

  self.text:locate (x, y)
  self.text:render ()
end

return Label