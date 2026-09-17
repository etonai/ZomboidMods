require "TimedActions/ISBaseTimedAction"

-- DC016 Phase 2: replacement-based conversion (idea #8, approach 2). Runs as a timed action
-- rather than directly inside the context-menu callback, matching vanilla's own
-- ISBuildIsoEntity.lua pattern for world-mutating object replacement (server/build-authoritative
-- code, not a bare client-side menu handler).
ISConvertWasherToChurningMachine = ISBaseTimedAction:derive("ISConvertWasherToChurningMachine")

-- DC016 Phase 6: the four rows the real White Washing Machine can face (per Ed), now all
-- declared as faces of our own entity too (entity_ChurningMachine.txt). Used both to validate
-- the detected real washer's sprite and as the fallback default if detection ever fails.
local CHURNING_MACHINE_SPRITES = {
    ["appliances_laundry_01_4"] = true,
    ["appliances_laundry_01_5"] = true,
    ["appliances_laundry_01_6"] = true,
    ["appliances_laundry_01_7"] = true,
}
local DEFAULT_CHURNING_MACHINE_SPRITE = "appliances_laundry_01_7"

-- DC018 Phase 1: consumed on conversion, per Ed (2026-09-17) - the screwdriver (checked via
-- ChurningMachineCode.canConvertWasher) remains a kept tool requirement, not consumed here.
local CONVERSION_ITEM_TYPE = "Base.ElectronicsScrap"

function ISConvertWasherToChurningMachine:isValid()
    return self.object and self.object:getObjectIndex() ~= -1
end

function ISConvertWasherToChurningMachine:update()
    self.character:faceThisObject(self.object)
end

function ISConvertWasherToChurningMachine:start()
end

function ISConvertWasherToChurningMachine:stop()
    ISBaseTimedAction.stop(self)
end

function ISConvertWasherToChurningMachine:perform()
    ISBaseTimedAction.perform(self)
end

function ISConvertWasherToChurningMachine:complete()
    local square = self.object:getSquare()
    if not square then
        return false
    end

    -- DC016 Phase 6: reuse the real washer's own current sprite (one of the four directional
    -- rows) instead of always using the fixed default, so the converted Churning Machine faces
    -- the same way the real washer did. Falls back to the default row (logged) if the detected
    -- sprite isn't one of the four expected ones, rather than failing outright.
    local detectedSprite = self.object:getSprite() and self.object:getSprite():getName()
    local spriteName = detectedSprite
    if not spriteName or not CHURNING_MACHINE_SPRITES[spriteName] then
        print("ISConvertWasherToChurningMachine: unexpected washer sprite '" .. tostring(detectedSprite) .. "', falling back to " .. DEFAULT_CHURNING_MACHINE_SPRITE)
        spriteName = DEFAULT_CHURNING_MACHINE_SPRITE
    end

    local objectInfo = SpriteConfigManager.getObjectInfoFromSprite(spriteName)
    if not objectInfo or not objectInfo:getScript() then
        print("ISConvertWasherToChurningMachine: could not resolve the Churning Machine's entity script from sprite " .. spriteName)
        return false
    end
    local gameEntityScript = objectInfo:getScript():getParent()

    -- DC016 Phase 5 fix: IsoObject has no getNorth() - that's specific to IsoThumpable/wall-like
    -- objects. IsoClothingWasher extends IsoObject directly, so a real washer has no orientation
    -- to read in the first place. This "north" is IsoThumpable's own separate open/closed-sprite
    -- orientation concept (irrelevant here - we don't use that constructor overload) - which of
    -- the four directions actually displays is fully determined by spriteName above, not this.
    local north = false

    -- DC016 Phase 1 finding: transmitRemoveItemFromSquare is the real mechanism vanilla's own
    -- multi-stage build system uses to remove a "previous stage" object before placing the next
    -- one at the same square, returning an index the new object can reuse.
    local replacedObjectIndex = square:transmitRemoveItemFromSquare(self.object)

    -- DC016 Phase 1 finding: the minimal 4-arg IsoThumpable constructor (no builder-cursor table
    -- required) plus GameEntityFactory.CreateIsoObjectEntity is the same mechanism
    -- ISBuildIsoEntity.lua uses internally for every normally-built entity, including our own
    -- Churning Machine when built via its CraftRecipe - this just invokes it directly instead of
    -- through a build recipe. Not yet confirmed whether this mod's isThumpable=false setting
    -- means this path is wrong for our specific entity (see DevCycle016.md Phase 1 notes) -
    -- flagged for in-game verification, not assumed correct.
    local thumpable = IsoThumpable.new(getCell(), square, spriteName, north)
    local isFirstTimeCreated = true
    GameEntityFactory.CreateIsoObjectEntity(thumpable, gameEntityScript, isFirstTimeCreated)

    square:AddSpecialObject(thumpable, replacedObjectIndex)
    square:RecalcAllWithNeighbours(true)
    thumpable:setExplored(true)
    thumpable:transmitCompleteItemToClients()

    -- DC018 Phase 1: consume 1 Scrap Electronics on successful conversion.
    self.character:getInventory():RemoveOneOf(CONVERSION_ITEM_TYPE)

    return true
end

function ISConvertWasherToChurningMachine:getDuration()
    return 100
end

function ISConvertWasherToChurningMachine:new(character, object)
    local o = ISBaseTimedAction.new(self, character)
    o.character = character
    o.object = object
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = o:getDuration()
    return o
end
