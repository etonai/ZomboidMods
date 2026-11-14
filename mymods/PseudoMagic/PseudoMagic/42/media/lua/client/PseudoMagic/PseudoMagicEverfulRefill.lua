-- PseudoMagic: keeps Everful items full of water (DevCycle 11).
-- Every ten in-game minutes, and when the game starts, every Everful Waterskin and Everful
-- Bucket the player carries (including inside bags) is topped up with water. An item that
-- holds another fluid is left alone; it refills as soon as it is empty. Vanilla waterskins
-- and buckets are never touched. Items on the ground or in world containers are not scanned.
-- Single player only.

if isClient() then return end

-- Item type (without module) -> full type, for every item this file refills.
local EVERFUL_ITEMS = {
    EverfulWaterskin = "PseudoMagic.EverfulWaterskin",
    EverfulBucket    = "PseudoMagic.EverfulBucket",
}

local function topUp(item)
    local fc = item:getFluidContainer()
    if not fc or fc:isFull() then return end
    local water = Fluid.Water
    if not water then return end
    if fc:isEmpty() or fc:isPureFluid(water) then
        fc:addFluid(water, fc:getFreeCapacity())
    end
end

local function refillAll(playerObj)
    if not playerObj then return end
    local inventory = playerObj:getInventory()
    for typeName, fullType in pairs(EVERFUL_ITEMS) do
        local found = inventory:getAllTypeRecurse(typeName)
        for i = 0, found:size() - 1 do
            local item = found:get(i)
            if item:getFullType() == fullType then
                topUp(item)
            end
        end
    end
end

local function onEveryTenMinutes()
    refillAll(getPlayer())
end

local function onGameStart()
    refillAll(getPlayer())
end

Events.EveryTenMinutes.Add(onEveryTenMinutes)
Events.OnGameStart.Add(onGameStart)
