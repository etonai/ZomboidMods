--***********************************************************
--** PseudoSaltWellB42 Part 5: Independent Items
--** ISFillKettleFromWell.lua
--***********************************************************
--** Timed action for filling a kettle with saltwater from well
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISFillKettleFromWell = ISBaseTimedAction:derive("ISFillKettleFromWell");

--************************************************************************--
--** ISFillKettleFromWell:isValid
--************************************************************************--
function ISFillKettleFromWell:isValid()
    return self.well ~= nil and self.kettle ~= nil;
end

--************************************************************************--
--** ISFillKettleFromWell:update
--************************************************************************--
function ISFillKettleFromWell:update()
    self.character:faceThisObject(self.well);
end

--************************************************************************--
--** ISFillKettleFromWell:start
--************************************************************************--
function ISFillKettleFromWell:start()
    self:setActionAnim("Loot");
    self.character:SetVariable("LootPosition", "Mid");
end

--************************************************************************--
--** ISFillKettleFromWell:stop
--************************************************************************--
function ISFillKettleFromWell:stop()
    ISBaseTimedAction.stop(self);
end

--************************************************************************--
--** ISFillKettleFromWell:perform
--** This is where the actual item transformation happens
--************************************************************************--
function ISFillKettleFromWell:perform()
    ISBaseTimedAction.perform(self);

    -- Remove empty kettle from inventory
    self.character:getInventory():Remove(self.kettle);

    -- Add saltwater kettle to inventory
    local saltwaterKettle = self.character:getInventory():AddItem("PseudoSaltWellB42.SaltwaterKettle");

    if saltwaterKettle then
        -- Play sound
        self.character:getEmitter():playSound("GetWaterFromLake");
    end
end

--************************************************************************--
--** ISFillKettleFromWell:new
--************************************************************************--
function ISFillKettleFromWell:new(character, well, kettle, time)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.well = well;
    o.kettle = kettle;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time;
    return o;
end

return ISFillKettleFromWell;
