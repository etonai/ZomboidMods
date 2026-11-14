-- PseudoMagic: inventory context-menu options.
require "PseudoMagic/PseudoMagicTeleport"
--   Magic tools/weapons: "Dismiss Magic <X>" deletes the item.
--   Ring of the Mage: "Summon" submenu adds a magic tool/weapon to the inventory.

-- Magic items, in summon-menu order. name is the suffix used by the UI text keys.
local MAGIC_ITEMS = {
    { name = "Hammer",       fullType = "PseudoMagic.MagicHammer" },
    { name = "Knife",        fullType = "PseudoMagic.MagicKnife" },
    { name = "Shovel",       fullType = "PseudoMagic.MagicShovel" },
    { name = "Saw",          fullType = "PseudoMagic.MagicSaw" },
    { name = "Crowbar",      fullType = "PseudoMagic.MagicCrowbar" },
    { name = "Pickaxe",      fullType = "PseudoMagic.MagicPickaxe" },
    { name = "Wrench",       fullType = "PseudoMagic.MagicWrench" },
    { name = "PipeWrench",   fullType = "PseudoMagic.MagicPipeWrench" },
    { name = "Sledgehammer", fullType = "PseudoMagic.MagicSledgehammer" },
    { name = "Jack",         fullType = "PseudoMagic.MagicJack" },
    { name = "TireIron",     fullType = "PseudoMagic.MagicTireIron" },
    { name = "Screwdriver",  fullType = "PseudoMagic.MagicScrewdriver" },
    { name = "WoodAxe",      fullType = "PseudoMagic.MagicWoodAxe" },
    { name = "ShortSword",   fullType = "PseudoMagic.MagicShortSword" },
    -- Light ball is equipped in the secondary hand when summoned.
    { name = "LightBall",    fullType = "PseudoMagic.MagicLightBall", equipSecondary = true },
    -- Robes can be summoned but not dismissed.
    { name = "Robe",         fullType = "PseudoMagic.MagicRobe",     noDismiss = true },
    { name = "WarmRobe",     fullType = "PseudoMagic.MagicWarmRobe", noDismiss = true },
}

local DISMISS_TEXT = {}
for _, m in ipairs(MAGIC_ITEMS) do
    if not m.noDismiss then
        DISMISS_TEXT[m.fullType] = "UI_PseudoMagic_DismissMagic" .. m.name
    end
end

local RING_TYPES = {
    ["PseudoMagic.RingOfTheMageRightMiddleFinger"] = true,
    ["PseudoMagic.RingOfTheMageLeftMiddleFinger"]  = true,
    ["PseudoMagic.RingOfTheMageRightRingFinger"]   = true,
    ["PseudoMagic.RingOfTheMageLeftRingFinger"]    = true,
}

local function dismissItem(playerObj, item)
    local container = item:getContainer()
    if not container then return end
    if playerObj:isEquipped(item) then
        playerObj:removeFromHands(item)
    end
    container:Remove(item)
    sendRemoveItemFromContainer(container, item)
end

local function summonItem(playerObj, entry)
    local inv = playerObj:getInventory()
    local item = inv:AddItem(entry.fullType)
    if item then
        sendAddItemToContainer(inv, item)
        if entry.equipSecondary then
            -- primary = false, twoHands = false: equip in the secondary hand
            ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, item, 50, false, false))
        end
    end
end

-- Inventory menu entries are either items or stack tables ({items = {...}}).
-- Returns the first dismissable item per full type, and whether a ring is present.
local function scan(items)
    local dismissable, hasRing = {}, false
    for _, entry in ipairs(items) do
        local list = type(entry) == "table" and entry.items or { entry }
        for _, item in ipairs(list) do
            if item.getFullType then
                local ft = item:getFullType()
                if DISMISS_TEXT[ft] then
                    if not dismissable[ft] then dismissable[ft] = item end
                elseif RING_TYPES[ft] then
                    hasRing = true
                end
            end
        end
    end
    return dismissable, hasRing
end

-- "Bind Location" and "Teleport" submenus (DevCycle 8). Bound slots show their coordinates; unbound Teleport
-- entries are greyed out with a tooltip.
local function coordsText(e)
    return " (" .. e.x .. ", " .. e.y .. ", " .. getText("UI_PseudoMagic_Floor") .. " " .. e.z .. ")"
end

local function addTeleportMenus(context, playerObj)
    local PMT = PseudoMagicTeleport

    local bindOption = context:addOption(getText("UI_PseudoMagic_BindLocation"))
    local bindSub = ISContextMenu:getNew(context)
    context:addSubMenu(bindOption, bindSub)
    for n = 1, PMT.SLOTS do
        local label = getText("UI_PseudoMagic_BindLocation" .. n)
        local e = PMT.getSlot(playerObj, n)
        if e then label = label .. coordsText(e) end
        bindSub:addOption(label, playerObj, PMT.bind, n)
    end

    local tpOption = context:addOption(getText("UI_PseudoMagic_Teleport"))
    local tpSub = ISContextMenu:getNew(context)
    context:addSubMenu(tpOption, tpSub)
    for n = 1, PMT.SLOTS do
        local label = getText("UI_PseudoMagic_TeleportToLocation" .. n)
        local e = PMT.getSlot(playerObj, n)
        if e then label = label .. coordsText(e) end
        local opt = tpSub:addOption(label, playerObj, PMT.teleport, n)
        if not e then
            opt.notAvailable = true
            local tip = ISWorldObjectContextMenu.addToolTip()
            tip.description = getText("UI_PseudoMagic_LocationNotBound")
            opt.toolTip = tip
        end
    end
end

local function onFillInventoryObjectContextMenu(playerNum, context, items)
    local playerObj = getSpecificPlayer(playerNum)
    local dismissable, hasRing = scan(items)
    for _, m in ipairs(MAGIC_ITEMS) do
        local item = dismissable[m.fullType]
        if item and DISMISS_TEXT[m.fullType] then
            context:addOption(getText(DISMISS_TEXT[m.fullType]), playerObj, dismissItem, item)
        end
    end
    if hasRing then
        local option = context:addOption(getText("UI_PseudoMagic_Summon"))
        local sub = ISContextMenu:getNew(context)
        context:addSubMenu(option, sub)
        for _, m in ipairs(MAGIC_ITEMS) do
            sub:addOption(getText("UI_PseudoMagic_Summon" .. m.name), playerObj, summonItem, m)
        end
        addTeleportMenus(context, playerObj)
    end
end

Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)
