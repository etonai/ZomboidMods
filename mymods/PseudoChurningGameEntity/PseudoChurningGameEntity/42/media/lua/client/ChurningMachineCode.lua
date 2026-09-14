ChurningMachineCode = ChurningMachineCode or {}

local RUN_MINUTES = 10.0 -- Step 10: full cycle duration.
local RUNNING_SOUND = "ClothingWasherRunning"

ChurningMachineCode.active = ChurningMachineCode.active or {}
ChurningMachineCode.emitters = ChurningMachineCode.emitters or {}
-- DC012 Phase 2 DIAGNOSTIC (temporary - remove once the audio bug is isolated): last time
-- each machine's isPlaying() state was logged, so the repeated check below is throttled
-- instead of printing on every single Events.OnTick call.
ChurningMachineCode.lastSoundCheckMs = ChurningMachineCode.lastSoundCheckMs or {}

local function machineKey(entity)
    local square = entity:getSquare()
    return string.format("%d_%d_%d", square:getX(), square:getY(), square:getZ())
end

local function isRunning(entity)
    return entity:getModData().churningMachineRunning == true
end

local function stopMachine(entity, completedCycle)
    local modData = entity:getModData()
    modData.churningMachineRunning = false
    modData.churningMachineStartHour = nil
    local key = machineKey(entity)
    local emitter = ChurningMachineCode.emitters[key]
    if emitter then
        emitter:stopOrTriggerSoundByName(RUNNING_SOUND)
    end
    ChurningMachineCode.emitters[key] = nil
    ChurningMachineCode.active[key] = nil
    ChurningMachineCode.lastSoundCheckMs[key] = nil
    if completedCycle then
        local fluidContainer = entity:getFluidContainer()
        if fluidContainer then
            local removable = math.floor(fluidContainer:getAmount() / 5.0 + 0.0001) * 5.0
            if removable > 0 then
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
    local emitter = IsoWorld.instance:getFreeEmitter(square:getX() + 0.5, square:getY() + 0.5, square:getZ())
    IsoWorld.instance:setEmitterOwner(emitter, entity)
    local soundInstance = emitter:playSoundLoopedImpl(RUNNING_SOUND)
    -- DC011 Phase 16: vanilla ClothingWasherLogic.updateSound() always sets this FMOD
    -- parameter right after starting the loop (ClothingWasherLogic.java:206) - we never
    -- have. Testing whether the event needs it set to route audio at all.
    emitter:setParameterValueByName(soundInstance, "ClothingWasherLoaded", 1.0)
    ChurningMachineCode.emitters[key] = emitter
    ChurningMachineCode.active[key] = entity
    -- DC012 Phase 2 DIAGNOSTIC: reset so checkRunningMachines logs an immediate reading on
    -- the very next tick, then every few seconds after - see checkRunningMachines below.
    ChurningMachineCode.lastSoundCheckMs[key] = nil
end

function ChurningMachineCode.onToggleOption(entity, playerObj)
    if isRunning(entity) then
        stopMachine(entity, false)
        return
    end
    local fluidContainer = entity:getFluidContainer()
    if fluidContainer and fluidContainer:getAmount() > 0 then
        startMachine(entity, playerObj)
    end
end

function ChurningMachineCode.turnOnOffMenu(context, param)
    local option = param.option
    local entity = param.entity
    local playerObj = param.playerObj
    local fluidContainer = entity:getFluidContainer()
    local hasMilk = fluidContainer ~= nil and fluidContainer:getAmount() > 0
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
    local subOption = context:addGetUpOption(label, entity, onSelect, playerObj)
    if not running and not hasMilk then
        subOption.notAvailable = true
        subOption.toolTip = ISWorldObjectContextMenu.addToolTip()
        subOption.toolTip:setVisible(false)
        subOption.toolTip.description = getText("Tooltip_ChurningMachine_NoMilk")
    end
end

-- DC012 Phase 2 DIAGNOSTIC (temporary - remove once the audio bug is isolated): how often,
-- in real milliseconds, to re-log isPlaying() for each running machine.
local SOUND_CHECK_INTERVAL_MS = 5000

local function checkRunningMachines()
    local now = getGameTime():getWorldAgeHours()
    local nowMs = getTimestampMs()
    local toStop = {}
    for key, entity in pairs(ChurningMachineCode.active) do
        local modData = entity:getModData()
        local startHour = modData.churningMachineStartHour
        if not startHour or (now - startHour) * 60.0 >= RUN_MINUTES then
            table.insert(toStop, entity)
        end

        -- DC012 Phase 2 DIAGNOSTIC: unlike DC011 Phase 15 (which only checked isPlaying()
        -- once, immediately after starting the loop), this re-checks repeatedly for the
        -- whole life of the cycle so a mid-cycle drop (e.g. the emitter getting silently
        -- reclaimed) would actually show up in the log instead of going unnoticed.
        local lastCheck = ChurningMachineCode.lastSoundCheckMs[key]
        if not lastCheck or nowMs - lastCheck >= SOUND_CHECK_INTERVAL_MS then
            ChurningMachineCode.lastSoundCheckMs[key] = nowMs
            local emitter = ChurningMachineCode.emitters[key]
            local playing = emitter ~= nil and emitter:isPlaying(RUNNING_SOUND)
            print("ChurningMachineCode DEBUG: [" .. key .. "] isPlaying(" .. RUNNING_SOUND .. ") = " .. tostring(playing))
        end
    end
    for i = 1, #toStop do
        stopMachine(toStop[i], true)
    end
end

Events.OnTick.Add(checkRunningMachines)
