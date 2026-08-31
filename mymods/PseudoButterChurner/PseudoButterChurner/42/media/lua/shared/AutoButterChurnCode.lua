-- Passive milk-to-butter conversion for placed AutoButterChurn entities.
--
-- DevCycle001.md Phase 17 replaced the earlier component CraftLogic /
-- Resources approach entirely: CraftLogic can only ever read fluid inputs
-- from a named Resources fluid entry (its own separate internal container),
-- never from a sibling component FluidContainer directly. Since the whole
-- point of this phase was to give AutoButterChurn the same simple,
-- vanilla "pour a held container's contents in" interaction that troughs,
-- rain collectors, and the Amphora get for free from component
-- FluidContainer (see ISWorldObjectContextMenuLogic.fetch's generic
-- v:hasComponent(ComponentType.FluidContainer) check), the churning logic
-- itself is now hand-rolled here, modeled on the vanilla
-- ClothingWasherLogic pattern: a registry of placed entities, ticked
-- periodically, using elapsed in-game time against GameTime to decide when
-- a batch completes.

AutoButterChurnCode = {}

AutoButterChurnCode.REGISTRY_KEY = "PseudoButterChurnerRegistry"
AutoButterChurnCode.MILK_PER_BATCH = 5.0
AutoButterChurnCode.SECONDS_PER_BATCH = 500
AutoButterChurnCode.ENTITY_SCRIPT = "Pseudonymous.AutoButterChurn"

local function squareKey(x, y, z)
    return x .. "," .. y .. "," .. z
end

function AutoButterChurnCode.registerEntity(square)
    local registry = ModData.getOrCreate(AutoButterChurnCode.REGISTRY_KEY)
    local key = squareKey(square:getX(), square:getY(), square:getZ())
    registry[key] = { x = square:getX(), y = square:getY(), z = square:getZ(), lastUpdate = GameTime.getInstance():getWorldAgeHours() }
end

local function unregisterKey(registry, key)
    registry[key] = nil
end

local function findEntityOnSquare(square)
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if instanceof(obj, "IsoThumpable") and obj:getEntityScript() and obj:getEntityScript():getFullName() == AutoButterChurnCode.ENTITY_SCRIPT then
            return obj
        end
    end
    return nil
end

local function processEntity(entity, square, entry)
    local worldAgeHours = GameTime.getInstance():getWorldAgeHours()
    local elapsedSeconds = (worldAgeHours - entry.lastUpdate) * 3600.0

    if elapsedSeconds < AutoButterChurnCode.SECONDS_PER_BATCH then
        return
    end

    if not square:haveElectricity() then
        entry.lastUpdate = worldAgeHours
        return
    end

    if entity:getFluidAmount() < AutoButterChurnCode.MILK_PER_BATCH then
        entry.lastUpdate = worldAgeHours
        return
    end

    entity:useFluid(AutoButterChurnCode.MILK_PER_BATCH)
    square:AddWorldInventoryItem("Base.Butter", 0, 0, 0)

    entry.lastUpdate = worldAgeHours
end

function AutoButterChurnCode.tick()
    if isClient() then
        return
    end

    local registry = ModData.getOrCreate(AutoButterChurnCode.REGISTRY_KEY)
    local keysToRemove = {}

    for key, entry in pairs(registry) do
        local square = getSquare(entry.x, entry.y, entry.z)
        local entity = square and findEntityOnSquare(square) or nil
        if entity then
            processEntity(entity, square, entry)
        else
            table.insert(keysToRemove, key)
        end
    end

    for _, key in ipairs(keysToRemove) do
        unregisterKey(registry, key)
    end
end

Events.EveryTenMinutes.Add(AutoButterChurnCode.tick)
