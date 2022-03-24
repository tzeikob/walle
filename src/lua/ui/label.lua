-- A component to render a label of text

local Text = require "text"

local Label = {
  canvas = nil,
  style = {
    margin = 6,
    padding = 3,
    dot_size = 6,
    roundness = 1,
    face = "UbuntuCondensend",
    size = 20,
    slanted = false,
    bold = false,
    background = { 1, 1, 1, 0.8 },
    color = { 0.1, 0.1, 0.1, 0.8 },
    on = { 0.1, 0.8, 0.1, 0.8 },
    off = { 0.8, 0.1, 0.1, 0.8 }
  }
}

function Label:new (canvas, value, connected, width, align)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.connected = connected
  o.width = width * o.canvas.scale
  o.align = align

  local face = o.style.face
  local size = o.style.size
  local slanted = o.style.slanted
  local bold = o.style.bold
  local color = o.style.color

  o.text = Text:new (o.canvas, value, face, size, slanted, bold, color)

  o.x = 0
  o.y = 0

  local scale = o.canvas.scale
  local margin = o.style.margin * scale
  local padding = o.style.padding * scale
  local dot_size = o.style.dot_size * scale

  local min_size = o.text.width + padding + dot_size + (margin * 2)

  if o.width < min_size then
    o.width = min_size
  end

  o.height = o.text.height + (margin * 2)

  return o
end

function Label:locate (x, y)
  self.x = x
  self.y = y
end

function Label:render ()
  local scale = self.canvas.scale

  local margin = self.style.margin * scale
  local padding = self.style.padding * scale
  local dot_size = self.style.dot_size * scale
  local roundness = self.style.roundness * scale

  local x = self.x
  local y = self.y - self.height

  self.canvas:draw_round_rectangle (x, y, self.width, self.height, roundness, self.style.background)

  -- Set center, left or right alignment
  x = self.x + (self.width / 2) - ((self.text.width + padding + dot_size) / 2)

  if self.align < 0 then
    x = self.x + margin
  elseif self.align > 0 then
    x = self.x + self.width - self.text.width - padding - dot_size - margin
  end

  y = y + self.height - margin

  self.text:locate (x, y)
  self.text:render ()

  local color = self.style.on

  if not self.connected then
    color = self.style.off
  end

  x = self.text.x + self.text.width + padding
  y = self.text.y - self.text.height

  self.canvas:draw_rectangle (x, y, dot_size, dot_size, color)
end

return Label