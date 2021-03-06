-- A component to render metrics from the user input

local convert = require "convert"
local Glyph = require "glyph"
local Metric = require "metric"
local Box = require "box"

local Actions = {
  canvas = nil,
  style = {
    skew_yx = 0.1,
    skew_xy = -0.2,
    margin_right = 50,
    margin_bottom = 80,
    color = { 1, 1, 1, 0.8 },
    dim = { 1, 1, 1, 0.4 }
  }
}

function Actions:new (canvas, data)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.data = data

  o.score = Metric:new (o.canvas, o.data.total, nil, "%06d", 32, o.style.color)
  o.hand = Glyph:new (o.canvas, Glyph.Hand, 48, o.style.color)
  o.tags = {
    Glyph:new (o.canvas, Glyph.Infinity, 36, o.style.dim)
  }

  local scalar = convert.round (o.data.scrolls_rate, 2)
  o.scrolls = Box:new (o.canvas, scalar, 52, Glyph.Scroll)

  scalar = convert.round (o.data.moves_rate, 2)
  o.moves = Box:new (o.canvas, scalar, 52, Glyph.Move)

  scalar = convert.round (o.data.clicks_rate, 2)
  o.clicks = Box:new (o.canvas, scalar, 52, Glyph.Click)

  scalar = convert.round (o.data.strokes_rate, 2)
  o.strokes = Box:new (o.canvas, scalar, 52, Glyph.Stroke)

  o.x = 0
  o.y = 0

  return o
end

function Actions:locate (x, y)
  self.x = x
  self.y = y
end

function Actions:render ()
  local scale = self.canvas.scale
  local skew_yx = self.style.skew_yx
  local skew_xy = self.style.skew_xy

  local margin_right = self.style.margin_right * scale
  local margin_bottom = self.style.margin_bottom * scale

  local x = self.x - margin_right
  local y = self.y - margin_bottom

  local dx = -1 * skew_xy * y
  local dy = -1 * skew_yx * x

  self.canvas:apply_transform (1, skew_yx, skew_xy, 1, dx, dy)

  self.hand:locate (x - self.hand.width, y)
  self.hand:render ()

  for i = 1, table.getn (self.tags) do
    local tag_x = self.hand.x + self.hand.width - self.tags[i].width
    local tag_y = self.hand.y + (32 * scale)

    if i > 1 then
      local tag_x = self.tags[i - 1].x - self.tags[i].width - (6 * scale)
    end

    self.tags[i]:locate (tag_x, tag_y)
    self.tags[i]:render ()
  end

  local x1 = self.hand.x - (4 * scale)
  local y1 = self.hand.y + (6 * scale)

  local x2 = self.hand.x + self.hand.width + (6 * scale)
  local y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, 1 * scale, self.style.dim)

  y1 = self.hand.y - self.hand.height - (6 * scale)
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, 1 * scale, self.style.dim)

  self.score:locate (
    self.hand.x + self.hand.width - self.score.width,
    self.hand.y - self.hand.height - (18 * scale))
  self.score:render ()

  self.scrolls:locate (
    self.hand.x - self.scrolls.width - (25 * scale),
    self.hand.y - (self.hand.height / 2) + (self.scrolls.height / 2) - (2 * scale))
  self.scrolls:render ()

  self.moves:locate (
    self.scrolls.x - self.moves.width - (10 * scale),
    self.scrolls.y)
  self.moves:render ()

  self.clicks:locate (
    self.moves.x - self.clicks.width - (10 * scale),
    self.moves.y)
  self.clicks:render ()

  x1 = self.clicks.x - (15 * scale)
  y1 = self.clicks.y - (2 * scale)

  x2 = x1
  y2 = y1 - self.clicks.height + (4 * scale)

  self.canvas:draw_line (x1, y1, x2, y2, 1 * scale, self.style.dim)

  self.strokes:locate (
    self.clicks.x - self.strokes.width - (30 * scale),
    self.clicks.y)
  self.strokes:render ()

  self.canvas:restore_transform ()
end

return Actions