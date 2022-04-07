-- A component to render a notification message

local format = require "format"
local Text = require "text"

local Message = {
  canvas = nil,
  style = {
    padding_top = 8,
    padding_bottom = 8,
    padding_left = 25,
    padding_right = 25,
    space = 5,
    face = "UbuntuCondensend",
    slanted = true,
    bold = false,
    background = { 0.2, 0.2, 0.2, 0.3 },
    color = { 1, 1, 1, 1 },
    high = { 1, 0.8, 0, 1 }
  }
}

function Message:new (canvas, text, size)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.text = text
  o.words = {}

  local splits = format.split (o.text, " ", false)

  for i = 1, table.getn (splits), 1 do
    local color = o.style.color
    local split = splits[i]

    if string.match (split, "h{.+}") then
      color = o.style.high
      split = string.sub (split, 3, #split - 1)
    end

    table.insert (o.words, Text:new (o.canvas, split, o.style.face, size, o.style.slanted, o.style.bold, color))
  end

  o.x = 0
  o.y = 0

  local scale = o.canvas.scale
  local padding_top = o.style.padding_top * scale
  local padding_bottom = o.style.padding_bottom * scale
  local padding_left = o.style.padding_left * scale
  local padding_right = o.style.padding_right * scale
  local space = o.style.space * scale

  o.width = padding_left

  for i = 1, table.getn (o.words), 1 do
    if i > 1 then
      o.width = o.width + space
    end

    o.width = o.width + o.words[i].width
  end

  o.width = o.width + padding_right
  o.height = padding_top + o.words[1].height + padding_bottom

  return o
end

function Message:locate (x, y)
  self.x = x
  self.y = y
end

function Message:render ()
  local scale = self.canvas.scale

  local padding_top = self.style.padding_top * scale
  local padding_bottom = self.style.padding_bottom * scale
  local padding_left = self.style.padding_left * scale
  local padding_right = self.style.padding_right * scale
  local space = self.style.space * scale

  local x = self.x
  local y = self.y - self.height

  self.canvas:draw_gradient (x, y, self.width, self.height, self.style.background)

  x = self.x + padding_left
  y = y + self.height - padding_bottom

  for i = 1, table.getn (self.words), 1 do
    if i > 1 then
      x = x + space
    end

    self.words[i]:locate (x, y)
    self.words[i]:render ()

    x = x + self.words[i].width
  end
end

return Message