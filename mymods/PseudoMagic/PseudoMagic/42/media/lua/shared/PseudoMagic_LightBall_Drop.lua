-- Dropping a Magic Light Ball on the ground places a light there (same approach as
-- PseudoButterCandle_Shared). Chains the original action so other mods keep working.
require "TimedActions/ISDropWorldItemAction"
require "PseudoMagic_LightBall_Utils"

local Utils = PseudoMagicLight
local OriginalDropItemComplete = ISDropWorldItemAction.complete

ISDropWorldItemAction.complete = function(self)
    OriginalDropItemComplete(self)

    if not Utils.isLightBall(self.item) then return true end

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
        sendServerCommand(Utils.commandModule, "light", data)
    elseif not isClient() then
        Utils.tryAddLightToWorld(itemId, data.x, data.y, data.z, data.chunkId, data.lightDistance)
    else
        Utils.sendLightCommand(self.item, square, self.character)
    end

    return true
end
