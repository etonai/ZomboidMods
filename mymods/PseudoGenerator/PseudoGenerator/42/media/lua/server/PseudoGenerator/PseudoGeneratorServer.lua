-- PseudoGenerator: tracking and maintenance of Naquadah Generators.
-- Single player only (DevCycle 001). Runs in the server/single-player Lua state.
--
-- The engine's list of generators (IsoGenerator.AllGenerators) is private, so the mod
-- keeps its own registry of Naquadah Generator locations in global ModData.
-- Maintenance = set fuel and condition to full. It never switches a generator on
-- (a manual shutdown is respected) and never plugs it in.

if isClient() then return end

require "TimedActions/ISDropWorldItemAction"
require "TimedActions/ISTakeGenerator"
require "PseudoGenerator/PseudoGenerator"

local PG = PseudoGenerator

local MODDATA_NAME = "PseudoGenerator"
local CHUNK_SIZE = 8 -- tiles per chunk side

------------------------------------------------------------------------
-- Registry (global ModData: PseudoGenerator.gens["x,y,z"] = {x, y, z, hour})
------------------------------------------------------------------------

local function registry()
    local data = ModData.getOrCreate(MODDATA_NAME)
    data.gens = data.gens or {}
    return data.gens
end

local function keyOf(x, y, z)
    return x .. "," .. y .. "," .. z
end

local function worldHours()
    return GameTime.getInstance():getWorldAgeHours()
end

function PG.register(square)
    if not square then return end
    local generator = square:getGenerator()
    if not PG.isNaquadah(generator) then return end
    local x, y, z = square:getX(), square:getY(), square:getZ()
    registry()[keyOf(x, y, z)] = { x = x, y = y, z = z, hour = worldHours() }
    -- A newly placed generator starts empty; fill it now rather than at the next ten-minute pass.
    generator:setCondition(PG.MAX_CONDITION)
    generator:setFuel(PG.MAX_FUEL)
end

function PG.unregister(square)
    if not square then return end
    registry()[keyOf(square:getX(), square:getY(), square:getZ())] = nil
end

------------------------------------------------------------------------
-- Maintenance
------------------------------------------------------------------------

-- Refill one generator. entry.hour is the world age (in hours) when this generator was
-- last maintained. IsoGenerator charges fuel and condition for every in-game hour since
-- its own internal lastHour on its first update after loading, so a long absence could
-- drain it in one step. If at least an hour passed unobserved, switch a running
-- generator off and on to reset the engine's counter (IsoGenerator.setActivated(true)
-- sets lastHour to now). A generator that is off stays off.
local function maintain(entry, generator)
    if generator:getCondition() < PG.MAX_CONDITION then
        generator:setCondition(PG.MAX_CONDITION)
    end
    if generator:getFuel() < PG.MAX_FUEL then
        generator:setFuel(PG.MAX_FUEL)
    end

    if generator:isActivated() and entry.hour and (worldHours() - entry.hour) >= 1 then
        generator:setActivated(false)
        generator:setActivated(true)
    end
    entry.hour = worldHours()
end

-- Handle one registry entry. square may be nil (not loaded). When removeIfMissing is
-- true an entry whose square is loaded but no longer holds a Naquadah Generator is dropped.
local function processEntry(key, entry, square, removeIfMissing)
    if not square then return end
    local generator = square:getGenerator()
    if PG.isNaquadah(generator) then
        maintain(entry, generator)
    elseif removeIfMissing then
        registry()[key] = nil
    end
end

-- Every ten in-game minutes: maintain every tracked generator whose square is loaded.
local function onEveryTenMinutes()
    local cell = getCell()
    if not cell then return end
    for key, entry in pairs(registry()) do
        processEntry(key, entry, cell:getGridSquare(entry.x, entry.y, entry.z), true)
    end
end

-- When a chunk loads: maintain tracked generators inside it right away, before the
-- engine's first update of those generators.
local function onLoadChunk(chunk)
    -- IsoChunk.wx/wy are not readable from Lua, so ask the chunk for the square at the
    -- entry's local coordinates and accept it only if it really is at the entry's position
    -- (a chunk that does not contain the entry returns nil or a different square).
    for key, entry in pairs(registry()) do
        local square = chunk:getGridSquare(entry.x % CHUNK_SIZE, entry.y % CHUNK_SIZE, entry.z)
        if square and square:getX() == entry.x and square:getY() == entry.y then
            processEntry(key, entry, square, false)
        end
    end
end

-- Fallback discovery: a generator item can reach the ground by several routes
-- (ISDropWorldItemAction, ISUnequipAction, forceDropHeavyItems, ...) and all of them end
-- in the Java method IsoGridSquare.AddWorldInventoryItem, which cannot be hooked from
-- Lua. So once a minute, look for untracked Naquadah Generators near the player.
local SCAN_RADIUS = 12

local function onEveryOneMinute()
    local player = getPlayer()
    if not player then return end
    local cell = getCell()
    if not cell then return end
    local px, py, pz = math.floor(player:getX()), math.floor(player:getY()), math.floor(player:getZ())
    local gens = registry()
    for x = px - SCAN_RADIUS, px + SCAN_RADIUS do
        for y = py - SCAN_RADIUS, py + SCAN_RADIUS do
            local square = cell:getGridSquare(x, y, pz)
            if square and not gens[keyOf(x, y, pz)] then
                local generator = square:getGenerator()
                if generator and PG.isNaquadah(generator) then
                    PG.register(square)
                end
            end
        end
    end
end

Events.EveryOneMinute.Add(onEveryOneMinute)
Events.EveryTenMinutes.Add(onEveryTenMinutes)
Events.LoadChunk.Add(onLoadChunk)

------------------------------------------------------------------------
-- Vanilla map-object handler override
------------------------------------------------------------------------

-- Vanilla (Map/MapObjects/MOGenerator.lua) registers a "new map object" handler for
-- sprite appliances_misc_01_13 that replaces the object with a Base.Generator_Blue at
-- zero fuel. Our item borrows that sprite, so that handler would turn a Naquadah
-- Generator into a vanilla one. MapObjects.OnNewWithSprite replaces the function already
-- registered at the same priority (vanilla uses 5), so register ours at 5 as well.
-- An existing IsoGenerator is left alone; a plain map object with this sprite is still
-- converted to a Blue Generator as in vanilla.
require "Map/MapObjects/MOGenerator"

local function onNewSprite13(object)
    if instanceof(object, "IsoGenerator") then
        return
    end
    local square = object:getSquare()
    local item = instanceItem("Base.Generator_Blue")
    if not square or not item then return end
    item:setCondition(100)
    item:getModData().fuel = 0
    square:transmitRemoveItemFromSquare(object)
    local generator = IsoGenerator.new(item, getWorld():getCell(), square)
    generator:transmitCompleteItemToClients()
end

MapObjects.OnNewWithSprite("appliances_misc_01_13", onNewSprite13, 5)

------------------------------------------------------------------------
-- Placement and pick-up
------------------------------------------------------------------------

-- Placing: a generator item dropped on a square becomes an IsoGenerator
-- (IsoGridSquare.AddWorldInventoryItem). Register it once the drop has completed.
local originalDropComplete = ISDropWorldItemAction.complete
function ISDropWorldItemAction:complete()
    local result = originalDropComplete(self)
    if self.item and self.sq and self.item:getFullType() == PG.ITEM_TYPE then
        PG.register(self.sq)
    end
    return result
end

-- Picking up: forget the location (the check must run before the generator is removed).
local originalTakeComplete = ISTakeGenerator.complete
function ISTakeGenerator:complete()
    local wasNaquadah = PG.isNaquadah(self.generator)
    local square = self.generator and self.generator:getSquare()
    local result = originalTakeComplete(self)
    if wasNaquadah then
        PG.unregister(square)
    end
    return result
end
