require "TimedActions/ISConvertWasherToChurningMachine"

ChurningMachineCode = ChurningMachineCode or {}

local RUN_MINUTES = 10.0 -- Step 10: full cycle duration.
local RUNNING_SOUND = "ClothingWasherRunning"

ChurningMachineCode.active = ChurningMachineCode.active or {}
ChurningMachineCode.emitters = ChurningMachineCode.emitters or {}
-- DC014 Phase 1: the numeric handle returned by playSoundLoopedImpl, tracked per machine so
-- it can be stopped precisely (mirroring IsoGenerator/AlarmClockClothing's own handle-based
-- tracking) instead of relying only on stopOrTriggerSoundByName.
ChurningMachineCode.soundInstances = ChurningMachineCode.soundInstances or {}

local function machineKey(entity)
    local square = entity:getSquare()
    return string.format("%d_%d_%d", square:getX(), square:getY(), square:getZ())
end

local function isRunning(entity)
    return entity:getModData().churningMachineRunning == true
end

-- DC017 Phase 1 (#13): entity:getContainer() and entity:getItemContainer() are the same
-- underlying field (per doc/ideas/PseudoChurningMachineDC11Plus.md #13's tracing of
-- IsoObject.java) - isPowered() resolves to the same generic grid-power-or-generator check
-- the real washer/dryer's own toggle UI uses (ClothingWasherToggle.lua). Per Ed (2026-09-15):
-- a nearby generator counts, matching isObjectPowered's own includeGenerators=true default.
local function isPowered(entity)
    local container = entity:getContainer()
    return container ~= nil and container:isPowered()
end

-- DC017 Phase 2 (#5, #11, #12): the FluidContainer whitelist was removed entirely (per Ed,
-- 2026-09-15) so any liquid can be poured in, matching idea #11's own title - purity is
-- enforced here in code instead, at cycle completion, rather than at the container's input
-- gate. Cow and sheep milk are combined for purity purposes (Open Design Question 3: a
-- cow+sheep mix counts as pure), matching vanilla's own churn_butter recipe treating them as
-- interchangeable (`-fluid 5.0 [CowMilk;SheepMilk] mode:mixture`).
local MILK_FLUID_TYPES = { "CowMilk", "SheepMilk" }

local function getMilkAmount(fluidContainer)
    local total = 0.0
    for _, fluidType in ipairs(MILK_FLUID_TYPES) do
        local fluid = Fluid.Get(fluidType)
        if fluid then
            total = total + fluidContainer:getSpecificFluidAmount(fluid)
        end
    end
    return total
end

-- Pure means "every drop in the container is cow and/or sheep milk" - not single-fluid-type
-- purity (FluidContainer:isPureFluid only checks one fluid), so this compares combined milk
-- volume against the container's total instead.
local function isPureMilk(fluidContainer)
    local total = fluidContainer:getAmount()
    return total > 0 and getMilkAmount(fluidContainer) >= total - 0.0001
end

local function stopMachine(entity, completedCycle)
    local modData = entity:getModData()
    modData.churningMachineRunning = false
    modData.churningMachineStartHour = nil
    local key = machineKey(entity)
    local emitter = ChurningMachineCode.emitters[key]
    if emitter then
        local soundInstance = ChurningMachineCode.soundInstances[key]
        if soundInstance then
            emitter:stopSound(soundInstance)
        else
            emitter:stopOrTriggerSoundByName(RUNNING_SOUND)
        end
        -- DC014 Phase 1: mirrors IsoGenerator.removeFromWorld() / ItemSoundManager's own
        -- cleanup - since startMachine took manual ownership of this emitter (removing it
        -- from IsoWorld's automatically-ticked pool), it must be handed back explicitly, or
        -- it's neither auto-ticked nor manually ticked by anything ever again.
        IsoWorld.instance:returnOwnershipOfEmitter(emitter)
    end
    ChurningMachineCode.emitters[key] = nil
    ChurningMachineCode.soundInstances[key] = nil
    ChurningMachineCode.active[key] = nil
    if completedCycle then
        local fluidContainer = entity:getFluidContainer()
        -- DC017 Phase 2 (#11, #12): only a 100%-milk container converts. Anything else
        -- present (water, any other non-milk liquid) means the cycle produces no butter and
        -- the container is left completely untouched - no partial extraction, per Ed's
        -- explicit direction (2026-09-15) superseding this idea's original
        -- getSpecificFluidAmount-based partial-extraction design.
        if fluidContainer and isPureMilk(fluidContainer) then
            local removable = math.floor(fluidContainer:getAmount() / 5.0 + 0.0001) * 5.0
            if removable > 0 then
                -- removeFluid removes proportionally across every fluid type present
                -- (FluidContainer.removeFluid, confirmed by re-reading the Java source) - safe
                -- here specifically because isPureMilk already guarantees the container holds
                -- only cow/sheep milk, so a proportional removal can't touch a non-milk fluid.
                fluidContainer:removeFluid(removable, false)
                local itemContainer = entity:getItemContainer()
                if itemContainer then
                    local butterCount = math.floor(removable / 5.0 + 0.0001)
                    for i = 1, butterCount do
                        itemContainer:AddItem("Base.Butter")
                    end
                end
            end
        end
    end
end

local function startMachine(entity, playerObj)
    local modData = entity:getModData()
    modData.churningMachineRunning = true
    modData.churningMachineStartHour = getGameTime():getWorldAgeHours()
    local square = entity:getSquare()
    local key = machineKey(entity)
    -- DC014 Phase 1: take manual ownership instead of setEmitterOwner - mirrors
    -- IsoGenerator/ItemSoundManager's own pattern (a confirmed-working, non-IsoObject
    -- source, per claude_digitalWatchAudioAnalysis.md's left-behind-alarm-watch finding),
    -- rather than the washer's pattern DC11/DC12 already tried and found silent. This
    -- removes the emitter from IsoWorld's automatically-ticked pool - see
    -- checkRunningMachines below for the manual emitter:tick() this now requires.
    local emitter = IsoWorld.instance:getFreeEmitter(square:getX() + 0.5, square:getY() + 0.5, square:getZ())
    IsoWorld.instance:takeOwnershipOfEmitter(emitter)
    local soundInstance = emitter:playSoundLoopedImpl(RUNNING_SOUND)
    -- DC011 Phase 16: vanilla ClothingWasherLogic.updateSound() always sets this FMOD
    -- parameter right after starting the loop (ClothingWasherLogic.java:206) - we never
    -- have. Testing whether the event needs it set to route audio at all.
    emitter:setParameterValueByName(soundInstance, "ClothingWasherLoaded", 1.0)
    ChurningMachineCode.emitters[key] = emitter
    ChurningMachineCode.soundInstances[key] = soundInstance
    ChurningMachineCode.active[key] = entity
end

function ChurningMachineCode.onToggleOption(entity, playerObj)
    if isRunning(entity) then
        stopMachine(entity, false)
        return
    end
    -- DC017 Phase 4: "Turn On" is no longer content-gated - per Ed (2026-09-15), the machine
    -- should always be able to run regardless of what's in it (or whether it's empty). Only
    -- power gates starting it now; purity only ever affects output, in stopMachine below.
    if isPowered(entity) then
        startMachine(entity, playerObj)
    end
end

function ChurningMachineCode.turnOnOffMenu(context, param)
    local option = param.option
    local entity = param.entity
    local playerObj = param.playerObj
    -- DC017 Phase 3 (#10): the Java engine (ISWorldObjectContextMenuLogic.callCustomSubmenu)
    -- creates `option` via a bare context.addOption(textRef, null, null) - an inert top-level
    -- entry with no click action - and hands it to this callback expecting it to be wired up
    -- as a real submenu, exactly like vanilla's own ContextMenuCode.AddDispenserBottle
    -- (media/lua/client/ContextMenuCode.lua) does via ISContextMenu:getNew(context) +
    -- context:addSubMenu(option, subMenu). This code never did that - "Turn On"/"Turn Off"
    -- was being added directly to `context`, making it a separate sibling entry next to the
    -- inert "Churning Machine" entry, instead of nested inside it. That's the extraneous menu
    -- item Ed reported: two entries where there should be one submenu containing the other.
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(option, subMenu)

    -- DC017 Phase 4: "Turn On" no longer gates on container contents at all - per Ed
    -- (2026-09-15), only power (Phase 1) should grey out the option; purity (Phase 2) only
    -- ever affects whether output is produced, in stopMachine.
    local hasPower = isPowered(entity)
    local running = isRunning(entity)
    local label = running and getText("ContextMenu_Turn_Off") or getText("ContextMenu_Turn_On")
    -- addGetUpOption's "target" arg (entity, below) IS forwarded to the callback as the
    -- first parameter (traced through ISContextMenuWrapper.addGetUpOption (Java) ->
    -- ISContextMenu:onGetUpAndThen (Lua) -> ISWaitWhileGettingUp:perform()) - the real
    -- call is onSelect(entity, playerObj), not onSelect(playerObj). Capture entity via
    -- closure (still correct/simpler) but the first param must be accepted and ignored,
    -- not omitted, or the real playerObj silently shifts into the wrong parameter (DC011
    -- Phase 2 diagnostic surfaced this: playerObj:getEmitter() crashed with "tried to call
    -- nil" because "playerObj" was actually receiving entity, which has no getEmitter()).
    local function onSelect(_, pObj)
        ChurningMachineCode.onToggleOption(entity, pObj)
    end
    local subOption = subMenu:addGetUpOption(label, entity, onSelect, playerObj)
    if not running and not hasPower then
        subOption.notAvailable = true
        subOption.toolTip = ISWorldObjectContextMenu.addToolTip()
        subOption.toolTip:setVisible(false)
        subOption.toolTip.description = getText("Tooltip_ChurningMachine_NoPower")
    end
end

-- DC016 Phase 2: replacement-based conversion (idea #8, approach 2 - see
-- doc/ideas/PseudoChurningMachineDC11Plus.md).
-- DC018 Phase 1: recipe changed per Ed (2026-09-17) - Electricity level dropped from 6 to 3,
-- and a consumed Base.ElectronicsScrap added alongside the existing kept-screwdriver
-- requirement. The skill-level check now also gates whether the conversion option appears in
-- the menu at all (see Menu Visibility Change Note, DevCycle018.md) - below level 3 the option
-- is omitted entirely, rather than shown greyed out like the tool/item checks below.
local REQUIRED_ELECTRICITY_LEVEL = 3
local CONVERSION_ITEM_TYPE = "Base.ElectronicsScrap"

local function predicateNotBroken(item)
    return not item:isBroken()
end

local function hasConversionSkill(playerObj)
    return playerObj:getPerkLevel(Perks.Electricity) >= REQUIRED_ELECTRICITY_LEVEL
end

-- Tool/item requirements only - the skill check is handled separately (hasConversionSkill)
-- since it gates menu visibility, not just availability.
local function canConvertWasher(playerObj)
    local inventory = playerObj:getInventory()
    return inventory:containsTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)
        and inventory:containsTypeRecurse(CONVERSION_ITEM_TYPE)
end

local function onSelectConvertWasher(object, playerObj)
    if not hasConversionSkill(playerObj) or not canConvertWasher(playerObj) then
        return
    end
    ISTimedActionQueue.add(ISConvertWasherToChurningMachine:new(playerObj, object))
end

local function onFillWorldObjectContextMenu(playerNum, context, worldobjects, test)
    local playerObj = getSpecificPlayer(playerNum)
    for _, object in ipairs(worldobjects) do
        -- Plain White Washing Machine only - explicitly not IsoCombinationWasherDryer or
        -- IsoClothingDryer, per DC016's scope decision.
        if instanceof(object, "IsoClothingWasher") then
            if test then
                return ISWorldObjectContextMenu.setTest()
            end
            -- DC018 Phase 1: below the skill threshold, the option isn't added at all - per
            -- Ed (2026-09-17), only the tool/item requirements should show as greyed out.
            if hasConversionSkill(playerObj) then
                local option = context:addGetUpOption(getText("ContextMenu_ChurningMachine_Convert"), object, onSelectConvertWasher, playerObj)
                if not canConvertWasher(playerObj) then
                    option.notAvailable = true
                    option.toolTip = ISWorldObjectContextMenu.addToolTip()
                    option.toolTip:setVisible(false)
                    option.toolTip.description = getText("Tooltip_ChurningMachine_RequiresConversion")
                end
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)

local function checkRunningMachines()
    local now = getGameTime():getWorldAgeHours()
    local toStop = {}
    local toInterrupt = {}
    for key, entity in pairs(ChurningMachineCode.active) do
        -- DC017 Phase 1 (#13): losing power mid-cycle is an interrupted cycle, like a manual
        -- Turn Off (no butter, no milk consumed) - per Ed (2026-09-15) - not a completed one,
        -- matching the real washer/dryer's own behavior of simply pausing rather than
        -- finishing a load. Checked first/separately from the time-based stop below, since an
        -- unpowered machine should stop regardless of how much of the cycle has elapsed.
        if not isPowered(entity) then
            table.insert(toInterrupt, entity)
        else
            local modData = entity:getModData()
            local startHour = modData.churningMachineStartHour
            if not startHour or (now - startHour) * 60.0 >= RUN_MINUTES then
                table.insert(toStop, entity)
            end
        end

        -- DC014 Phase 1: mirrors ItemSoundManager.update()'s own per-frame emitter.tick()
        -- call - since startMachine took manual ownership of this emitter (removing it from
        -- IsoWorld's automatically-ticked pool via takeOwnershipOfEmitter), nothing else
        -- will ever tick it unless we do so explicitly, every tick, ourselves.
        local emitter = ChurningMachineCode.emitters[key]
        if emitter then
            emitter:tick()
        end
    end
    for i = 1, #toInterrupt do
        stopMachine(toInterrupt[i], false)
    end
    for i = 1, #toStop do
        stopMachine(toStop[i], true)
    end
end

Events.OnTick.Add(checkRunningMachines)
