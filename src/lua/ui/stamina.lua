-- A component to render user's health and stamina metrics

local Metric = require "metric"
local BlockScalar = require "block-scalar"
local BarScalar = require "bar-scalar"

local Stamina = {
  canvas = nil,
  style = {
    color = { 1, 1, 1, 0.8 }
  }
}

function Stamina:new (canvas, data)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.data = data

  local scale = canvas.scale

  o.score = Metric:new (canvas, data.energy, 999, "%03d", 38 * scale, o.style.color)
  o.blocks = BlockScalar:new (canvas, data.energy, 999, 20, 240 * scale, 20 * scale)
  o.bar = BarScalar:new (canvas, data.energy, 999, 240 * scale, 6 * scale)

  o.x = 0
  o.y = 0

  return o
end

function Stamina:locate (x, y)
  self.x = x
  self.y = y
end

function Stamina:render ()
  local scale = self.canvas.scale

  self.canvas:apply_transform (1.0, -0.06, -0.2, 1.0, 0.2 * self.y, 0.06 * self.x)

  self.bar:locate (self.x, self.y - self.bar.height)
  self.bar:render ()

  self.blocks:locate (self.bar.x, self.bar.y - self.blocks.height - (8 * scale))
  self.blocks:render ()

  self.score:locate (self.blocks.x, self.blocks.y - (8 * scale))
  self.score:render ()

  self.canvas:restore_transform ()
end

return Stamina