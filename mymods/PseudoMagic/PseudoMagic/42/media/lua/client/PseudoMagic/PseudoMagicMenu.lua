-- PseudoMagic: inventory context-menu options.
--   Magic Knife / Magic Hammer: "Dismiss Magic <X>" deletes the item.
--   Ring of Summoning: "Summon Hammer" / "Summon Knife" add a magic weapon to the inventory.

local DISMISS_TEXT = {
    ["PseudoMagic.MagicKnife"]  = "UI_PseudoMagic_DismissMagicKnife",
    ["PseudoMagic.MagicHammer"] = "UI_PseudoMagic_DismissMagicHammer",
}

local RING_TYPES = {
    ["PseudoMagic.RingOfSummoningRightMiddleFinger"] = true,
    ["PseudoMagic.RingOfSummoningLeftMiddleFinger"]  = true,
    ["PseudoMagic.RingOfSummoningRightRingFinger"]   = true,
    ["PseudoMagic.RingOfSummoningLeftRingFinger"]    = true,
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
    for fullType, item in pairs(dismissable) do
        context:addOption(getText(DISMISS_TEXT[fullType]), playerObj, dismissItem, item)
    end
    if hasRing then
        context:addOption(getText("UI_PseudoMagic_SummonHammer"), playerObj, summonItem, "PseudoMagic.MagicHammer")
        context:addOption(getText("UI_PseudoMagic_SummonKnife"), playerObj, summonItem, "PseudoMagic.MagicKnife")
    end
end

Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)
