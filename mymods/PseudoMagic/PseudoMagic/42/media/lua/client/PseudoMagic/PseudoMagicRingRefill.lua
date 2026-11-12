-- PseudoMagic: keeps the Ring of the Mage usable as a fire starter forever.
-- Fire-starting actions call Use() on the starter. The ring is a non-drainable clothing item
-- with 1 use, so KeepOnDeplete (set in the item script) stops it being deleted, but it would
-- sit at 0 uses and fail the "getCurrentUses() > 0" check in ISCampingMenu. This resets it to 1.

local RING_TYPES = {
    ["PseudoMagic.RingOfTheMageRightMiddleFinger"] = true,
    ["PseudoMagic.RingOfTheMageLeftMiddleFinger"]  = true,
    ["PseudoMagic.RingOfTheMageRightRingFinger"]   = true,
    ["PseudoMagic.RingOfTheMageLeftRingFinger"]    = true,
}

local CHECK_INTERVAL = 10 -- ticks between scans
local tick = 0

local function refillRings(playerObj)
    local starters = playerObj:getInventory():getAllTagRecurse(ItemTag.START_FIRE, ArrayList.new())
    for i = 0, starters:size() - 1 do
        local item = starters:get(i)
        if RING_TYPES[item:getFullType()] and item:getCurrentUses() < 1 then
            item:setCurrentUses(1)
        end
    end
end

local function onPlayerUpdate(playerObj)
    tick = tick + 1
    if tick < CHECK_INTERVAL then return end
    tick = 0
    refillRings(playerObj)
end

Events.OnPlayerUpdate.Add(onPlayerUpdate)
