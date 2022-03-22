-- A component to render user's health and status metrics

local Metric = require "metric"
local Blocks = require "blocks"
local Bar = require "bar"
local Label = require "label"

local Status = {
  canvas = nil,
  style = {
    margin_left = 50,
    margin_bottom = 80,
    padding = 8,
    color = { 1, 1, 1, 0.8 }
  }
}

function Status:new (canvas, data)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.data = data

  o.score = Metric:new (o.canvas, data.energy, 999, "%03d", 38, o.style.color)
  o.blocks = Blocks:new (o.canvas, data.energy, 999, 20, 240, 20)
  o.bar = Bar:new (o.canvas, data.energy, 999, 240, 6)
  o.label = Label:new (o.canvas, data.username, "UbuntuCondensed", 16, false, false, { 0.1, 0.1, 0.1, 0.8 }, 0, { 1, 1, 1, 0.8 }, 0)

  o.x = 0
  o.y = 0

  return o
end

function Status:locate (x, y)
  self.x = x
  self.y = y
end

function Status:render ()
  local scale = self.canvas.scale

  local margin_left = self.style.margin_left * scale
  local margin_bottom = self.style.margin_bottom * scale
  local padding = self.style.padding * scale

  self.x = self.x + margin_left
  self.y = self.y - margin_bottom

  self.canvas:apply_transform (1.0, -0.06, -0.2, 1.0, 0.2 * self.y, 0.06 * self.x)

  self.label:locate (self.x, self.y)
  self.label:render ()

  self.bar:locate (self.label.x, self.label.y - self.label.height - self.bar.height - padding)
  self.bar:render ()

  self.blocks:locate (self.bar.x, self.bar.y - self.blocks.height - padding)
  self.blocks:render ()

  self.score:locate (self.blocks.x, self.blocks.y - padding)
  self.score:render ()

  self.canvas:restore_transform ()
end

return Status