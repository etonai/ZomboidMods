-- Adds an explicit "Open" context-menu option for the placed AutoButterChurn
-- entity. DC2 Phase 13: the generic vanilla mechanism that's supposed to add
-- this automatically (ISWorldMenuElements.ContextEntity, in
-- media/lua/client/Context/World/ISContextEntity.lua, auto-discovered via
-- ISMenuContextWorld.lua's loadElements(ISWorldMenuElements)) checks exactly
-- ISEntityUI.CanOpenWindowFor(player, entity) before adding its option -
-- confirmed true for this entity via AutoButterChurnWindowDiagnostic.lua on
-- two separate right-clicks, yet no option appeared either time. Rather than
-- keep tracing why the generic element isn't firing, this adds the same
-- option directly through Events.OnFillWorldObjectContextMenu (confirmed
-- working - the diagnostic hook fires reliably on this same event), using
-- the exact same already-confirmed-working ISEntityUI calls.

require "AutoButterChurnCode"

local ENTITY_SCRIPT = "Pseudonymous.AutoButterChurn"

local function findEntityAmongObjects(worldobjects)
    for i = 1, #worldobjects do
        local obj = worldobjects[i]
        if instanceof(obj, "IsoThumpable") and obj:getEntityScript() and obj:getEntityScript():getFullName() == ENTITY_SCRIPT then
            return obj
        end
    end
    return nil
end

local function onOpen(entity, playerObj)
    if ISEntityUI.CanOpenWindowFor(playerObj, entity) then
        ISEntityUI.OpenWindow(playerObj, entity)
    end
end

local function onFillWorldObjectContextMenu(player, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then
        return true
    end

    local playerObj = getSpecificPlayer(player)
    if not playerObj then
        return false
    end

    local entity = findEntityAmongObjects(worldobjects)
    if not entity then
        return false
    end

    if not ISEntityUI.CanOpenWindowFor(playerObj, entity) then
        return false
    end

    if not isClient() then
        AutoButterChurnCode.snapshotMilk(entity)
    end

    if test then
        return ISWorldObjectContextMenu.setTest()
    end

    local displayName = entity:getEntityDisplayName()
    if (not displayName) or displayName == GameEntity.getDefaultEntityDisplayName() then
        displayName = getText("Entity_Open_Window")
    end

    context:addOption(displayName, entity, onOpen, playerObj)
    return true
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
