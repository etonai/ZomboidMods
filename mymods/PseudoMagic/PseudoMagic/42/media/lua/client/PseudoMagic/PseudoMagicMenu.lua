-- PseudoMagic: inventory context-menu options.
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
}

local DISMISS_TEXT = {}
for _, m in ipairs(MAGIC_ITEMS) do
    DISMISS_TEXT[m.fullType] = "UI_PseudoMagic_DismissMagic" .. m.name
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

local function summonItem(playerObj, fullType)
    local inv = playerObj:getInventory()
    local item = inv:AddItem(fullType)
    if item then
        sendAddItemToContainer(inv, item)
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

local function onFillInventoryObjectContextMenu(playerNum, context, items)
    local playerObj = getSpecificPlayer(playerNum)
    local dismissable, hasRing = scan(items)
    for _, m in ipairs(MAGIC_ITEMS) do
        local item = dismissable[m.fullType]
        if item then
            context:addOption(getText(DISMISS_TEXT[m.fullType]), playerObj, dismissItem, item)
        end
    end
    if hasRing then
        local option = context:addOption(getText("UI_PseudoMagic_Summon"))
        local sub = ISContextMenu:getNew(context)
        context:addSubMenu(option, sub)
        for _, m in ipairs(MAGIC_ITEMS) do
            sub:addOption(getText("UI_PseudoMagic_Summon" .. m.name), playerObj, summonItem, m.fullType)
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)
