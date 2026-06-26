--***********************************************************
--** PseudoSaltWellB42 Part 5: Independent Items
--** WellFillMenu.lua
--***********************************************************
--** Context menu for filling pots and kettles from saltwater well
--***********************************************************

require "TimedActions/ISFillPotFromWell"
require "TimedActions/ISFillKettleFromWell"

WellFillMenu = {};

--************************************************************************--
--** WellFillMenu.onFillPot
--** Called when player selects "Fill Pot" from context menu
--************************************************************************--
function WellFillMenu.onFillPot(worldobjects, pot, player)
    local playerObj = getSpecificPlayer(player);
    local well = nil;

    -- Find the saltwater well object
    for _, obj in ipairs(worldobjects) do
        if obj:getName() == "SaltwaterWell" then
            well = obj;
            break;
        end
    end

    if well and playerObj:getInventory():contains(pot) then
        ISTimedActionQueue.add(ISFillPotFromWell:new(playerObj, well, pot, 100));
    end
end

--************************************************************************--
--** WellFillMenu.onFillKettle
--** Called when player selects "Fill Kettle" from context menu
--************************************************************************--
function WellFillMenu.onFillKettle(worldobjects, kettle, player)
    local playerObj = getSpecificPlayer(player);
    local well = nil;

    -- Find the saltwater well object
    for _, obj in ipairs(worldobjects) do
        if obj:getName() == "SaltwaterWell" then
            well = obj;
            break;
        end
    end

    if well and playerObj:getInventory():contains(kettle) then
        ISTimedActionQueue.add(ISFillKettleFromWell:new(playerObj, well, kettle, 100));
    end
end

--************************************************************************--
--** WellFillMenu.createMenu
--** Adds "Fill Pot" and "Fill Kettle" options to saltwater well context menu
--************************************************************************--
function WellFillMenu.createMenu(player, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return ISWorldObjectContextMenu.setTest() end

    local playerObj = getSpecificPlayer(player);
    if not playerObj then return end

    -- Check if we're clicking on a saltwater well
    local hasSaltwaterWell = false;
    for _, obj in ipairs(worldobjects) do
        if obj:getName() == "SaltwaterWell" then
            hasSaltwaterWell = true;
            break;
        end
    end

    if not hasSaltwaterWell then return end

    -- Check player's inventory for pots and kettles
    local inv = playerObj:getInventory();
    local items = inv:getItems();
    local emptyPots = {};
    local emptyKettles = {};

    for i=0, items:size()-1 do
        local item = items:get(i);
        local itemType = item:getFullType();

        if itemType == "Base.Pot" then
            table.insert(emptyPots, item);
        elseif itemType == "Base.Kettle" then
            table.insert(emptyKettles, item);
        end
    end

    -- Add "Fill Pot with Saltwater" options if player has empty pots
    if #emptyPots > 0 then
        if test then return ISWorldObjectContextMenu.setTest() end

        local fillPotOption = context:addOption(getText("ContextMenu_FillPotWithSaltwater"), worldobjects, nil);
        local fillPotSubMenu = ISContextMenu:getNew(context);
        context:addSubMenu(fillPotOption, fillPotSubMenu);

        for _, pot in ipairs(emptyPots) do
            fillPotSubMenu:addOption(
                pot:getName(),
                worldobjects,
                WellFillMenu.onFillPot,
                pot,
                player
            );
        end
    end

    -- Add "Fill Kettle with Saltwater" options if player has empty kettles
    if #emptyKettles > 0 then
        if test then return ISWorldObjectContextMenu.setTest() end

        local fillKettleOption = context:addOption(getText("ContextMenu_FillKettleWithSaltwater"), worldobjects, nil);
        local fillKettleSubMenu = ISContextMenu:getNew(context);
        context:addSubMenu(fillKettleOption, fillKettleSubMenu);

        for _, kettle in ipairs(emptyKettles) do
            fillKettleSubMenu:addOption(
                kettle:getName(),
                worldobjects,
                WellFillMenu.onFillKettle,
                kettle,
                player
            );
        end
    end
end

-- Register the context menu handler
Events.OnFillWorldObjectContextMenu.Add(WellFillMenu.createMenu);
