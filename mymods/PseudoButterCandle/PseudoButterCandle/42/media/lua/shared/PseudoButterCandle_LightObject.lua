require "ISBaseObject"

PseudoButterCandle_LightObject = ISBaseObject:derive("PseudoButterCandle_LightObject")

function PseudoButterCandle_LightObject:new(x, y, z, radius)
  local o = ISBaseObject:new()
  setmetatable(o, self)
  self.__index = self

  o.x = x
  o.y = y
  o.z = z
  o.radius = radius or 5

  return o
end

function PseudoButterCandle_LightObject:spawnLight()
  if self.light then
    getCell():addLamppost(self.light)
    return
  end

  self.light = IsoLightSource.new(self.x, self.y, self.z, 0.8, 0.66, 0.45, self.radius)
  getCell():addLamppost(self.light)
end

function PseudoButterCandle_LightObject:destroy()
  if isServer() then return end
  if self.light then
    getCell():removeLamppost(self.light)
    self.light = nil
  end
end
