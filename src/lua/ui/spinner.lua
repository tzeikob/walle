-- A component for metric values drawn as a rollable spinner

local Text = require "text"

local Spinner = {
  canvas = nil,
  style = {
    face = "Walle Digits",
    padding = 50,
    radius = 2,
    places = 4,
    downscale = 0.75,
    format = "%02d",
    color = { 1, 1, 1, 0.8 },
    dot = { 1, 1, 1, 0.3 }
  }
}

function Spinner:new (canvas, value, max, size)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value
  o.max = max

  o.extents = {}

  local places = o.style.places
  local color = o.style.color

  local step = color[4] / (places + 1)
  local volume = step

  for i = o.value - places, o.value - 1, 1 do
    local num = i

    if i < 0 then
      num = o.max + i
    end

    local item = Text:new (
      o.canvas,
      string.format (o.style.format, num),
      o.style.face,
      size * o.style.downscale,
      false,
      false,
      { color[1], color[2], color[3], volume })

    table.insert (o.extents, item)

    volume = volume + step
  end

  volume = color[4] - step

  for i = o.value + 1, o.value + places, 1 do
    local num = i

    if i >= o.max then
      num = math.fmod (i, o.max)
    end

    local item = Text:new (
      o.canvas,
      string.format (o.style.format, num),
      o.style.face,
      size * o.style.downscale,
      false,
      false,
      { color[1], color[2], color[3], volume })

    table.insert (o.extents, item)

    volume = volume - step
  end

  o.facade = Text:new (
    o.canvas,
    string.format (o.style.format, o.value),
    o.style.face,
    size,
    false,
    false,
    o.style.color)

  o.x = 0
  o.y = 0

  o.width = o.facade.width

  for i = 1, table.getn (o.extents), 1 do
    o.width = o.width + o.extents[i].width + (o.style.padding * o.canvas.scale)
  end

  o.height = o.facade.height

  return o
end

function Spinner:locate (x, y)
  self.x = x
  self.y = y
end

function Spinner:render ()
  local scale = self.canvas.scale

  local padding = self.style.padding * scale
  local radius = self.style.radius * scale
  local places = self.style.places

  local x = self.x

  for i = 1, places, 1 do
    local y = self.y - (self.height / 2) + (self.extents[i].height / 2)

    self.extents[i]:locate (x, y)
    self.extents[i]:render ()

    x = x + self.extents[i].width + (padding / 2)
    y = y - (self.extents[i].height / 2)

    self.canvas:draw_dot (x, y, radius, self.style.dot)

    x = x + (padding / 2)
  end

  self.facade:locate (x, self.y)
  self.facade:render ()

  x = x + self.facade.width + (padding / 2)

  for i = places + 1, table.getn (self.extents), 1 do
    local y = self.y - (self.height / 2)

    self.canvas:draw_dot (x, y, radius, self.style.dot)

    x = x + (padding / 2)
    y = y + (self.extents[i].height / 2)

    self.extents[i]:locate (x, y)
    self.extents[i]:render ()

    x = x + self.extents[i].width + (padding / 2)
  end

end

return Spinner