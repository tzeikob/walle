-- A component for timing values drawn as a horizontal bar

local Ticker = {
  canvas = nil,
  style = {
    padding = 2,
    skew = 0.06,
    color = { 1, 0.8, 0, 0.8 },
    dim = { 1, 1, 1, 0.2 }
  }
}

function Ticker:new (canvas, value, max, splits, width, height)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.value = value
  o.max = max
  o.splits = splits

  o.x = 0
  o.y = 0

  o.width = width * o.canvas.scale
  o.height = height * o.canvas.scale

  return o
end

function Ticker:locate (x, y)
  self.x = x
  self.y = y
end

function Ticker:render ()
  local scale = self.canvas.scale

  local padding = self.style.padding * scale
  local skew = self.style.skew

  local shared_width = self.width - ((self.splits - 1) * padding)
  local share = shared_width / self.splits

  local rate = self.value / (self.max - 1)
  local current = math.floor (rate * self.splits)

  local color = self.style.color

  if current < 1 then
    color = self.style.dim
  end

  local x = self.x
  local y = self.y

  self.canvas:draw_trapezoid (x, y, share, self.height, share * skew, -1, -1, color)

  for i = 2, self.splits - 1, 1 do
    color = self.style.color

    if current < i then
      color = self.style.dim
    end

    x = x + share + padding

    self.canvas:draw_rectangle (x, y, share, self.height, color)
  end

  color = self.style.color

  if current < self.splits then
    color = self.style.dim
  end

  x = x + share + padding

  self.canvas:draw_trapezoid (x, y, share, self.height, share * skew, -1, 1, color)
end

return Ticker