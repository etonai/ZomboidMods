require "TimedActions/ISDropWorldItemAction"
require "PseudoButterCandle_Utils"

PseudoButterCandle = PseudoButterCandle or {}

local Utils = PseudoButterCandle.Utils
local OriginalDropItemComplete = ISDropWorldItemAction.complete

ISDropWorldItemAction.complete = function(self)
  OriginalDropItemComplete(self)

  if not Utils.isLitButterCandle(self.item) then return true end

  local modData = ModData.getOrCreate(Utils.modKey)
  local itemId = self.item:getID()
  local square = self.sq
  local data = {
    itemId = itemId,
    chunkId = Utils.getChunkIDFromCoords(square:getX(), square:getY()),
    x = square:getX(),
    y = square:getY(),
    z = square:getZ(),
    lightDistance = self.item:getLightDistance(),
  }

  modData[itemId] = data

  if isServer() then
    sendServerCommand("PseudoButterCandle", "light", data)
  elseif not isClient() then
    Utils.tryAddLightToWorld(itemId, data.x, data.y, data.z, data.chunkId, data.lightDistance)
  else
    Utils.sendLightCommand(self.item, square, self.character)
  end

  return true
end
