--***********************************************************
--** PseudoSaltWellB42 Part 5: Independent Items
--** ISFillPotFromWell.lua
--***********************************************************
--** Timed action for filling a pot-like container with saltwater from well
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISFillPotFromWell = ISBaseTimedAction:derive("ISFillPotFromWell");

function ISFillPotFromWell:isValid()
    return self.well ~= nil and self.pot ~= nil and self.pot:getContainer() ~= nil and self.saltwaterType ~= nil;
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

    self.pot:getContainer():Remove(self.pot);

    local saltwaterContainer = self.character:getInventory():AddItem(self.saltwaterType);
    if saltwaterContainer then
        self.character:getEmitter():playSound("GetWaterFromLake");
    end
end

function ISFillPotFromWell:new(character, well, pot, time, saltwaterType)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.well = well;
    o.pot = pot;
    o.saltwaterType = saltwaterType or "PseudoSaltWellB42.SaltwaterPot";
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time;
    return o;
end

return ISFillPotFromWell;