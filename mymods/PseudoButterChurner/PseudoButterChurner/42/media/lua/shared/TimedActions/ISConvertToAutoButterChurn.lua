-- Converts a placed, empty, powered-off IsoClothingWasher or
-- IsoCombinationWasherDryer into an AutoButterChurn scripted entity, in
-- place. Modeled on media/lua/shared/TimedActions/ISOpenCloseLid.lua's
-- :complete(), which uses the same square:RemoveTileObject /
-- square:addWorkstationEntity pattern to swap a legacy world object for a
-- scripted entity. "washer" is a generic name here - it may hold either
-- source object type; only IsoObject-level methods are used on it, so both
-- work identically.
--
-- See doc/planning/DevCycle001.md Phase 2, Phase 8, and Phase 17.

require "TimedActions/ISBaseTimedAction"
require "AutoButterChurnCode"

ISConvertToAutoButterChurn = ISBaseTimedAction:derive("ISConvertToAutoButterChurn")

ISConvertToAutoButterChurn.ENTITY_SCRIPT = AutoButterChurnCode.ENTITY_SCRIPT

-- Confirmed visible in-game during Phase 16 testing. entity_AutoButterChurn.txt's
-- own declared SpriteConfig row is a different value (crafted_05_78) - this
-- is the separate runtime "closedSprite" argument to addWorkstationEntity,
-- which has no uniqueness constraint with other entities' declared rows
-- (unlike the Phase 7 load-time duplicate-sprite check). Still a
-- placeholder reusing the manual Butter Churn's look, not real custom art -
-- see DevCycle001.md Notes and Risks.
ISConvertToAutoButterChurn.SPRITE = "crafted_05_72"

function ISConvertToAutoButterChurn:isValid()
    return self.washer and not self.washer:isActivated() and self.washer:getContainer()
        and self.washer:getContainer():isEmpty()
end

function ISConvertToAutoButterChurn:waitToStart()
    self.character:faceThisObject(self.washer)
    return self.character:shouldBeTurning()
end

function ISConvertToAutoButterChurn:update()
    self.character:faceThisObject(self.washer)
    self.character:setMetabolicTarget(Metabolics.HeavyDomestic)
end

function ISConvertToAutoButterChurn:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
end

function ISConvertToAutoButterChurn:stop()
    ISBaseTimedAction.stop(self)
end

function ISConvertToAutoButterChurn:perform()
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

function ISConvertToAutoButterChurn:complete()
    self.square:transmitRemoveItemFromSquare(self.washer)
    self.square:RemoveTileObject(self.washer)

    local newEntity = self.square:addWorkstationEntity(ISConvertToAutoButterChurn.ENTITY_SCRIPT, ISConvertToAutoButterChurn.SPRITE)

    -- TEMPORARY diagnostics, DevCycle001.md Phase 17. Keep in place until
    -- the new FluidContainer-based fill + registry-tick churn flow has been
    -- confirmed working end-to-end (per the Phase 15 lesson: don't remove
    -- diagnostics before a fix is confirmed).
    print("AutoButterChurnDiag: addWorkstationEntity returned " .. tostring(newEntity))

    if newEntity then
        newEntity:sync()
        AutoButterChurnCode.registerEntity(self.square)
        print("AutoButterChurnDiag: registered entity at " .. tostring(self.square:getX()) .. "," .. tostring(self.square:getY()) .. "," .. tostring(self.square:getZ()) .. " in " .. AutoButterChurnCode.REGISTRY_KEY)
    end

    return true
end

function ISConvertToAutoButterChurn:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
    return 200 -- roughly matches other Electrical-skill workbench conversions; revisit after playtesting
end

function ISConvertToAutoButterChurn:new(character, washer, square)
    local o = ISBaseTimedAction.new(self, character)
    o.character = character
    o.washer = washer
    o.square = square
    o.maxTime = o:getDuration()
    o.stopOnWalk = true
    o.stopOnRun = true
    return o
end
