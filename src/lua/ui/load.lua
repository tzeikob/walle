-- A component to render a load value with label and optional thermal scalar

local Text = require "text"
local Thermal = require "thermal"

local Load = {
  canvas = nil,
  style = {
    padding = 6,
    gap = 3,
    roundness = 1,
    offset = 4,
    face = "UbuntuCondensend",
    size = 22,
    background = { 1, 1, 1, 0.9 },
    dim = { 1, 1, 1, 0.3 },
    color = { 0.1, 0.1, 0.1, 0.8 }
  }
}

function Load:new (canvas, label, value, format, temp, width)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.label = label
  o.value = value
  o.format = format
  o.temp = temp

  local text = string.format(o.format, o.value) .. " " .. o.label
  o.text = Text:new (o.canvas, text, o.style.face, o.style.size, false, false, o.style.color)

  if o.temp then
    o.thermal = Thermal:new (o.canvas, o.temp, o.text.height * 0.4)
  end

  o.x = 0
  o.y = 0

  local scale = o.canvas.scale
  local padding = o.style.padding * scale
  local gap = o.style.gap * scale

  local min_size = padding + o.text.width

  if o.thermal then
    min_size = min_size + gap + o.thermal.width
  end

  min_size = min_size + padding

  o.width = width * scale

  if o.width <= min_size then
    o.width = min_size
  end

  o.height = o.text.height + (padding * 2)

  return o
end

function Load:locate (x, y)
  self.x = x
  self.y = y
end

function Load:render ()
  local scale = self.canvas.scale

  local padding = self.style.padding * scale
  local gap = self.style.gap * scale
  local roundness = self.style.roundness * scale
  local offset = self.style.offset * scale

  local x = self.x
  local y = self.y - self.height

  self.canvas:draw_round_rectangle (x + offset, y + offset, self.width, self.height, roundness, self.style.dim)
  self.canvas:draw_round_rectangle (x, y, self.width, self.height, roundness, self.style.background)

  x = self.x + (self.width / 2) - (self.text.width / 2)

  if self.thermal then
    x = x - ((gap + self.thermal.width) / 2)
  end

  y = y + self.height - padding

  self.text:locate (x, y)
  self.text:render ()

  if self.thermal then
    x = self.text.x + self.text.width + gap
    y = self.text.y - self.text.height

    self.thermal:locate (x, y)
    self.thermal:render ()
  end
end

return Load