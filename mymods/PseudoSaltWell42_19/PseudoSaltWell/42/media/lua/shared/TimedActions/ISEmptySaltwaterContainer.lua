--***********************************************************
--** PseudoSaltWellB42 Part 5: Independent Items
--** ISEmptySaltwaterContainer.lua
--***********************************************************
--** Timed action for emptying saltwater/salt containers
--** CRITICAL: Must manually remove and add items to avoid vanilla bug
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISEmptySaltwaterContainer = ISBaseTimedAction:derive("ISEmptySaltwaterContainer");

--************************************************************************--
--** ISEmptySaltwaterContainer:isValid
--************************************************************************--
function ISEmptySaltwaterContainer:isValid()
    return self.container ~= nil;
end

--************************************************************************--
--** ISEmptySaltwaterContainer:update
--************************************************************************--
function ISEmptySaltwaterContainer:update()
    -- No animation update needed for this action
end

--************************************************************************--
--** ISEmptySaltwaterContainer:start
--************************************************************************--
function ISEmptySaltwaterContainer:start()
    self:setActionAnim("Loot");
    self.character:SetVariable("LootPosition", "Low");
end

--************************************************************************--
--** ISEmptySaltwaterContainer:stop
--************************************************************************--
function ISEmptySaltwaterContainer:stop()
    ISBaseTimedAction.stop(self);
end

--************************************************************************--
--** ISEmptySaltwaterContainer:perform
--** CRITICAL: We manually remove the container and add the empty version
--** Cannot rely on ReplaceOnUseOn because vanilla "Pour on Ground" breaks it
--************************************************************************--
function ISEmptySaltwaterContainer:perform()
    ISBaseTimedAction.perform(self);

    -- Remove the full container
    self.character:getInventory():Remove(self.container);

    -- Add the empty container back
    -- emptyType will be "Base.Pot" or "Base.Kettle"
    self.character:getInventory():AddItem(self.emptyType);
end

--************************************************************************--
--** ISEmptySaltwaterContainer:new
--************************************************************************--
function ISEmptySaltwaterContainer:new(character, container, emptyType, time)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.container = container;
    o.emptyType = emptyType;  -- "Base.Pot" or "Base.Kettle"
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time;
    return o;
end

return ISEmptySaltwaterContainer;
