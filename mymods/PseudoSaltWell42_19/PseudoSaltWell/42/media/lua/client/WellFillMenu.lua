--***********************************************************
--** PseudoSaltWellB42 Part 5: Independent Items
--** WellFillMenu.lua
--***********************************************************
--** Context menu for filling vessels from saltwater well
--***********************************************************

require "TimedActions/ISFillPotFromWell"
require "TimedActions/ISFillKettleFromWell"

WellFillMenu = {};

local potData = {
    group = "pot",
    saltwaterType = "PseudoSaltWellB42.SaltwaterPot",
    action = ISFillPotFromWell,
};

local forgedPotData = {
    group = "pot",
    saltwaterType = "PseudoSaltWellB42.SaltwaterPotForged",
    action = ISFillPotFromWell,
};

local kettleData = {
    group = "kettle",
    saltwaterType = "PseudoSaltWellB42.SaltwaterKettle",
    action = ISFillKettleFromWell,
};

local copperKettleData = {
    group = "kettle",
    saltwaterType = "PseudoSaltWellB42.SaltwaterKettleCopper",
    action = ISFillKettleFromWell,
};

local bucketData = {
    group = "bucket",
    saltwaterType = "PseudoSaltWellB42.SaltwaterBucket",
    action = ISFillPotFromWell,
};

local forgedBucketData = {
    group = "bucket",
    saltwaterType = "PseudoSaltWellB42.SaltwaterBucketForged",
    action = ISFillPotFromWell,
};

local fillableTypes = {
    { type = "Base.Pot", data = potData },
    { type = "Pot", data = potData },
    { type = "Base.PotForged", data = forgedPotData },
    { type = "PotForged", data = forgedPotData },
    { type = "Base.Kettle", data = kettleData },
    { type = "Kettle", data = kettleData },
    { type = "Base.Kettle_Copper", data = copperKettleData },
    { type = "Kettle_Copper", data = copperKettleData },
    { type = "Base.Bucket", data = bucketData },
    { type = "Bucket", data = bucketData },
    { type = "Base.BucketEmpty", data = bucketData },
    { type = "BucketEmpty", data = bucketData },
    { type = "Base.BucketForged", data = forgedBucketData },
    { type = "BucketForged", data = forgedBucketData },
};

local function findSaltwaterWell(worldobjects)
    for _, obj in ipairs(worldobjects) do
        if obj:getName() == "SaltwaterWell" then
            return obj;
        end
    end

    return nil;
end

local function isEmptyFluidContainer(item)
    return item ~= nil and (not item:getFluidContainer() or item:getFluidContainer():isEmpty());
end

local function isAccessibleInventoryItem(item)
    return item ~= nil and item:getContainer() ~= nil;
end

local function addFillableItemsByType(inventory, containers, seenItems, itemType, containerData)
    local items = inventory:getAllTypeRecurse(itemType);
    if not items then
        return;
    end

    for i=0, items:size()-1 do
        local item = items:get(i);
        local seenKey = tostring(item);
        if not seenItems[seenKey] and isAccessibleInventoryItem(item) and isEmptyFluidContainer(item) then
            seenItems[seenKey] = true;
            table.insert(containers[containerData.group], { item = item, data = containerData });
        end
    end
end

local function collectFillableContainers(playerObj)
    local containers = {
        pot = {},
        kettle = {},
        bucket = {},
    };

    local inventory = playerObj:getInventory();
    local seenItems = {};

    for _, entry in ipairs(fillableTypes) do
        addFillableItemsByType(inventory, containers, seenItems, entry.type, entry.data);
    end

    return containers;
end

function WellFillMenu.onFillContainer(worldobjects, container, player, containerData)
    local playerObj = getSpecificPlayer(player);
    local well = findSaltwaterWell(worldobjects);

    if well and containerData and isAccessibleInventoryItem(container) and isEmptyFluidContainer(container) then
        ISTimedActionQueue.add(containerData.action:new(playerObj, well, container, 100, containerData.saltwaterType));
    end
end

function WellFillMenu.addFillSubMenu(context, worldobjects, player, title, containers)
    if #containers < 1 then
        return;
    end

    local fillOption = context:addOption(title, worldobjects, nil);
    local fillSubMenu = ISContextMenu:getNew(context);
    context:addSubMenu(fillOption, fillSubMenu);

    for _, entry in ipairs(containers) do
        fillSubMenu:addOption(
            entry.item:getName(),
            worldobjects,
            WellFillMenu.onFillContainer,
            entry.item,
            player,
            entry.data
        );
    end
end

function WellFillMenu.createMenu(player, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return ISWorldObjectContextMenu.setTest() end

    local playerObj = getSpecificPlayer(player);
    if not playerObj then return end

    if not findSaltwaterWell(worldobjects) then return end

    local containers = collectFillableContainers(playerObj);

    if #containers.pot > 0 or #containers.kettle > 0 or #containers.bucket > 0 then
        if test then return ISWorldObjectContextMenu.setTest() end
    end

    WellFillMenu.addFillSubMenu(context, worldobjects, player, getText("ContextMenu_FillPotWithSaltwater"), containers.pot);
    WellFillMenu.addFillSubMenu(context, worldobjects, player, getText("ContextMenu_FillKettleWithSaltwater"), containers.kettle);
    WellFillMenu.addFillSubMenu(context, worldobjects, player, getText("ContextMenu_FillBucketWithSaltwater"), containers.bucket);
end

Events.OnFillWorldObjectContextMenu.Add(WellFillMenu.createMenu);