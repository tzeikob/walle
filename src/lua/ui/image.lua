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

  return o
end

function Image:locate (x, y)
  self.x = x
  self.y = y
end

function Image:render ()
  local glob = self.canvas:create_image (self.file_path)
  local downscale = self.size / glob.width

  -- Fix top-left coordinates before scaling
  local dx = (1 - downscale) * self.x
  local dy = (1 - downscale) * self.y - self.size

  self.canvas:apply_transform (downscale, 0, 0, downscale, dx, dy)

  self.canvas:paint_image (self.x, self.y, glob.image)

  self.canvas:restore_transform ()
end

return Image