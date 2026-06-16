--***********************************************************
--** PseudoSaltWellB42 Part 5: Independent Items
--** EmptySaltwaterMenu.lua
--***********************************************************
--** Context menu for emptying saltwater and salt containers
--***********************************************************

require "TimedActions/ISEmptySaltwaterContainer"

EmptySaltwaterMenu = {};

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
            local emptyType = nil;

            -- Determine which container type to return
            if itemType == "PseudoSaltWellB42.SaltwaterPot" or itemType == "PseudoSaltWellB42.SaltPot" then
                emptyType = "Base.Pot";
            elseif itemType == "PseudoSaltWellB42.SaltwaterKettle" or itemType == "PseudoSaltWellB42.SaltKettle" then
                emptyType = "Base.Kettle";
            end

            -- Add "Empty Container" option if this is one of our items
            if emptyType then
                context:addOption(
                    "Empty Container",
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
