-- PseudoTransporter: shared definitions, pair registry, and placement/pick-up hooks.
-- DevCycle 001: single player, one pair (one Control, one Signal Booster).

PseudoTransporter = PseudoTransporter or {}
local PT = PseudoTransporter

PT.MARKER = "PseudoTransporterRole"      -- modData key on world objects and carried items
PT.ROLE_CONTROL = "control"
PT.ROLE_BOOSTER = "booster"
PT.ITEM_ROLES = {
    ["PseudoTransporter.TransporterControl"] = "control",
    ["PseudoTransporter.TransporterSignalBooster"] = "booster",
}
PT.REGISTRY = "PseudoTransporter"

PT.DEBUG = true
local function dbg(msg)
    if PT.DEBUG then print("[PseudoTransporter] " .. tostring(msg)) end
end
PT.dbg = dbg

-- Global ModData: { control = {x,y,z}, booster = {x,y,z} }. Persists with the save.
function PT.getRegistry()
    return ModData.getOrCreate(PT.REGISTRY)
end

function PT.register(role, square)
    if not role or not square then return end
    PT.getRegistry()[role] = { x = square:getX(), y = square:getY(), z = square:getZ() }
    dbg("registered " .. role .. " at " .. square:getX() .. "," .. square:getY() .. "," .. square:getZ())
end

function PT.unregister(role)
    if not role then return end
    PT.getRegistry()[role] = nil
    dbg("unregistered " .. role)
end

function PT.otherRole(role)
    if role == PT.ROLE_CONTROL then return PT.ROLE_BOOSTER end
    if role == PT.ROLE_BOOSTER then return PT.ROLE_CONTROL end
end

-- Role of a placed world object (nil for vanilla cones and radios).
function PT.getObjectRole(obj)
    if obj and obj.hasModData and obj:hasModData() then
        return obj:getModData()[PT.MARKER]
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
        local _, _, object = findArgs(...)
        local role = PT.getObjectRole(object)
        pendingRole = role
        local ok, result = pcall(origPickUp, self, ...)
        pendingRole = nil
        if not ok then error(result, 0) end
        if role then PT.unregister(role) end
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
        if role and square then PT.register(role, square) end
        return result
    end
else
    dbg("WARNING: ISMoveableSpriteProps.placeMoveableInternal not found")
end
