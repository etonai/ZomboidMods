-- DC2 Phase 16: AutoButterChurnCode.snapshotMilk() was being called on
-- right-click (ISAutoButterChurnOpenMenu.lua), but that happens BEFORE the
-- player can even open the window and drag a milk container into the input
-- slot - confirmed by live testing, the snapshot always read 0 because
-- nothing had been placed yet at that point. The correct moment to snapshot
-- is when the item slot's contents actually change, which the generic
-- entity-crafting-window code already reports via
-- ISWidgetCraftLogicInputControl:onItemSlotContentsChanged (fired for every
-- CraftLogic-family entity, not just this one). Wrapping it here rather than
-- forking the vanilla file, filtering to only this mod's entity inside.

require "AutoButterChurnCode"
require "Entity/ISUI/Components/Crafting/ISWidgetCraftLogicInputControl"

local ENTITY_SCRIPT = "Pseudonymous.AutoButterChurn"

local function isOurEntity(entity)
    return entity ~= nil
        and instanceof(entity, "IsoThumpable")
        and entity:getEntityScript() ~= nil
        and entity:getEntityScript():getFullName() == ENTITY_SCRIPT
end

local originalOnItemSlotContentsChanged = ISWidgetCraftLogicInputControl.onItemSlotContentsChanged

function ISWidgetCraftLogicInputControl:onItemSlotContentsChanged(_itemSlot)
    if isOurEntity(self.entity) then
        print("AutoButterChurnCode: item slot contents changed, re-snapshotting")
        AutoButterChurnCode.snapshotMilk(self.entity)
    end

    originalOnItemSlotContentsChanged(self, _itemSlot)
end
