--***********************************************************
--** PseudoSaltWellB42 Part 4: Location-Based Hole Type
--** ISFillPotFromWell.lua
--***********************************************************
--** Timed action for filling a pot with saltwater from well
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISFillPotFromWell = ISBaseTimedAction:derive("ISFillPotFromWell");

function ISFillPotFromWell:isValid()
    return self.well ~= nil and self.pot ~= nil;
end

function ISFillPotFromWell:update()
    self.character:faceThisObject(self.well);
end

function ISFillPotFromWell:start()
    self:setActionAnim("Loot");
    self.character:SetVariable("LootPosition", "Mid");
end

function ISFillPotFromWell:stop()
    ISBaseTimedAction.stop(self);
end

function ISFillPotFromWell:perform()
    ISBaseTimedAction.perform(self);

    -- Remove empty pot from inventory
    self.character:getInventory():Remove(self.pot);

    -- Add saltwater pot to inventory
    local saltwaterPot = self.character:getInventory():AddItem("Pseudonymous.SaltwaterPot");

    if saltwaterPot then
        -- Play sound
        self.character:getEmitter():playSound("GetWaterFromTap");
    end
end

function ISFillPotFromWell:new(character, well, pot, time)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.well = well;
    o.pot = pot;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time;
    return o;
end
