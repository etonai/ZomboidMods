--***********************************************************
--** PseudoSaltWellB42 Part 4: Location-Based Hole Type
--** LocationBasedHoleMenu.lua
--***********************************************************
--** Adds "Dig a Hole" context menu option to ground
--***********************************************************

require "BuildingObjects/ISLocationBasedHole"
require "SaltwaterLocationDetector"

LocationBasedHoleMenu = {};

--************************************************************************--
--** LocationBasedHoleMenu.onDigHole
--** Triggered when player selects "Dig a Hole" from context menu
--************************************************************************--
function LocationBasedHoleMenu.onDigHole(worldobjects, shovel, player, clickedSquare)
    local playerObj = getSpecificPlayer(player);

    -- Determine sprite based on the square that was clicked
    local worldX = clickedSquare:getX();
    local worldY = clickedSquare:getY();
    local isSaltwater = SaltwaterLocationDetector.isSaltwaterLocation(worldX, worldY);

    local spriteName;
    if isSaltwater then
        spriteName = "pseudoed_saltwell_01_0";
    else
        spriteName = "pseudoed_saltwell_01_1";
    end

    -- Create the hole building object with the determined sprite
    local hole = ISLocationBasedHole:new(spriteName, shovel);
    hole.player = player;
    hole.character = playerObj;
    hole.isSaltwater = isSaltwater;  -- Store for create() to use

    -- Lock to the clicked square coordinates
    hole.lockedX = worldX;
    hole.lockedY = worldY;

    -- Set the building cursor
    getCell():setDrag(hole, player);
end

--************************************************************************--
--** LocationBasedHoleMenu.createMenu
--** Adds context menu options when right-clicking ground
--************************************************************************--
function LocationBasedHoleMenu.createMenu(player, context, worldobjects, test)
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
    if not ISLocationBasedHole.canDigHere(worldobjects) then return end

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

    -- Add "Dig a Hole" option to the Shovel submenu
    if test then return ISWorldObjectContextMenu.setTest() end

    -- Get the square that was clicked for coordinate detection
    local clickedSquare = nil;
    for _, obj in ipairs(worldobjects) do
        if obj:getSquare() then
            clickedSquare = obj:getSquare();
            break;
        end
    end

    local option = shovelSubMenu:addOption(
        "Dig a Hole",
        worldobjects,
        LocationBasedHoleMenu.onDigHole,
        shovel,
        player,
        clickedSquare
    );
end

-- Register the context menu handler
Events.OnFillWorldObjectContextMenu.Add(LocationBasedHoleMenu.createMenu);
