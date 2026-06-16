--***********************************************************
--** PseudoSaltWellB42 Part 3: Well Fill Pot
--** SimpleWellMenu.lua
--***********************************************************
--** Adds "Dig a Hole" context menu option to ground
--***********************************************************

require "BuildingObjects/ISSimpleWell"

SimpleWellMenu = {};

--************************************************************************--
--** SimpleWellMenu.onDigWell
--** Triggered when player selects "Dig Well" from context menu
--************************************************************************--
function SimpleWellMenu.onDigWell(worldobjects, shovel, player)
    local playerObj = getSpecificPlayer(player);

    -- Create the well building object with custom well sprite
    local well = ISSimpleWell:new("pseudoed_01_6", shovel);
    well.player = player;
    well.character = playerObj;

    -- Set the building cursor
    getCell():setDrag(well, player);
end

--************************************************************************--
--** SimpleWellMenu.createMenu
--** Adds context menu options when right-clicking ground
--************************************************************************--
function SimpleWellMenu.createMenu(player, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return ISWorldObjectContextMenu.setTest() end

    local playerObj = getSpecificPlayer(player);
    if not playerObj then return end

    -- Check if player has a shovel with DigGrave tag
    local shovel = nil;
    local inv = playerObj:getInventory();
    local items = inv:getItems();

    for i=0, items:size()-1 do
        local item = items:get(i);
        if item:hasTag("DigGrave") then
            shovel = item;
            break;
        end
    end

    -- If no shovel, don't add menu option
    if not shovel then return end

    -- Check if we can dig at this location
    if not ISSimpleWell.canDigHere(worldobjects) then return end

    -- Find the existing Shovel submenu (created by the game)
    local shovelSubMenu = context;
    local shovelOption = nil;
    for i,v in ipairs(context.options) do
        if v.name == getText("ContextMenu_Shovel") then
            shovelOption = v;
            shovelSubMenu = context:getSubMenu(shovelOption.subOption);
            break;
        end
    end

    -- Add "Dig Well" option to the Shovel submenu
    if test then return ISWorldObjectContextMenu.setTest() end

    local option = shovelSubMenu:addOption(
        "Dig a Hole",
        worldobjects,
        SimpleWellMenu.onDigWell,
        shovel,
        player
    );
end

-- Register the context menu handler
Events.OnFillWorldObjectContextMenu.Add(SimpleWellMenu.createMenu);
