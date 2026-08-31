-- Adds a "Convert to Automatic Butter Churner" context-menu option on a
-- placed, empty, powered-off IsoClothingWasher or IsoCombinationWasherDryer.
-- See doc/planning/DevCycle001.md Phase 2 and Phase 8, and
-- doc/ideas/claude_automaticButterChurning.md §4a.

require "TimedActions/ISConvertToAutoButterChurn"

ISAutoButterChurnContextMenu = {}

ISAutoButterChurnContextMenu.REQUIRED_ELECTRICAL_LEVEL = 5

-- Testing scope (DevCycle001.md Phase 11): only the combo washer/dryer is
-- offered for conversion until that path is confirmed working end-to-end.
-- Flip this back to true once combo testing succeeds, to re-enable the
-- plain IsoClothingWasher.
ISAutoButterChurnContextMenu.ALLOW_PLAIN_WASHER = false

function ISAutoButterChurnContextMenu.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return true end

    local playerObj = getSpecificPlayer(player)
    if not playerObj or playerObj:getVehicle() then return false end

    -- "washer" here is either a plain IsoClothingWasher or an
    -- IsoCombinationWasherDryer (in either washer or dryer mode) - both are
    -- eligible conversion sources (Q9 was revised in Phase 8 to include the
    -- combo unit). Both extend IsoObject directly (not each other), and both
    -- expose isActivated()/getContainer()/getSquare(), so the rest of this
    -- file treats them identically. Plain IsoClothingWasher is currently
    -- disabled for testing - see ALLOW_PLAIN_WASHER above and Phase 11.
    local washer = nil
    for i = 1, #worldobjects do
        local square = worldobjects[i]:getSquare()
        if square then
            local objects = square:getObjects()
            for j = 0, objects:size() - 1 do
                local obj = objects:get(j)
                local isPlainWasher = ISAutoButterChurnContextMenu.ALLOW_PLAIN_WASHER and instanceof(obj, "IsoClothingWasher")
                if isPlainWasher or instanceof(obj, "IsoCombinationWasherDryer") then
                    washer = obj
                    break
                end
            end
        end
        if washer then break end
    end

    if not washer then return false end
    if test then return ISWorldObjectContextMenu.setTest() end

    local playerInv = playerObj:getInventory()
    local hasScrewdriver = playerInv:getFirstTagRecurse(ItemTag.SCREWDRIVER) ~= nil
    local hasSkill = playerObj:getPerkLevel(Perks.Electricity) >= ISAutoButterChurnContextMenu.REQUIRED_ELECTRICAL_LEVEL
    local isEmptyAndOff = not washer:isActivated() and washer:getContainer() and washer:getContainer():isEmpty()

    local option = context:addGetUpOption(getText("ContextMenu_ConvertToAutoButterChurn"), washer,
        ISAutoButterChurnContextMenu.onConvert, playerObj)

    if not hasScrewdriver or not hasSkill or not isEmptyAndOff then
        option.notAvailable = true
        option.toolTip = ISWorldObjectContextMenu.addToolTip()
        option.toolTip:setVisible(false)
        option.toolTip:setName(ISWorldObjectContextMenu.getMoveableDisplayName(washer))
        local description = ""
        if not hasScrewdriver then
            description = description .. getText("Tooltip_AutoButterChurn_NeedsScrewdriver") .. " <LINE> "
        end
        if not hasSkill then
            description = description .. getText("Tooltip_AutoButterChurn_NeedsElectrical") .. " <LINE> "
        end
        if not isEmptyAndOff then
            description = description .. getText("Tooltip_AutoButterChurn_MustBeEmptyAndOff") .. " <LINE> "
        end
        option.toolTip.description = description
    end

    return true
end

function ISAutoButterChurnContextMenu.onConvert(washer, playerObj)
    if luautils.walkAdj(playerObj, washer:getSquare(), false) then
        ISTimedActionQueue.add(ISConvertToAutoButterChurn:new(playerObj, washer, washer:getSquare()))
    end
end

Events.OnFillWorldObjectContextMenu.Add(ISAutoButterChurnContextMenu.OnFillWorldObjectContextMenu)
