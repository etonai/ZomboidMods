--***********************************************************
--** PseudoSaltWellB42 Part 5: Independent Items
--** ISFillPotFromWell.lua
--***********************************************************
--** Timed action for filling a pot with saltwater from well
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISFillPotFromWell = ISBaseTimedAction:derive("ISFillPotFromWell");

--************************************************************************--
--** ISFillPotFromWell:isValid
--************************************************************************--
function ISFillPotFromWell:isValid()
    return self.well ~= nil and self.pot ~= nil;
end

--************************************************************************--
--** ISFillPotFromWell:update
--************************************************************************--
function ISFillPotFromWell:update()
    self.character:faceThisObject(self.well);
end

--************************************************************************--
--** ISFillPotFromWell:start
--************************************************************************--
function ISFillPotFromWell:start()
    self:setActionAnim("Loot");
    self.character:SetVariable("LootPosition", "Mid");
end

--************************************************************************--
--** ISFillPotFromWell:stop
--************************************************************************--
function ISFillPotFromWell:stop()
    ISBaseTimedAction.stop(self);
end

--************************************************************************--
--** ISFillPotFromWell:perform
--** This is where the actual item transformation happens
--************************************************************************--
function ISFillPotFromWell:perform()
    ISBaseTimedAction.perform(self);

    -- Remove empty pot from inventory
    self.character:getInventory():Remove(self.pot);

    -- Add saltwater pot to inventory
    local saltwaterPot = self.character:getInventory():AddItem("PseudoSaltWellB42.SaltwaterPot");

    if saltwaterPot then
        -- Play sound
        self.character:getEmitter():playSound("GetWaterFromLake");
    end
end

--************************************************************************--
--** ISFillPotFromWell:new
--************************************************************************--
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

return ISFillPotFromWell;
