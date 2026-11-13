-- PseudoMagic: Ring of the Mage teleportation (DevCycle 8, single-player first).
-- Seven bindable locations per character, stored in the player's mod data (saved with the character).
-- The move itself uses the approach proven in PseudoTransporter: setX/Y/Z plus setLastX/Y/Z, arriving at the
-- nearest free square around the destination.

PseudoMagicTeleport = PseudoMagicTeleport or {}
local PMT = PseudoMagicTeleport

PMT.SLOTS = 7
local KEY = "PseudoMagicTeleport"

local function validSlot(n)
    return type(n) == "number" and n >= 1 and n <= PMT.SLOTS and n == math.floor(n)
end

local function store(player)
    local md = player:getModData()
    md[KEY] = md[KEY] or {}
    return md[KEY]
end

-- Returns { x, y, z } for the slot, or nil when nothing is bound.
function PMT.getSlot(player, n)
    if not validSlot(n) then return nil end
    local e = store(player)["slot" .. n]
    if e and e.x and e.y and e.z then return e end
    return nil
end

function PMT.clearSlot(player, n)
    if validSlot(n) then store(player)["slot" .. n] = nil end
end

-- Binds the player's current tile. While flying, the floor beneath the player is bound, not the hover height.
function PMT.bind(player, n)
    if not validSlot(n) then return end
    local x, y, z = math.floor(player:getX()), math.floor(player:getY()), math.floor(player:getZ())
    if PseudoMagicFlight and PseudoMagicFlight.isFlying and PseudoMagicFlight.isFlying(player) then
        z = PseudoMagicFlight.groundAt(x, y, player:getZ())
    end
    store(player)["slot" .. n] = { x = x, y = y, z = z }
    HaloTextHelper.addGoodText(player, getText("UI_PseudoMagic_LocationBound", n))
end

-- Same search as PseudoTransporter: the destination tile, then its eight neighbours; centre of the first free
-- loaded square. If no square is loaded (destination chunk not loaded), fall back to the raw coordinates.
local OFFSETS = { {0,0}, {0,1}, {1,0}, {0,-1}, {-1,0}, {1,1}, {-1,-1}, {1,-1}, {-1,1} }

local function pickArrival(dest)
    local cell = getCell()
    for _, o in ipairs(OFFSETS) do
        local sq = cell:getGridSquare(dest.x + o[1], dest.y + o[2], dest.z)
        if sq and sq:isFree(false) then
            return sq:getX() + 0.5, sq:getY() + 0.5, sq:getZ()
        end
    end
    return dest.x + 0.5, dest.y + 0.5, dest.z
end

function PMT.teleport(player, n)
    local dest = PMT.getSlot(player, n)
    if not dest then return end

    if player:getVehicle() then pcall(function() player:ensureNotInVehicle() end) end
    -- Flight holds the height every tick; release it so the player is not pulled back to the old height.
    if PseudoMagicFlight and PseudoMagicFlight.release then PseudoMagicFlight.release(player) end

    local x, y, z = pickArrival(dest)
    player:setX(x); player:setY(y); player:setZ(z)
    player:setLastX(x); player:setLastY(y); player:setLastZ(z)
    HaloTextHelper.addGoodText(player, getText("UI_PseudoMagic_Teleported", n))
end
