-- A component to render monitoring values and status

local Load = require "load"

local Monitor = {
  canvas = nil,
  style = {
    margin_top = 50,
    margin_right = 50,
    padding = 10,
    offset = 4,
    skew_yx = 0.04,
    skew_xy = -0.08
  }
}

function Monitor:new (canvas, data)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.data = data

  o.core = Load:new (o.canvas, "CORE", data.cpu.util, "%02d", data.cpu.temp, 90)
  o.disp = Load:new (o.canvas, "FLOAT", data.gpu.util, "%02d", data.gpu.temp, 90)
  o.stack = Load:new (o.canvas, "STACK", data.mem.util, "%02d", nil, o.disp.width / o.canvas.scale)
  o.store = Load:new (o.canvas, "STORE", data.disk.util, "%02d", nil, o.stack.width / o.canvas.scale)

  o.x = 0
  o.y = 0

  return o
end

function Monitor:locate (x, y)
  self.x = x
  self.y = y
end

function Monitor:render ()
  local scale = self.canvas.scale
  local skew_yx = self.style.skew_yx
  local skew_xy = self.style.skew_xy

  local margin_top = self.style.margin_top * scale
  local margin_right = self.style.margin_right * scale
  local padding = self.style.padding * scale
  local offset = self.style.offset * scale

  local x = self.x - self.core.width - margin_right
  local y = self.y + self.core.height + margin_top

  local dx = -1 * skew_xy * y
  local dy = -1 * skew_yx * x

  self.canvas:apply_transform (1, skew_yx, skew_xy, 1, dx, dy)

  self.core:locate (x, y)
  self.core:render ()

  x = x + offset
  y = y + self.core.height + padding

  self.disp:locate (x, y)
  self.disp:render ()

  y = y + self.disp.height + padding

  self.stack:locate (x, y)
  self.stack:render ()

  y = y + self.stack.height + padding

  self.store:locate (x, y)
  self.store:render ()

  self.canvas:restore_transform ()
end

return Monitor