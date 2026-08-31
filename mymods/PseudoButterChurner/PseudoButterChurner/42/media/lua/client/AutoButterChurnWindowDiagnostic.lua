-- TEMPORARY diagnostic, DevCycle002.md Phase 13.
--
-- The right-click "Open" menu option for a scripted entity is only added
-- when ISEntityWindow.CanOpenWindowFor() -> ISEntityUI.HasComponentPanels()
-- returns true (media/lua/client/Context/World/ISContextEntity.lua). With
-- no menu option appearing at all for a freshly-built AutoButterChurn
-- (confirmed not a stale-entity issue - DC2 Phase 13), this prints exactly
-- which check in that chain is failing, instead of guessing again.
--
-- DELETE once the "no interaction menu" bug is confirmed fixed.

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

local function safePrint(label, func)
    local ok, result = pcall(func)
    if ok then
        print("AutoButterChurnWindowDiag: " .. label .. " = " .. tostring(result))
    else
        print("AutoButterChurnWindowDiag: " .. label .. " -> ERROR: " .. tostring(result))
    end
end

local function diagnose(player, entity)
    print("AutoButterChurnWindowDiag: found entity, running checks...")

    safePrint("uiConfig", function() return entity:getComponent(ComponentType.UiConfig) end)
    safePrint("uiConfig:isUiEnabled()", function() return entity:getComponent(ComponentType.UiConfig):isUiEnabled() end)
    safePrint("uiConfig:getEntityStyleName()", function() return entity:getComponent(ComponentType.UiConfig):getEntityStyleName() end)
    safePrint("uiConfig:getEntityUiStyle()", function() return entity:getComponent(ComponentType.UiConfig):getEntityUiStyle() end)
    safePrint("uiStyle:getLuaWindowClass()", function() return entity:getComponent(ComponentType.UiConfig):getEntityUiStyle():getLuaWindowClass() end)

    safePrint("hasComponent(DryingCraftLogic)", function() return entity:hasComponent(ComponentType.DryingCraftLogic) end)
    safePrint("hasComponent(Resources)", function() return entity:hasComponent(ComponentType.Resources) end)
    safePrint("craftLogic:isValid()", function() return entity:getComponent(ComponentType.DryingCraftLogic):isValid() end)

    safePrint("ISEntityUI.GetEntityUiConfig(entity)", function() return ISEntityUI.GetEntityUiConfig(entity) end)
    safePrint("ISEntityUI.GetWindowClass(entity)", function() return ISEntityUI.GetWindowClass(entity) end)
    safePrint("ISEntityUI.HasComponentPanels(player, entity)", function() return ISEntityUI.HasComponentPanels(player, entity) end)
    safePrint("ISEntityUI.CanOpenWindowFor(player, entity)", function() return ISEntityUI.CanOpenWindowFor(player, entity) end)
end

local function onFillWorldObjectContextMenu(player, context, worldobjects, test)
    if test then
        return
    end

    local playerObj = getSpecificPlayer(player)
    if not playerObj then
        return
    end

    local entity = findEntityAmongObjects(worldobjects)
    if entity then
        diagnose(playerObj, entity)
    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
