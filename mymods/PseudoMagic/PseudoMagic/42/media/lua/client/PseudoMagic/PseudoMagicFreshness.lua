-- PseudoMagic: Crate of Freshness (DevCycle 11).
-- A regular Metal Crate (Metal_Crate_Lvl1, four facing sprites) can be enchanted from its right-click menu by a
-- survivor carrying a Ring of the Mage. An enchanted crate keeps every Food item inside it
-- (including food in bags in the crate) at age 0: every ten in-game minutes, and when the
-- crate's area loads. Single player only.
--
-- Why an enchantment and not a new crate: the engine allows exactly one entity script per
-- sprite ("Sprite ... is duplicate", SpriteConfigManager), so a separate crate cannot reuse
-- the vanilla crate's sprites, and a new container sprite would need a custom tilesheet.
--
-- Enchanted crates are recorded in global ModData (PseudoMagicFreshness.crates, keyed
-- "x,y,z") and flagged with modData PseudoMagicFreshness on the object itself.

if isClient() then return end

-- Metal_Crate_Lvl1 (entity_welding_crate_lvl1.txt): one sprite per facing. The Fancy Metal Crate
-- (crafted_05_44) is deliberately not included.
local CRATE_SPRITES = {
    ["constructedobjects_01_44"] = true,
    ["constructedobjects_01_45"] = true,
    ["constructedobjects_01_46"] = true,
    ["constructedobjects_01_47"] = true,
}
local FLAG = "PseudoMagicFreshness"
local MODDATA_NAME = "PseudoMagicFreshness"
local CHUNK_SIZE = 8 -- tiles per chunk side

local RING_TYPES = {
    ["PseudoMagic.RingOfTheMageRightMiddleFinger"] = true,
    ["PseudoMagic.RingOfTheMageLeftMiddleFinger"]  = true,
    ["PseudoMagic.RingOfTheMageRightRingFinger"]   = true,
    ["PseudoMagic.RingOfTheMageLeftRingFinger"]    = true,
}

------------------------------------------------------------------------
-- Registry
------------------------------------------------------------------------

local function registry()
    local data = ModData.getOrCreate(MODDATA_NAME)
    data.crates = data.crates or {}
    return data.crates
end

local function keyOf(x, y, z)
    return x .. "," .. y .. "," .. z
end

local function isCrateSprite(obj)
    if not obj or not obj.getSprite then return false end
    local sprite = obj:getSprite()
    return sprite ~= nil and CRATE_SPRITES[sprite:getName()] == true
end

local function isEnchanted(obj)
    return obj:getModData()[FLAG] == true
end

-- The regular Metal Crate on a square, or nil.
local function crateOn(square)
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if isCrateSprite(obj) and obj:getContainer() then
            return obj
        end
    end
    return nil
end

------------------------------------------------------------------------
-- Freshening
------------------------------------------------------------------------

local function freshenContainer(container, now)
    local items = container:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if instanceof(item, "Food") then
            if item:getAge() > 0 then
                item:setAge(0)
            end
            -- Food ages by (world age - lastAged) on its first update after loading, so move
            -- the marker to now as well; otherwise a long absence would age it again.
            item:setLastAged(now)
        elseif item:IsInventoryContainer() then
            freshenContainer(item:getInventory(), now)
        end
    end
end

local function freshenCrate(obj)
    local container = obj:getContainer()
    if container then
        freshenContainer(container, GameTime.getInstance():getWorldAgeHours())
    end
end

-- Handle one registry entry. square may be nil (not loaded). A loaded square that no longer
-- holds an enchanted crate (picked up, destroyed) drops its entry.
local function processEntry(key, entry, square, removeIfMissing)
    if not square then return end
    local obj = crateOn(square)
    if obj and isEnchanted(obj) then
        freshenCrate(obj)
    elseif removeIfMissing then
        registry()[key] = nil
    end
end

local function onEveryTenMinutes()
    local cell = getCell()
    if not cell then return end
    for key, entry in pairs(registry()) do
        processEntry(key, entry, cell:getGridSquare(entry.x, entry.y, entry.z), true)
    end
end

-- When a chunk loads: freshen tracked crates inside it right away, before the food's first
-- update. Ask the chunk for the square at the entry's local coordinates and accept it only
-- if it really is at the entry's position (as PseudoGenerator does).
local function onLoadChunk(chunk)
    for key, entry in pairs(registry()) do
        local square = chunk:getGridSquare(entry.x % CHUNK_SIZE, entry.y % CHUNK_SIZE, entry.z)
        if square and square:getX() == entry.x and square:getY() == entry.y then
            processEntry(key, entry, square, false)
        end
    end
end

Events.EveryTenMinutes.Add(onEveryTenMinutes)
Events.LoadChunk.Add(onLoadChunk)

------------------------------------------------------------------------
-- Enchanting (world context menu)
------------------------------------------------------------------------

local function hasRing(playerObj)
    local starters = playerObj:getInventory():getAllTagRecurse(ItemTag.START_FIRE, ArrayList.new())
    for i = 0, starters:size() - 1 do
        if RING_TYPES[starters:get(i):getFullType()] then
            return true
        end
    end
    return false
end

local function enchant(playerObj, obj)
    local square = obj:getSquare()
    if not square then return end
    obj:getModData()[FLAG] = true
    local x, y, z = square:getX(), square:getY(), square:getZ()
    registry()[keyOf(x, y, z)] = { x = x, y = y, z = z }
    freshenCrate(obj)
    playerObj:setHaloNote(getText("UI_PseudoMagic_FreshnessEnchanted"))
end

local function disenchant(playerObj, obj)
    local square = obj:getSquare()
    obj:getModData()[FLAG] = nil
    if square then
        registry()[keyOf(square:getX(), square:getY(), square:getZ())] = nil
    end
    playerObj:setHaloNote(getText("UI_PseudoMagic_FreshnessRemoved"))
end

local function onFillWorldObjectContextMenu(playerNum, context, worldobjects, test)
    if test then return end
    local playerObj = getSpecificPlayer(playerNum)
    if not playerObj or not hasRing(playerObj) then return end
    for _, obj in ipairs(worldobjects) do
        if isCrateSprite(obj) and obj:getContainer() then
            if isEnchanted(obj) then
                context:addOption(getText("UI_PseudoMagic_RemoveFreshness"), playerObj, disenchant, obj)
            else
                context:addOption(getText("UI_PseudoMagic_EnchantFreshness"), playerObj, enchant, obj)
            end
            return
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
