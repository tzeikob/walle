-- A component to render user's health and status metrics

local Metric = require "metric"
local Blocks = require "blocks"
local Bar = require "bar"
local Login = require "login"
local Image = require "image"

local Status = {
  canvas = nil,
  style = {
    skew_yx = -0.06,
    skew_xy = -0.2,
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

  o.score = Metric:new (o.canvas, o.data.energy, 999, "%03d", 38, o.style.color)
  o.blocks = Blocks:new (o.canvas, o.data.energy, 999, 20, 240, 20)
  o.bar = Bar:new (o.canvas, o.data.energy, 999, 240, 6)
  o.login = Login:new (o.canvas, o.data.username, o.data.connected, 0, 0)

  -- Calculate the avatar size equal to the total height
  local scale = o.canvas.scale
  local padding = o.style.padding * scale

  local size = o.login.height + o.bar.height + o.blocks.height + o.score.height
  size = size + (3 * padding)

  o.avatar = Image:new (o.canvas, o.data.avatar, size / scale)

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
  local skew_yx = self.style.skew_yx
  local skew_xy = self.style.skew_xy

  local margin_left = self.style.margin_left * scale
  local margin_bottom = self.style.margin_bottom * scale
  local padding = self.style.padding * scale

  local x = self.x + margin_left
  local y = self.y - margin_bottom

  local dx = -1 * skew_xy * y
  local dy = -1 * skew_yx * x

  self.avatar:locate (x, y - dy * 2)
  self.avatar:render ()

  self.canvas:apply_transform (1.0, skew_yx, skew_xy, 1.0, dx, dy)

  self.login:locate (x + self.avatar.width + padding, y)
  self.login:render ()

  self.bar:locate (self.login.x, self.login.y - self.login.height - self.bar.height - padding)
  self.bar:render ()

  self.blocks:locate (self.bar.x, self.bar.y - self.blocks.height - padding)
  self.blocks:render ()

  self.score:locate (self.blocks.x, self.blocks.y - padding)
  self.score:render ()

  self.canvas:restore_transform ()
end

return Status