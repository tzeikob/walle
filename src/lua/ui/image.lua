-- A component to render a PNG image file

local Image = {
  canvas = nil
}

function Image:new (canvas, file_path, size)
  local o = setmetatable ({}, self)
  self.__index = self

  o.canvas = canvas
  o.file_path = file_path
  o.size = size * o.canvas.scale

  o.x = 0
  o.y = 0

  o.width = o.size
  o.height = o.size

  o.glob = o.canvas:create_image (o.file_path)
  o.downscale = o.size / o.glob.width

  return o
end

function Image:locate (x, y)
  self.x = x
  self.y = y
end

function Image:render ()
  -- Fix top-left coordinates before scaling
  local dx = (1 - self.downscale) * self.x
  local dy = (1 - self.downscale) * self.y - self.size

  self.canvas:apply_transform (self.downscale, 0, 0, self.downscale, dx, dy)

  self.canvas:paint_image (self.x, self.y, self.glob.image)

  self.canvas:restore_transform ()
end

return Image