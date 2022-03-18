-- A ui component to render metrics for the user input skills

local convert = require "convert"
local Glyph = require "glyph"
local Metric = require "metric"
local BoxScalar = require "box-scalar"

local Skills = {
  canvas = nil,
  data = nil,
  score = nil,
  hand = nil,
  tags = nil,
  scrolls = nil,
  moves = nil,
  clicks = nil,
  strokes = nil,
  x = 0,
  y = 0
}

function Skills:new (canvas, data)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.data = data

  o.score = Metric:new (o.canvas, data.total, nil, 32 * o.canvas.scale, { 1, 1, 1, 0.8 }, "%06d")
  o.hand = Glyph:new (o.canvas, Glyph.Hand, 48 * o.canvas.scale, { 1, 1, 1, 0.8 })

  o.tags = {
    Glyph:new (o.canvas, Glyph.Infinity, 36 * o.canvas.scale, { 1, 1, 1, 0.4 })
  }

  local scalar = convert.round (data.scrolls_rate, 1) * 10
  o.scrolls = BoxScalar:new (o.canvas, scalar, Glyph.Scroll, 48 * o.canvas.scale)

  scalar = convert.round (data.moves_rate, 1) * 10
  o.moves = BoxScalar:new (o.canvas, scalar, Glyph.Move, 48 * o.canvas.scale)

  scalar = convert.round (data.clicks_rate, 1) * 10
  o.clicks = BoxScalar:new (o.canvas, scalar, Glyph.Click, 48 * o.canvas.scale)

  scalar = convert.round (data.strokes_rate, 1) * 10
  o.strokes = BoxScalar:new (o.canvas, scalar, Glyph.Stroke, 48 * o.canvas.scale)

  o.x = 0
  o.y = 0

  return o
end

function Skills:locate (x, y)
  self.x = x
  self.y = y
end

function Skills:render ()
  local scale = self.canvas.scale

  self.canvas:apply_transform (1.0, 0.1, -0.2, 1.0, 0.2 * self.y, -0.1 * self.x)

  self.hand:locate (self.x - self.hand.width, self.y)
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

  self.canvas:draw_line (x1, y1, x2, y2, 1 * scale, { 1, 1, 1, 0.4 } )

  y1 = self.hand.y - self.hand.height - (6 * scale)
  y2 = y1

  self.canvas:draw_line (x1, y1, x2, y2, 1 * scale, { 1, 1, 1, 0.4 })

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

  self.canvas:draw_line (x1, y1, x2, y2, 1 * scale, { 1, 1, 1, 0.4 })

  self.strokes:locate (
    self.clicks.x - self.strokes.width - (30 * scale),
    self.clicks.y)
  self.strokes:render ()

  self.canvas:restore_transform ()
end

return Skills