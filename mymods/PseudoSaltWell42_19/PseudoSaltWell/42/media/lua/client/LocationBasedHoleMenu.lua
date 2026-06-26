--***********************************************************
--** PseudoSaltWellB42 Part 4: Location-Based Hole Type
--** LocationBasedHoleMenu.lua
--***********************************************************
--** Adds "Dig a Hole" context menu option to ground
--***********************************************************

-- ISLocationBasedHole is loaded automatically from server/BuildingObjects/
require "SaltwaterLocationDetector"

LocationBasedHoleMenu = {};

--************************************************************************--
--** LocationBasedHoleMenu.onDigHole
--** Triggered when player selects "Dig a Hole" from context menu
--************************************************************************--
function LocationBasedHoleMenu.onDigHole(worldobjects, shovel, player)
    local playerObj = getSpecificPlayer(player);

    -- Sprite is just the initial ghost texture; ISLocationBasedHole:render()
    -- recomputes the correct sprite every frame based on whichever square is
    -- under the cursor, and ISLocationBasedHole:create() recomputes again
    -- from the actual placement coordinates. Free placement (no locked
    -- coordinates) matches how vanilla's own grave-digging cursor behaves —
    -- see ISWorldObjectContextMenu.onDigGraves.
    local hole = ISLocationBasedHole:new("location_community_cemetary_01_33", shovel);
    hole.player = player;
    hole.character = playerObj;

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
        if item:hasTag(ItemTag.DIG_GRAVE) then
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

    local option = shovelSubMenu:addOption(
        getText("ContextMenu_DigAHole"),
        worldobjects,
        LocationBasedHoleMenu.onDigHole,
        shovel,
        player
    );
end

-- Register the context menu handler
Events.OnFillWorldObjectContextMenu.Add(LocationBasedHoleMenu.createMenu);
