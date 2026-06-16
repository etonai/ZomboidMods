--***********************************************************
--** PseudoSaltWellB42 Part 3: Well Fill Pot
--** WellFillMenu.lua
--***********************************************************
--** Adds context menu option to fill pots from wells
--***********************************************************

require "TimedActions/ISFillPotFromWell"

WellFillMenu = {};

--************************************************************************--
--** WellFillMenu.onFillPot
--** Triggered when player selects "Fill Pot with Saltwater" from context menu
--************************************************************************--
function WellFillMenu.onFillPot(worldObjects, pot, player)
    local playerObj = getSpecificPlayer(player);

    -- Find the well object
    local well = nil;
    for _, obj in ipairs(worldObjects) do
        if obj:getName() == "SimpleWell" then
            well = obj;
            break;
        end
    end

    if well and pot then
        -- Queue the timed action
        ISTimedActionQueue.add(ISFillPotFromWell:new(playerObj, well, pot, 100));
    end
end

--************************************************************************--
--** WellFillMenu.createMenu
--** Adds context menu options when right-clicking a well
--************************************************************************--
function WellFillMenu.createMenu(player, context, worldObjects, test)
    if test and ISWorldObjectContextMenu.Test then return ISWorldObjectContextMenu.setTest() end

    local playerObj = getSpecificPlayer(player);
    if not playerObj then return end

    -- Check if we clicked on a well
    local well = nil;
    for _, obj in ipairs(worldObjects) do
        if obj:getName() == "SimpleWell" then
            well = obj;
            break;
        end
    end

    if not well then return end

    -- Check if player has an empty pot in inventory
    local inv = playerObj:getInventory();
    local pot = inv:getFirstTypeRecurse("Pot");

    if not pot then return end

    -- Add "Fill Pot with Saltwater" context menu option
    if test then return ISWorldObjectContextMenu.setTest() end

    local option = context:addOption(
        "Fill Pot with Saltwater",
        worldObjects,
        WellFillMenu.onFillPot,
        pot,
        player
    );
end

-- Register the context menu handler
Events.OnFillWorldObjectContextMenu.Add(WellFillMenu.createMenu);
