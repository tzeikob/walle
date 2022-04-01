-- A component for timing values drawn as a horizontal bar

local Ticker = {
  canvas = nil,
  style = {
    padding = 2,
    theta = 1.4,
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
  local theta = self.style.theta

  local width = self.width - ((self.splits - 1) * padding)
  local share = width / self.splits

  local x = self.x
  local y = self.y

  for i = 1, self.splits, 1 do
    if i == 1 then
      self.canvas:draw_left_trapezoid (x, y, share, self.height, theta, 1, self.style.dim)
    elseif i == self.splits then
      self.canvas:draw_right_trapezoid (x, y, share, self.height, theta, 1, self.style.dim)
    elseif i > 1 and i < self.splits then
      self.canvas:draw_rectangle (x, y, share, self.height, self.style.dim)
    end

    x = x + share + padding
  end

  local rate = self.value / (self.max - 1)
  local filled = math.floor (rate * self.splits)

  x = self.x

  for i = 1, filled, 1 do
    if i == 1 then
      self.canvas:draw_left_trapezoid (x, y, share, self.height, theta, 1, self.style.color)
    elseif i == self.splits then
      self.canvas:draw_right_trapezoid (x, y, share, self.height, theta, 1, self.style.color)
    elseif i > 1 and i < self.splits then
      self.canvas:draw_rectangle (x, y, share, self.height, self.style.color)
    end

    x = x + share + padding
  end

  local split_size = self.max / self.splits
  local remain = self.value - (filled * split_size)
  local portion = remain / split_size

  if filled == 0 then
    self.canvas:draw_left_trapezoid (x, y, share, self.height, theta, portion, self.style.color)
  elseif filled == self.splits - 1 then
    self.canvas:draw_right_trapezoid (x, y, share, self.height, theta, portion, self.style.color)
  elseif filled > 0 and filled < self.splits then
    self.canvas:draw_rectangle (x, y, share * portion, self.height, self.style.color)
  end
end

return Ticker