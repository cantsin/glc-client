local Sprite = require('graphics/sprites/sprite')

local killVerbs = {"killed", "murdered", "smashed", "exploded", "dispatched", "neutralized", "X'd"}

-- sets the location of the bullet
local function bulletLocation(direction, X, Y)
  local shootOffset = -4
  direction = direction or "right"
  local getOffset = {
      left  = { X = X + shootOffset , Y = Y }
    , up    = { X = X               , Y = Y + shootOffset }
    , down  = { X = X               , Y = Y - shootOffset }
    , right = { X = X - shootOffset , Y = Y }
  }

  return getOffset[direction]
end

local function drawBullet(x, y)
  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.circle("fill", 0, 0, 2, 10)
  love.graphics.pop()
end

-- fireBullet is triggered by pressing the spacebar and returns a message
-- containing all the important bulletData.
local function fireBullet(playerData)

  inspect = require('util/inspect')
  print(inspect(playerData))

  local location = bulletLocation(playerData.player.direction,
                                  playerData.player.X,
                                  playerData.player.Y)
  -- calculate currZoneId only once and pass it into playerData
  -- we don't use the second variable
  local currZoneId, currZone = getZoneOffset(location.X, location.Y)
  return { spriteType = "Bullet"
  , name = playerData.player.name
  , direction = playerData.player.direction
  , X = location.X
  , Y = location.Y
  , hitList = {[""] = true} -- json.lua is fubar! To hell with it. It'll crash if I leave an empty table {} here.
  , damage = 1
  --, startTime = love.timer.getTime() -- should not be in here
  , zoneid = currZoneId
  , speed = playerData.speed
  , width = 4
  , height = 4
  }
end

Bullet = Sprite.inherit{spriteType = "Bullet"}
Bullet.__index = Bullet
Bullet.fireBullet = fireBullet

function Bullet:updateState(data)
  self.speed = data.speed or self.speed
end

function Bullet:update()

  -- for now
  local delta = 0.4

  local setBulletNewLocation = {
      right = function()
        self.x = self.x + delta * self.speed
      end
    , left = function()
        self.x = self.x - delta * self.speed
      end
    , down = function()
        self.y = self.y + delta * self.speed
      end
    , up = function()
        self.y = self.y - delta * self.speed
      end
  }

  -- bullets are forever extant. rarrrgh!

  -- if bullet hasn't hit an obstacle after two seconds, remove bullet.
  -- if time > bullet.startTime + 2 then
  --   bullet.remove = true
  -- else
  setBulletNewLocation[self.direction]()
  -- end
end

function Bullet:draw()
  layers.background:draw(drawBullet, {self.x, self.y})
end

function Bullet.new(obj)
  bulletData = {
    x = obj.X,
    y = obj.Y,
    width = obj.width,
    height = obj.width,
    direction = obj.direction,
    zoneid = obj.zoneid
  }

  self = Bullet.__base.new(bulletData)
  setmetatable(self, Bullet)
  self:updateState(obj)
  return self
end

return Bullet
