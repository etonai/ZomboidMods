--***********************************************************
--** PseudoSaltWellB42 Part 5: Independent Items
--** EmptySaltwaterMenu.lua
--***********************************************************
--** Context menu for emptying saltwater and salt containers
--***********************************************************

require "TimedActions/ISEmptySaltwaterContainer"

EmptySaltwaterMenu = {};

EmptySaltwaterMenu.EmptyTypes = {
    ["PseudoSaltWellB42.SaltwaterPot"] = "Base.Pot",
    ["PseudoSaltWellB42.SaltPot"] = "Base.Pot",
    ["PseudoSaltWellB42.SaltwaterPotForged"] = "Base.PotForged",
    ["PseudoSaltWellB42.SaltPotForged"] = "Base.PotForged",
    ["PseudoSaltWellB42.SaltwaterKettle"] = "Base.Kettle",
    ["PseudoSaltWellB42.SaltKettle"] = "Base.Kettle",
    ["PseudoSaltWellB42.SaltwaterKettleCopper"] = "Base.Kettle_Copper",
    ["PseudoSaltWellB42.SaltKettleCopper"] = "Base.Kettle_Copper",
    ["PseudoSaltWellB42.SaltwaterBucket"] = "Base.Bucket",
    ["PseudoSaltWellB42.SaltBucket"] = "Base.Bucket",
    ["PseudoSaltWellB42.SaltwaterBucketForged"] = "Base.BucketForged",
    ["PseudoSaltWellB42.SaltBucketForged"] = "Base.BucketForged",
};

--************************************************************************--
--** EmptySaltwaterMenu.onEmptyContainer
--** Called when player selects "Empty Container" from context menu
--************************************************************************--
function EmptySaltwaterMenu.onEmptyContainer(playerObj, container, emptyType)
    if playerObj:getInventory():contains(container) then
        ISTimedActionQueue.add(ISEmptySaltwaterContainer:new(playerObj, container, emptyType, 50));
    end
end

--************************************************************************--
--** EmptySaltwaterMenu.createMenu
--** Adds "Empty Container" option to inventory context menu
--************************************************************************--
function EmptySaltwaterMenu.createMenu(playerIndex, context, items)
    local playerObj = getSpecificPlayer(playerIndex);
    if not playerObj then return end

    -- Process each selected item
    for _, item in ipairs(items) do
        local actualItem = item;
        if not instanceof(item, "InventoryItem") then
            actualItem = item.items[1];
        end

        if actualItem then
            local itemType = actualItem:getFullType();
            local emptyType = EmptySaltwaterMenu.EmptyTypes[itemType];

            -- Add "Empty Container" option if this is one of our items
            if emptyType then
                context:addOption(
                    getText("ContextMenu_EmptyContainer"),
                    playerObj,
                    EmptySaltwaterMenu.onEmptyContainer,
                    actualItem,
                    emptyType
                );
            end
        end
    end
end

-- Register the context menu handler
Events.OnFillInventoryObjectContextMenu.Add(EmptySaltwaterMenu.createMenu);
