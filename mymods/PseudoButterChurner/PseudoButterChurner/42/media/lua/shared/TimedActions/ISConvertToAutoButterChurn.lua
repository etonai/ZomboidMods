-- Converts a placed, empty, powered-off IsoClothingWasher into an
-- AutoButterChurn scripted entity, in place. Modeled on
-- media/lua/shared/TimedActions/ISOpenCloseLid.lua's :complete(), which uses
-- the same square:RemoveTileObject / square:addWorkstationEntity pattern to
-- swap a legacy world object for a scripted entity.
--
-- See doc/planning/DevCycle001.md Phase 2.

require "TimedActions/ISBaseTimedAction"

ISConvertToAutoButterChurn = ISBaseTimedAction:derive("ISConvertToAutoButterChurn")

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
    local health = self.washer:getHealth()
    local maxHealth = self.washer:getMaxHealth()

    self.square:transmitRemoveItemFromSquare(self.washer)
    self.square:RemoveTileObject(self.washer)

    local newEntity = self.square:addWorkstationEntity("AutoButterChurn", ISConvertToAutoButterChurn.SPRITE)
    if newEntity then
        newEntity:setMaxHealth(maxHealth)
        newEntity:setHealth(health)
        newEntity:sync()
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
