ChurningMachineCode = ChurningMachineCode or {}

local RUN_MINUTES = 10.0 -- Step 10: full cycle duration.
local RUNNING_SOUND = "ClothingWasherRunning"

ChurningMachineCode.active = ChurningMachineCode.active or {}
ChurningMachineCode.emitters = ChurningMachineCode.emitters or {}

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

local function startMachine(entity)
    local modData = entity:getModData()
    modData.churningMachineRunning = true
    modData.churningMachineStartHour = getGameTime():getWorldAgeHours()
    local square = entity:getSquare()
    local key = machineKey(entity)
    local emitter = IsoWorld.instance:getFreeEmitter(square:getX() + 0.5, square:getY() + 0.5, square:getZ())
    IsoWorld.instance:setEmitterOwner(emitter, entity)
    emitter:playSoundLoopedImpl(RUNNING_SOUND)
    ChurningMachineCode.emitters[key] = emitter
    ChurningMachineCode.active[key] = entity
end

function ChurningMachineCode.onToggleOption(entity, playerObj)
    if isRunning(entity) then
        stopMachine(entity, false)
        return
    end
    local fluidContainer = entity:getFluidContainer()
    if fluidContainer and fluidContainer:getAmount() > 0 then
        startMachine(entity)
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
    -- addGetUpOption's "target" arg (entity, below) is only used for walk-adjacency and is
    -- NOT forwarded to the callback (only the trailing params are) - capture entity via
    -- closure instead of relying on it being passed through.
    local function onSelect(pObj)
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

local function checkRunningMachines()
    local now = getGameTime():getWorldAgeHours()
    local toStop = {}
    for key, entity in pairs(ChurningMachineCode.active) do
        local modData = entity:getModData()
        local startHour = modData.churningMachineStartHour
        if not startHour or (now - startHour) * 60.0 >= RUN_MINUTES then
            table.insert(toStop, entity)
        end
    end
    for i = 1, #toStop do
        stopMachine(toStop[i], true)
    end
end

Events.OnTick.Add(checkRunningMachines)
