-- PseudoMagic: flight, a power of the Ring of the Mage (client, single-player first).
-- While a Ring of the Mage is worn, hold the "up" key to rise and the "down" key to descend; release both
-- to hover. In the air the movement keys move the player at FLY_SPEED tiles per second. On the ground,
-- movement is vanilla.
--
-- Technique (see claudeDocs/claude_KintoUn.md): the game treats a character above the floor as falling and
-- will not walk them, so the height is held by writing setZ + setLastZ every tick (the same trick as vanilla's
-- ISFastTeleportMove debug cheat), and the horizontal position is moved by Lua in small steps with wall checks.
-- All of it runs inside pcall so an error is printed instead of breaking the game.

local FLY_SPEED = 2.0      -- tiles per second in the air (DC 6 started at 1.0; doubled to 2.0 after testing)
local CLIMB_RATE = 1.0     -- floors per second when rising or descending
local GLIDE_RATE = 0.6     -- floors per second when the ring is taken off in the air
local MAX_HEIGHT = 8       -- highest z (floors) the ring can reach
local STEP = 0.2           -- horizontal movement is done in steps of this many tiles so walls are not skipped
local LOW = 0.3            -- at or below this height above the ground, ground collision rules apply
local DT_CAP = 0.1         -- seconds; limits one update's movement after a hitch
local LANDING_EPSILON = 0.02
local RESUME_EPSILON = 0.05
local DEBUG = true         -- prints when the ring is detected as worn or removed; set false once flight is confirmed
local lastRingOn = nil

local RING_TYPES = {
    ["PseudoMagic.RingOfTheMageRightMiddleFinger"] = true,
    ["PseudoMagic.RingOfTheMageLeftMiddleFinger"]  = true,
    ["PseudoMagic.RingOfTheMageRightRingFinger"]   = true,
    ["PseudoMagic.RingOfTheMageLeftRingFinger"]    = true,
}

local held = {}            -- player -> held z (nil = on the ground, the game is in charge)
local pendingResume = {}   -- player -> true until the first update after the player is created (load handling)

-- Key binds (Options > Mods) -----------------------------------------------------------------------------------

local keyUp, keyDown
pcall(function()
    require "PZAPI/ModOptions"
    local options = PZAPI.ModOptions:create("PseudoMagicFlight", "Ring of the Mage")
    keyUp = options:addKeyBind("UpKey", "IGUI_PseudoMagicFlight_UpKey", Keyboard.KEY_PERIOD, "IGUI_PseudoMagicFlight_UpKey_tooltip")
    keyDown = options:addKeyBind("DownKey", "IGUI_PseudoMagicFlight_DownKey", Keyboard.KEY_COMMA, "IGUI_PseudoMagicFlight_DownKey_tooltip")
end)

local function keyOf(opt, default)
    local ok, k = pcall(function() return opt:getValue() end)
    if ok and k and k ~= 0 then return k end
    return default
end

local function isHeld(opt, default)
    return isKeyDown(keyOf(opt, default))
end

-- Helpers ------------------------------------------------------------------------------------------------------

local function wearingRing(player)
    local worn = player:getWornItems()
    if not worn then return false end
    for i = 0, worn:size() - 1 do
        local item = worn:get(i):getItem()
        if item and RING_TYPES[item:getFullType()] then return true end
    end
    return false
end

-- Highest floor at x,y (not above z) that can be stood on; level 0 always counts.
local function groundAt(x, y, z)
    local cell = getCell()
    for k = math.floor(z), 1, -1 do
        local sq = cell:getGridSquare(math.floor(x), math.floor(y), k)
        if sq and sq:TreatAsSolidFloor() then return k end
    end
    return 0
end

local lastDebugLog = 0

local function holdZ(player, z)
    player:setZ(z)
    player:setLastZ(z)
    -- The engine's updateFalling() keeps adding to lastFallSpeed while the character is above the floor. That
    -- value drives the falling animation (isFalling) and the impact speed passed to DoLand, so it must be kept
    -- at zero or long hovers show a falling pose and landings can be fatal (DC 6, Phase 5).
    if DEBUG then
        local now = getTimestampMs and getTimestampMs() or 0
        if now - lastDebugLog >= 1000 then
            lastDebugLog = now
            local ok, v = pcall(function() return player:getLastFallSpeed() end)
            print("[PseudoMagicFlight] z=" .. tostring(z) .. " lastFallSpeed(before reset)=" .. tostring(ok and v or "n/a"))
        end
    end
    pcall(function() player:setFallTime(0) end)
    pcall(function() player:setLastFallSpeed(0) end)
    pcall(function() player:setbFalling(false) end)
end

-- Isometric directions: forward = (-1,-1), backward = (1,1), left = (-1,1), right = (1,-1).
-- Key names are the vanilla keybinding names ("Forward", "Backward", "Left", "Right").
local function keyDir()
    local core = getCore()
    local dx, dy = 0, 0
    if isKeyDown(core:getKey("Forward")) then dx, dy = dx - 1, dy - 1 end
    if isKeyDown(core:getKey("Backward")) then dx, dy = dx + 1, dy + 1 end
    if isKeyDown(core:getKey("Left")) then dx, dy = dx - 1, dy + 1 end
    if isKeyDown(core:getKey("Right")) then dx, dy = dx + 1, dy - 1 end
    local len = math.sqrt(dx * dx + dy * dy)
    if len < 0.001 then return nil end
    return dx / len, dy / len
end

-- Can the player move from one square to the next? "high" = well above the ground, so only walls, windows and
-- doors block (low furniture, fences and cars can be flown over).
local function blocked(from, to, high)
    if from == to then return false end
    if not to then return not high end  -- in the air, a missing square is open air
    if not from then return false end
    if to:isSolid() then return true end
    if high then
        if not from:isBlockedTo(to) then return false end
        return from:isWallTo(to) or from:isWindowTo(to) or from:isDoorTo(to)
    end
    return from:isBlockedTo(to) or not to:isFree(false)
end

local function push(player, dist, dx, dy)
    local cell = getCell()
    local steps = math.max(1, math.ceil(dist / STEP))
    local step = dist / steps
    for _ = 1, steps do
        local x, y, z = player:getX(), player:getY(), player:getZ()
        local nx, ny = x + dx * step, y + dy * step
        local lvl = math.floor(z)
        local high = (z - groundAt(x, y, z)) > LOW
        local from = cell:getGridSquare(math.floor(x), math.floor(y), lvl)
        local to = cell:getGridSquare(math.floor(nx), math.floor(ny), lvl)
        if blocked(from, to, high) then return end
        player:setX(nx)
        player:setY(ny)
    end
end

-- Altitude: rise, descend, hover, glide and land. Returns true while the player is still in the air.
local function altitude(player, ringOn, dt)
    local x, y = player:getX(), player:getY()
    local z = held[player] or player:getZ()
    local up = ringOn and isHeld(keyUp, Keyboard.KEY_PERIOD)
    local down = ringOn and isHeld(keyDown, Keyboard.KEY_COMMA)

    if not held[player] and not up then return false end

    if up then
        local nz = math.min(z + CLIMB_RATE * dt, MAX_HEIGHT)
        local roof = getCell():getGridSquare(math.floor(x), math.floor(y), math.floor(nz))
        if math.floor(nz) > math.floor(z) and roof and roof:TreatAsSolidFloor() then
            nz = z                                  -- a solid floor above: do not pass through it
        end
        z = nz
    elseif down then
        z = z - CLIMB_RATE * dt
    elseif not ringOn then
        z = z - GLIDE_RATE * dt                     -- ring taken off in the air: glide down
    end

    local ground = groundAt(x, y, math.max(z, player:getZ()))
    -- Never "land" while rising: on the first frames of a lift-off the height is within LANDING_EPSILON of the
    -- ground (CLIMB_RATE * dt is about 0.017), which used to reset the player to the ground every frame.
    if not up and z <= ground + LANDING_EPSILON then
        held[player] = nil                          -- landed: the game takes over again
        holdZ(player, ground)
        return false
    end
    held[player] = z
    holdZ(player, z)
    return true
end

local function release(player)
    held[player] = nil
end

-- Main update -------------------------------------------------------------------------------------------------

local function update(player)
    if not player or not player:isLocalPlayer() then return end

    if player:isDead() or player:getVehicle() or player:isKnockedDown() then
        release(player)
        pendingResume[player] = nil
        player:setVariable("PseudoMagicFlying", false)
        return
    end

    local ringOn = wearingRing(player)
    if DEBUG and ringOn ~= lastRingOn then
        lastRingOn = ringOn
        print("[PseudoMagicFlight] ring worn: " .. tostring(ringOn))
    end

    -- Just loaded or created while above the ground with a ring on: resume hovering instead of falling.
    if pendingResume[player] then
        pendingResume[player] = nil
        if ringOn and not held[player] then
            local z = player:getZ()
            if z > groundAt(player:getX(), player:getY(), z) + RESUME_EPSILON then
                held[player] = z
            end
        end
    end

    local dt = math.min(getGameTime():getRealworldSecondsSinceLastUpdate(), DT_CAP)
    local flying = altitude(player, ringOn, dt)
    -- Drives the AnimSet nodes in media/AnimSets/player/*/PseudoMagicFlight*.xml (standing pose while flying).
    player:setVariable("PseudoMagicFlying", flying)
    if not flying or not ringOn or player:isAiming() then return end

    local dx, dy = keyDir()
    if not dx then return end
    player:getForwardDirection():set(dx, dy)
    push(player, FLY_SPEED * dt, dx, dy)
end

Events.OnPlayerUpdate.Add(function(player)
    local ok, err = pcall(update, player)
    if not ok then print("[PseudoMagicFlight] error: " .. tostring(err)) end
end)

-- Re-apply the held height every tick so the engine does not turn the height into a fall.
Events.OnTick.Add(function()
    local ok, err = pcall(function()
        for player, z in pairs(held) do holdZ(player, z) end
    end)
    if not ok then print("[PseudoMagicFlight] error: " .. tostring(err)) end
end)

Events.OnCreatePlayer.Add(function(_, player)
    if player then pendingResume[player] = true end
end)

Events.OnGameStart.Add(function()
    pcall(function() PZAPI.ModOptions:load() end)
end)
