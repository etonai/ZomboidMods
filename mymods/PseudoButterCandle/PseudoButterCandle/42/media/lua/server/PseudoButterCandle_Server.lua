require "PseudoButterCandle_Utils"

PseudoButterCandle = PseudoButterCandle or {}

local Utils = PseudoButterCandle.Utils
local isSinglePlayer = not isClient() and not isServer()

function PseudoButterCandle.onClientCommand(module, command, playerObj, args)
  if module ~= "PseudoButterCandle" then return end

  local modData = ModData.getOrCreate(Utils.modKey)

  if command == "light" and args then
    local square = getCell():getGridSquare(args.x, args.y, args.z)
    local item = Utils.getItemByID(args.itemId, square)
    if not item or not Utils.isLitButterCandle(item) then return end

    args.lightDistance = item:getLightDistance()
    args.chunkId = args.chunkId or Utils.getChunkIDFromCoords(args.x, args.y)
    modData[args.itemId] = args

    if isSinglePlayer then
      Utils.tryAddLightToWorld(args.itemId, args.x, args.y, args.z, args.chunkId, args.lightDistance)
    else
      sendServerCommand("PseudoButterCandle", "light", args)
    end
  elseif command == "extinguish" and args then
    if modData[args.itemId] then
      modData[args.itemId] = nil
    end

    if isSinglePlayer then
      Utils.tryRemoveLightFromWorld(args.itemId)
    else
      sendServerCommand("PseudoButterCandle", "extinguish", args)
    end
  elseif command == "load" then
    for id, data in pairs(modData) do
      if data then
        if isSinglePlayer then
          Utils.tryAddLightToWorld(id, data.x, data.y, data.z, data.chunkId, data.lightDistance)
        else
          sendServerCommand(playerObj, "PseudoButterCandle", "light", data)
        end
      end
    end
  end
end

Events.OnClientCommand.Add(PseudoButterCandle.onClientCommand)

function PseudoButterCandle.everyTenMinutes()
  local modData = ModData.getOrCreate(Utils.modKey)

  for id, data in pairs(modData) do
    local square = data and getCell():getGridSquare(data.x, data.y, data.z)

    if square then
      local item = Utils.getItemByID(id, square)

      if not item or not Utils.isLitButterCandle(item) then
        modData[id] = nil
        if isSinglePlayer then
          Utils.tryRemoveLightFromWorld(id)
        else
          sendServerCommand("PseudoButterCandle", "extinguish", { itemId = id })
        end
      else
        local uses = item:getCurrentUsesFloat() - (item:getUseDelta() * 100)
        item:setCurrentUsesFloat(uses)

        if isServer() then
          item:syncItemFields()
        end

        if uses <= 0 then
          modData[id] = nil

          if isSinglePlayer then
            Utils.tryRemoveLightFromWorld(id)
          else
            sendServerCommand("PseudoButterCandle", "extinguish", data)
          end

          Utils.removeWorldItem(item, square)
        end
      end
    end
  end
end

if isServer() or isSinglePlayer then
  Events.EveryTenMinutes.Add(PseudoButterCandle.everyTenMinutes)
end