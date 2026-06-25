require "TimedActions/ISInventoryTransferAction"
require "PseudoButterCandle_Utils"

PseudoButterCandle = PseudoButterCandle or {}

local Utils = PseudoButterCandle.Utils
local OriginalTransferActionPerform = ISInventoryTransferAction.perform

ISInventoryTransferAction.perform = function(self)
  if Utils.isLitButterCandle(self.item) then
    if self.srcContainer and self.srcContainer:getType() == "floor" then
      Utils.sendExtinguishCommand(self.item, self.character)
    elseif self.destContainer and self.destContainer:getType() == "floor" then
      Utils.sendLightCommand(self.item, self.character:getCurrentSquare(), self.character)
    end
  end

  OriginalTransferActionPerform(self)
end

function PseudoButterCandle.onServerCommand(module, command, args)
  if module ~= "PseudoButterCandle" then return end
  if not args then return end

  if command == "light" then
    Utils.tryAddLightToWorld(args.itemId, args.x, args.y, args.z, args.chunkId, args.lightDistance)
  elseif command == "extinguish" then
    Utils.tryRemoveLightFromWorld(args.itemId)
  end
end

Events.OnServerCommand.Add(PseudoButterCandle.onServerCommand)

local delayedTimer = nil
local currentPlayer = nil

function PseudoButterCandle.sendLoadCommandDelayed()
  delayedTimer = delayedTimer - 1
  if delayedTimer > 0 then return end

  Events.OnPlayerUpdate.Remove(PseudoButterCandle.sendLoadCommandDelayed)
  sendClientCommand(currentPlayer, "PseudoButterCandle", "load", nil)
end

function PseudoButterCandle.onCreatePlayer(playerIndex, playerObj)
  currentPlayer = playerObj
  delayedTimer = 3
  Events.OnPlayerUpdate.Add(PseudoButterCandle.sendLoadCommandDelayed)
end

Events.OnCreatePlayer.Add(PseudoButterCandle.onCreatePlayer)
