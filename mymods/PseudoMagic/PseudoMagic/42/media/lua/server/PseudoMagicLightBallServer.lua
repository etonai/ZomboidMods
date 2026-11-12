-- Server (and single-player) side of the Magic Light Ball: tracks balls lying on the ground,
-- burns them down once per game minute, and removes the item and its light when empty.
require "PseudoMagic_LightBall_Utils"

local Utils = PseudoMagicLight
local isSinglePlayer = not isClient() and not isServer()

local function removeLight(id, data)
    if isSinglePlayer then
        Utils.tryRemoveLightFromWorld(id)
    else
        sendServerCommand(Utils.commandModule, "extinguish", data or { itemId = id })
    end
end

local function onClientCommand(module, command, playerObj, args)
    if module ~= Utils.commandModule then return end

    local modData = ModData.getOrCreate(Utils.modKey)

    if command == "light" and args then
        local square = getCell():getGridSquare(args.x, args.y, args.z)
        local item = Utils.getItemByID(args.itemId, square)
        if not item or not Utils.isLightBall(item) then return end

        args.lightDistance = item:getLightDistance()
        args.chunkId = args.chunkId or Utils.getChunkIDFromCoords(args.x, args.y)
        modData[args.itemId] = args

        if isSinglePlayer then
            Utils.tryAddLightToWorld(args.itemId, args.x, args.y, args.z, args.chunkId, args.lightDistance)
        else
            sendServerCommand(Utils.commandModule, "light", args)
        end
    elseif command == "extinguish" and args then
        modData[args.itemId] = nil
        removeLight(args.itemId, args)
    elseif command == "load" then
        for id, data in pairs(modData) do
            if data then
                if isSinglePlayer then
                    Utils.tryAddLightToWorld(id, data.x, data.y, data.z, data.chunkId, data.lightDistance)
                else
                    sendServerCommand(playerObj, Utils.commandModule, "light", data)
                end
            end
        end
    end
end
Events.OnClientCommand.Add(onClientCommand)

-- Burn down balls on the ground. The carried drain is done by the engine (UseWhileUnequipped);
-- ground items are drained here at the same rate: Utils.usesPerMinute uses per game minute.
local function everyOneMinute()
    local modData = ModData.getOrCreate(Utils.modKey)

    for id, data in pairs(modData) do
        local square = data and getCell():getGridSquare(data.x, data.y, data.z)

        if square then
            local item = Utils.getItemByID(id, square)

            if not item or not Utils.isLightBall(item) then
                modData[id] = nil
                removeLight(id)
            else
                local uses = item:getCurrentUsesFloat() - (item:getUseDelta() * Utils.usesPerMinute)
                item:setCurrentUsesFloat(uses)

                if isServer() then
                    item:syncItemFields()
                end

                if uses <= 0.0001 then
                    modData[id] = nil
                    removeLight(id, data)
                    Utils.removeWorldItem(item, square)
                end
            end
        end
    end
end

if isServer() or isSinglePlayer then
    Events.EveryOneMinute.Add(everyOneMinute)
end
