-- PseudoTransporter: shared definitions, pair registry, and placement/pick-up hooks.
-- DevCycle 001: single player, one pair (one Control, one Signal Booster).

PseudoTransporter = PseudoTransporter or {}
local PT = PseudoTransporter

PT.MARKER = "PseudoTransporterRole"      -- modData key on world objects and carried items
PT.ROLE_CONTROL = "control"
PT.BOOSTER_ROLES = { "booster1", "booster2", "booster3" }
PT.ITEM_ROLES = {
    ["PseudoTransporter.TransporterControl"] = "control",
    ["PseudoTransporter.TransporterSignalBooster"] = "booster1",
    ["PseudoTransporter.TransporterSignalBooster2"] = "booster2",
    ["PseudoTransporter.TransporterSignalBooster3"] = "booster3",
}
-- DevCycle 001 used the single role "booster"; it is now Signal Booster #1.
PT.LEGACY_ROLES = { booster = "booster1" }

function PT.isBoosterRole(role)
    for _, r in ipairs(PT.BOOSTER_ROLES) do
        if r == role then return true end
    end
    return false
end
PT.REGISTRY = "PseudoTransporter"

PT.DEBUG = true
local function dbg(msg)
    if PT.DEBUG then print("[PseudoTransporter] " .. tostring(msg)) end
end
PT.dbg = dbg

-- Global ModData: { control = {x,y,z}, booster = {x,y,z} }. Persists with the save.
function PT.getRegistry()
    local reg = ModData.getOrCreate(PT.REGISTRY)
    if reg.booster ~= nil then          -- migrate a DevCycle 001 save
        reg.booster1 = reg.booster1 or reg.booster
        reg.booster = nil
    end
    return reg
end

function PT.register(role, square)
    if not role or not square then return end
    PT.getRegistry()[role] = { x = square:getX(), y = square:getY(), z = square:getZ() }
    dbg("registered " .. role .. " at " .. square:getX() .. "," .. square:getY() .. "," .. square:getZ())
end

-- When a square is given, the entry is cleared only if it still points at that square
-- (an older duplicate of a role must not clear the newer one's entry).
function PT.unregister(role, square)
    if not role then return end
    local reg = PT.getRegistry()
    local e = reg[role]
    if e and square and (e.x ~= square:getX() or e.y ~= square:getY() or e.z ~= square:getZ()) then
        dbg("not unregistering " .. role .. ": entry is elsewhere")
        return
    end
    reg[role] = nil
    dbg("unregistered " .. role)
end

-- Role of a placed world object (nil for vanilla cones and radios).
function PT.getObjectRole(obj)
    if obj and obj.hasModData and obj:hasModData() then
        local role = obj:getModData()[PT.MARKER]
        return PT.LEGACY_ROLES[role] or role
    end
end

-- Finds the marked object of the given role on a loaded square.
function PT.findOnSquare(square, role)
    if not square then return nil end
    local objs = square:getObjects()
    for i = 0, objs:size() - 1 do
        local o = objs:get(i)
        if PT.getObjectRole(o) == role then return o end
    end
end

---------------------------------------------------------------------------
-- Hooks into the vanilla moveable pipeline.
-- Placement copies item modData to the placed object. Pick-up re-creates the
-- item from the sprite (a vanilla item), so the marker is re-applied to it.
---------------------------------------------------------------------------
local pendingRole = nil

-- The installed game's argument order for these functions may differ from the
-- decompiled 42.20.4 Lua, so arguments are found by type, not by position.
local function findArgs(...)
    local square, item, object
    for i = 1, select("#", ...) do
        local a = select(i, ...)
        if type(a) == "userdata" then
            if instanceof(a, "IsoGridSquare") then
                square = square or a
            elseif instanceof(a, "InventoryItem") then
                item = item or a
            elseif instanceof(a, "IsoObject") and not instanceof(a, "IsoGameCharacter") then
                object = object or a
            end
        end
    end
    return square, item, object
end

local origInstanceItem = ISMoveableSpriteProps.instanceItem
if origInstanceItem then
    function ISMoveableSpriteProps:instanceItem(...)
        local item = origInstanceItem(self, ...)
        if item and pendingRole then
            item:getModData()[PT.MARKER] = pendingRole
        end
        return item
    end
else
    dbg("WARNING: ISMoveableSpriteProps.instanceItem not found")
end

local origPickUp = ISMoveableSpriteProps.pickUpMoveableInternal
if origPickUp then
    function ISMoveableSpriteProps:pickUpMoveableInternal(...)
        local square, _, object = findArgs(...)
        local role = PT.getObjectRole(object)
        pendingRole = role
        local ok, result = pcall(origPickUp, self, ...)
        pendingRole = nil
        if not ok then error(result, 0) end
        if role then PT.unregister(role, square) end
        return result
    end
else
    dbg("WARNING: ISMoveableSpriteProps.pickUpMoveableInternal not found")
end

local origPlace = ISMoveableSpriteProps.placeMoveableInternal
if origPlace then
    function ISMoveableSpriteProps:placeMoveableInternal(...)
        local square, item = findArgs(...)
        if item then
            local role = PT.ITEM_ROLES[item:getFullType()]
            if role then item:getModData()[PT.MARKER] = role end
        end
        local result = origPlace(self, ...)
        local role = item and item:hasModData() and item:getModData()[PT.MARKER]
        role = PT.LEGACY_ROLES[role] or role
        if role and square then PT.register(role, square) end
        return result
    end
else
    dbg("WARNING: ISMoveableSpriteProps.placeMoveableInternal not found")
end

---------------------------------------------------------------------------
-- Teleport (shared by the world menus and the Transporter Badge).
---------------------------------------------------------------------------

-- Picks a free square at or next to the destination. Falls back to the raw coordinates
-- when the destination chunk is not loaded.
local function pickArrival(dest)
    local cell = getCell()
    local offsets = { {0,0}, {0,1}, {1,0}, {0,-1}, {-1,0}, {1,1}, {-1,-1}, {1,-1}, {-1,1} }
    for _, o in ipairs(offsets) do
        local sq = cell:getGridSquare(dest.x + o[1], dest.y + o[2], dest.z)
        if sq and sq:isFree(false) then
            return sq:getX() + 0.5, sq:getY() + 0.5, sq:getZ()
        end
    end
    return dest.x + 0.5, dest.y + 0.5, dest.z
end

-- Moves the player next to the registered destination role. Does nothing if that end is
-- not registered; clears a stale entry when its square is loaded but the object is gone.
function PT.transportTo(playerObj, destRole)
    local dest = PT.getRegistry()[destRole]
    if not dest then dbg("no " .. destRole .. " registered; nothing happens") return end

    local sq = getCell():getGridSquare(dest.x, dest.y, dest.z)
    if sq and not PT.findOnSquare(sq, destRole) then
        dbg("stale " .. destRole .. " entry; clearing")
        PT.unregister(destRole)
        return
    end

    local x, y, z = pickArrival(dest)
    dbg("teleport to " .. x .. "," .. y .. "," .. z)
    playerObj:setX(x); playerObj:setY(y); playerObj:setZ(z)
    playerObj:setLastX(x); playerObj:setLastY(y); playerObj:setLastZ(z)
end
