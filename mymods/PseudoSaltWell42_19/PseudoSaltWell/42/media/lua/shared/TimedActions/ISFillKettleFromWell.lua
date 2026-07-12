--***********************************************************
--** PseudoSaltWellB42 Part 5: Independent Items
--** ISFillKettleFromWell.lua
--***********************************************************
--** Timed action for filling a kettle-like container with saltwater from well
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISFillKettleFromWell = ISBaseTimedAction:derive("ISFillKettleFromWell");

function ISFillKettleFromWell:isValid()
    return self.well ~= nil and self.kettle ~= nil and self.kettle:getContainer() ~= nil and self.saltwaterType ~= nil;
end

function ISFillKettleFromWell:update()
    self.character:faceThisObject(self.well);
end

function ISFillKettleFromWell:start()
    self:setActionAnim("Loot");
    self.character:SetVariable("LootPosition", "Mid");
end

function ISFillKettleFromWell:stop()
    ISBaseTimedAction.stop(self);
end

function ISFillKettleFromWell:perform()
    ISBaseTimedAction.perform(self);

    self.kettle:getContainer():Remove(self.kettle);

    local saltwaterKettle = self.character:getInventory():AddItem(self.saltwaterType);
    if saltwaterKettle then
        self.character:getEmitter():playSound("GetWaterFromLake");
    end
end

function ISFillKettleFromWell:new(character, well, kettle, time, saltwaterType)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.well = well;
    o.kettle = kettle;
    o.saltwaterType = saltwaterType or "PseudoSaltWellB42.SaltwaterKettle";
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time;
    return o;
end

return ISFillKettleFromWell;