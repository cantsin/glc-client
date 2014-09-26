
Layer = {}

-- TODO fix _.each bug
-- TODO fix oo bug (scale does not work, params are overriden)
-- TODO translation for overlay
-- TODO translation for world
-- TODO bug with drawable

-- TODO library/coords.lua

function Layer:new(width, height, x, y, r)
  setmetatable({}, self)
  self.__index = self

  self.width = width or win.width
  self.height = height or win.height
  self.x = x or 0
  self.y = y or 0
  self.r = r or 0
  self.sx = win.width / self.width
  self.sy = win.height / self.height
  self.drawable = false

  -- set up the canvas. we almost always want linear interpolation.
  self.canvas = love.graphics.newCanvas(self.width, self.height)
  self.canvas:setFilter("nearest", "nearest")

  return self
end

function Layer:set_drawable(drawable)
  self.drawable = drawable == true -- anything else is false-y
end

function Layer:clear()
  if self.drawable then
    self.canvas:clear(0, 0, 0, 0)
  end
end

function Layer:render()
  if self.drawable then
    love.graphics.draw(self.canvas, self.x, self.y, self.r, self.sx, self.sy)
  end
end

-- Given a canvas and a function that does graphical operations, make
-- sure the function operates only within the given canvas.
function Layer:draw(fn, args)
  if self.drawable then
    local closure = function()
      fn(unpack(args or {}))
    end
    self.canvas:renderTo(closure)
    -- reset all graphic attributes as to avoid side-effects
    love.graphics.reset()
  end
end

return Layer
