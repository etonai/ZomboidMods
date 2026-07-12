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

WellFillMenu.ContainerTypes = {
    ["Base.Pot"] = potData,
    ["Pot"] = potData,
    ["Base.PotForged"] = forgedPotData,
    ["PotForged"] = forgedPotData,
    ["Base.Kettle"] = kettleData,
    ["Kettle"] = kettleData,
    ["Base.Kettle_Copper"] = copperKettleData,
    ["Kettle_Copper"] = copperKettleData,
    ["Base.Bucket"] = bucketData,
    ["Bucket"] = bucketData,
    ["Base.BucketEmpty"] = bucketData,
    ["BucketEmpty"] = bucketData,
    ["Base.BucketForged"] = forgedBucketData,
    ["BucketForged"] = forgedBucketData,
};

local function findSaltwaterWell(worldobjects)
    for _, obj in ipairs(worldobjects) do
        if obj:getName() == "SaltwaterWell" then
            return obj;
        end
    end

    return nil;
end

local function getContainerData(item)
    if not item then
        return nil;
    end

    if item:getFluidContainer() and not item:getFluidContainer():isEmpty() then
        return nil;
    end

    local fullType = tostring(item:getFullType() or "");
    local type = tostring(item:getType() or "");
    local data = WellFillMenu.ContainerTypes[fullType] or WellFillMenu.ContainerTypes[type];
    if data then
        return data;
    end

    local pourType = item:getPourType();
    local eatType = item:getEatType();
    local icon = tostring(item:getIcon() or "");

    if pourType == "Kettle" and fullType and string.find(fullType, "Kettle_Copper", 1, true) then
        return copperKettleData;
    end

    if pourType == "Kettle" and type and string.find(type, "Kettle_Copper", 1, true) then
        return copperKettleData;
    end

    if pourType == "Kettle" then
        return kettleData;
    end

    if eatType == "Pot" or pourType == "Pot" then
        if (fullType and string.find(fullType, "Forged", 1, true)) or (type and string.find(type, "Forged", 1, true)) or (icon and string.find(icon, "Forged", 1, true)) then
            return forgedPotData;
        end
        return potData;
    end

    if eatType == "Bucket" or pourType == "Bucket" then
        if (fullType and string.find(fullType, "Forged", 1, true)) or (type and string.find(type, "Forged", 1, true)) or (icon and string.find(icon, "Forged", 1, true)) then
            return forgedBucketData;
        end
        return bucketData;
    end

    return nil;
end

local function isAccessibleInventoryItem(item)
    return item ~= nil and item:getContainer() ~= nil;
end

local function collectFillableContainers(playerObj)
    local containers = {
        pot = {},
        kettle = {},
        bucket = {},
    };

    local allItems = playerObj:getInventory():getAllEvalRecurse(function(item)
        return getContainerData(item) ~= nil;
    end);

    for i=0, allItems:size()-1 do
        local item = allItems:get(i);
        local containerData = getContainerData(item);
        if containerData then
            table.insert(containers[containerData.group], { item = item, data = containerData });
        end
    end

    return containers;
end

function WellFillMenu.onFillContainer(worldobjects, container, player, containerData)
    local playerObj = getSpecificPlayer(player);
    local well = findSaltwaterWell(worldobjects);

    if well and containerData and isAccessibleInventoryItem(container) then
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