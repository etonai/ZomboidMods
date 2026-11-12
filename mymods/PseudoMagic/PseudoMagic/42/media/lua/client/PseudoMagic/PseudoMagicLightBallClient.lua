-- Client side of the Magic Light Ball: reacts to floor transfers, applies server commands,
-- and asks the server for the saved lights after joining.
require "TimedActions/ISInventoryTransferAction"
require "PseudoMagic_LightBall_Utils"

local Utils = PseudoMagicLight
local OriginalTransferActionPerform = ISInventoryTransferAction.perform

ISInventoryTransferAction.perform = function(self)
    if Utils.isLightBall(self.item) then
        if self.srcContainer and self.srcContainer:getType() == "floor" then
            Utils.sendRemoveCommand(self.item, self.character)
        elseif self.destContainer and self.destContainer:getType() == "floor" then
            Utils.sendLightCommand(self.item, self.character:getCurrentSquare(), self.character)
        end
    end
    OriginalTransferActionPerform(self)
end

local function onServerCommand(module, command, args)
    if module ~= Utils.commandModule or not args then return end
    if command == "light" then
        Utils.tryAddLightToWorld(args.itemId, args.x, args.y, args.z, args.chunkId, args.lightDistance)
    elseif command == "extinguish" then
        Utils.tryRemoveLightFromWorld(args.itemId)
    end
end
Events.OnServerCommand.Add(onServerCommand)

local delayedTimer = nil
local currentPlayer = nil

local function sendLoadCommandDelayed()
    delayedTimer = delayedTimer - 1
    if delayedTimer > 0 then return end
    Events.OnPlayerUpdate.Remove(sendLoadCommandDelayed)
    sendClientCommand(currentPlayer, Utils.commandModule, "load", nil)
end

local function onCreatePlayer(playerIndex, playerObj)
    currentPlayer = playerObj
    delayedTimer = 3
    Events.OnPlayerUpdate.Add(sendLoadCommandDelayed)
end
Events.OnCreatePlayer.Add(onCreatePlayer)
