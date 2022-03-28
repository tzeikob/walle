-- A component to render timings metrics and status

local Spinner = require "spinner"

local Timings = {
  canvas = nil,
  style = {
    margin_top = 50
  }
}

function Timings:new (canvas, data)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.data = data

  o.hours = Spinner:new (o.canvas, o.data.uptime.hours, 24, 32)

  o.x = 0
  o.y = 0

  return o
end

function Timings:locate (x, y)
  self.x = x
  self.y = y
end

function Timings:render ()
  local scale = self.canvas.scale
  local margin_top = self.style.margin_top * scale

  local x = self.x - (self.hours.width / 2)
  local y = self.y + margin_top

  self.hours:locate (x, y)
  self.hours:render ()
end

return Timings