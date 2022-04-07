-- A component to render timings metrics and status

local Spinner = require "spinner"
local Ticker = require "ticker"

local Timings = {
  canvas = nil,
  style = {
    margin_top = 50,
    padding = 10
  }
}

function Timings:new (canvas, data)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.data = data

  o.hours = Spinner:new (o.canvas, o.data.uptime.hours, 24, 32)

  local width = math.floor ((o.hours.width / o.canvas.scale) * 0.95)
  local value = o.data.uptime.secs + (60 * o.data.uptime.mins)
  o.mins = Ticker:new (o.canvas, value, 60 * 60, 12, width, 5)

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
  local padding = self.style.padding * scale

  local x = self.x - (self.hours.width / 2)
  local y = self.y + margin_top

  self.hours:locate (x, y)
  self.hours:render ()

  x = self.hours.x + ((self.hours.width - self.mins.width) / 2)
  y = self.hours.y + padding

  self.mins:locate (x, y)
  self.mins:render ()
end

return Timings