-- DC2 Phase 15: the AutoButterChurn recipe's own -fluid 5.0 [...] mode:mixture
-- input drains the ENTIRE held container in a single completed batch,
-- confirmed by live testing (a 10 L and a 20 L bucket both went to 0 L after
-- exactly one batch) - not the "cap at 5.0" behavior the engine's own
-- CraftRecipeManager.consumeInputFluidInternal appears, on static reading, to
-- implement. Three rounds of static Java tracing this cycle (Phase 14, this
-- phase) failed to correctly predict this component's actual behavior, and
-- CraftRecipeData.luaCallOnTest() turned out to be a stub that never calls
-- custom Lua at all, while OnStart/OnCreate both fire strictly after the
-- engine's own consumeInputs() call - so there is no recipe-level Lua hook
-- available that runs before the drain to read the "true" pre-batch amount.
--
-- Rather than keep depending on that internal accounting, this tracks the
-- milk amount entirely ourselves: snapshotted the moment the player opens
-- the entity's context menu (see ISAutoButterChurnOpenMenu.lua, which is
-- necessarily triggered before the crafting window/Start button are ever
-- reachable), then decremented locally by exactly 5.0 per completed batch,
-- ignoring whatever the engine's own FluidContainer now reports (0, always).
-- The leftover under 5 L is written back into the item's FluidContainer
-- directly once the run stops, since the engine already zeroed it out.

AutoButterChurnCode = {}

AutoButterChurnCode.MILK_PER_BATCH = 5.0
AutoButterChurnCode.pendingMilk = {}
AutoButterChurnCode.pendingItemType = {}

function AutoButterChurnCode.squareKey(square)
    return square:getX() .. "," .. square:getY() .. "," .. square:getZ()
end

function AutoButterChurnCode.snapshotMilk(entity)
    local resourcesComponent = entity:getComponent(ComponentType.Resources)
    if not resourcesComponent then
        return
    end

    local items = resourcesComponent:getResourcesFromGroup("churn_inputs", ArrayList.new(), ResourceIO.Input, ResourceType.Item)
    if items:size() == 0 then
        return
    end

    local resource = items:get(0)
    local item = resource:peekItem()
    local fc = item and item:getFluidContainer()
    local amount = fc and fc:getAmount() or 0.0

    local square = entity:getSquare()
    if not square then
        return
    end

    -- onItemSlotContentsChanged (the caller, via AutoButterChurnItemSlotHook.lua)
    -- fires for ANY change to the slot's contents - including the recipe's own
    -- drain reducing the item's fluid, not just the player adding milk. DC2
    -- Phase 16 confirmed this: the very next contents-changed event after a
    -- correct 10 L snapshot reported 0, overwriting it right before
    -- onBatchComplete could read it. Only accept a snapshot that INCREASES
    -- the tracked amount - a real fill always adds milk; a drain (ours or the
    -- engine's own) only ever removes it, so a same-or-lower reading here is
    -- the drain side effect, not a new fill, and must be ignored.
    local key = AutoButterChurnCode.squareKey(square)
    local existing = AutoButterChurnCode.pendingMilk[key]
    if existing and amount <= existing + 1.0e-5 then
        print("AutoButterChurnCode: ignoring snapshot " .. tostring(amount) .. " (not an increase over tracked " .. tostring(existing) .. ")")
        return
    end

    AutoButterChurnCode.pendingMilk[key] = amount
    if item then
        AutoButterChurnCode.pendingItemType[key] = item:getFullType()
    end
    print("AutoButterChurnCode: snapshotted milk = " .. tostring(amount) .. " at " .. key)
end

-- DC2 Phase 18: CraftRecipeManager.consumeInputItem's removal condition
-- (!input.isKeep() || canMoveItemsToOutput) is an OR where
-- canMoveItemsToOutput comes from Resource.canMoveItemsToOutput() -
-- unconditionally true in the base class, with no override in ResourceItem -
-- so mode:keep alone can never stop the removal; the condition is always
-- true regardless of it. The container is removed from churn_inputs on
-- EVERY completed batch, not just the last - so the auto-continue call to
-- craftLogic:start() would otherwise find an empty input slot and silently
-- fail to start a second batch. Rebuilds the container (with the correct
-- leftover fluid already set) after every batch, not just the final one.
-- DC2 Phase 19: FluidContainer:adjustAmount() (used here previously) is a
-- no-op whenever the container is already empty
-- (zombie42_20_4/entity/components/fluids/FluidContainer.java:706-708,
-- "if (!this.isEmpty()) {...}") - and every container this function touches
-- IS empty at this point, confirmed by Phase 15's own finding that the
-- engine always drains to 0. adjustAmount only ever rescales an EXISTING
-- amount; it cannot set fluid into an empty container. addFluid(type,
-- amount) is the correct call for that. Milk type isn't tracked separately
-- (mode:mixture already treats CowMilk/SheepMilk as interchangeable for this
-- recipe), so CowMilk is used as a reasonable default for any leftover.
local function setFluidAmount(fc, amount)
    if fc and amount > 1.0e-5 then
        fc:addFluid("CowMilk", amount)
    end
end

local function rebuildContainer(itemType, fluidAmount)
    local newItem = instanceItem(itemType)
    if not newItem then
        return nil
    end

    setFluidAmount(newItem:getFluidContainer(), fluidAmount)

    return newItem
end

function AutoButterChurnCode.onBatchComplete(craftRecipeData, character)
    local resource = craftRecipeData and craftRecipeData:getViableResource(0)
    local entity = resource and resource:getGameEntity()
    local square = entity and entity:getSquare()
    if not square then
        print("AutoButterChurnCode: onBatchComplete - no square, cannot track")
        return
    end

    local key = AutoButterChurnCode.squareKey(square)
    local tracked = AutoButterChurnCode.pendingMilk[key]
    local itemType = AutoButterChurnCode.pendingItemType[key]
    print("AutoButterChurnCode: batch complete, locally-tracked milk before this batch = " .. tostring(tracked))

    if not tracked then
        -- No snapshot on record (e.g. the player never right-clicked before
        -- starting somehow) - nothing safe to do here, bail without guessing.
        return
    end

    local afterThisBatch = tracked - AutoButterChurnCode.MILK_PER_BATCH
    local runFinished = afterThisBatch + 1.0e-5 < AutoButterChurnCode.MILK_PER_BATCH

    local item = resource:peekItem()
    if item then
        -- Still in the slot (the removal doesn't always fire - keep this as
        -- the cheap path). Just fix up its fluid level directly.
        setFluidAmount(item:getFluidContainer(), afterThisBatch)
        print("AutoButterChurnCode: container still in slot, set to " .. tostring(afterThisBatch))
    elseif itemType then
        -- Removed by the engine - rebuild it. While the run continues, put
        -- it back in churn_inputs so the next craftLogic:start() has
        -- something to consume; once finished, hand it to the player instead.
        if runFinished then
            local player = entity:getUsingPlayer()
            local newItem = rebuildContainer(itemType, afterThisBatch)
            if newItem and player then
                player:getInventory():AddItem(newItem)
                print("AutoButterChurnCode: container was removed, recreated in " .. tostring(player:getUsername()) .. "'s inventory, leftover = " .. tostring(afterThisBatch))
            else
                print("AutoButterChurnCode: container was removed and could not be returned (newItem=" .. tostring(newItem) .. ", player=" .. tostring(player) .. ")")
            end
        else
            local newItem = rebuildContainer(itemType, afterThisBatch)
            if newItem then
                local list = ArrayList.new()
                list:add(newItem)
                resource:offerItems(list)
                print("AutoButterChurnCode: container was removed, rebuilt into churn_inputs with " .. tostring(afterThisBatch) .. " L for the next batch")
            else
                print("AutoButterChurnCode: container was removed and could not be rebuilt (instanceItem failed for " .. tostring(itemType) .. ")")
            end
        end
    else
        print("AutoButterChurnCode: container missing and no itemType on record - cannot recover it")
    end

    if runFinished then
        AutoButterChurnCode.pendingMilk[key] = nil
        AutoButterChurnCode.pendingItemType[key] = nil
        print("AutoButterChurnCode: run finished")
        return
    end

    AutoButterChurnCode.pendingMilk[key] = afterThisBatch

    local craftLogic = entity:getComponent(ComponentType.DryingCraftLogic)
    local player = entity:getUsingPlayer()
    print("AutoButterChurnCode: " .. tostring(afterThisBatch) .. " L remaining -> continuing (craftLogic=" .. tostring(craftLogic) .. ", player=" .. tostring(player) .. ")")

    if craftLogic and player then
        craftLogic:start(player)
    end
end
