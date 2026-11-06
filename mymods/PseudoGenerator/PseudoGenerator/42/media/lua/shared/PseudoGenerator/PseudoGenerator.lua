-- PseudoGenerator: shared definitions and helpers.
-- Loaded on both client and server. Contains no game-state changes.

PseudoGenerator = PseudoGenerator or {}
local PG = PseudoGenerator

-- Full type of the Naquadah Generator item (module.item from the item script).
PG.ITEM_TYPE = "PseudoGenerator.NaquadahGenerator"

-- Engine limits (IsoGenerator.getMaxFuel() is 10, condition max is 100).
PG.MAX_FUEL = 10
PG.MAX_CONDITION = 100

-- True when the given IsoGenerator is a Naquadah Generator.
-- IsoGenerator:getGeneratorItemType() resolves the generator's sprite through the
-- sprite->item map built from every item tagged base:generator. The object's
-- modData "generatorFullType" (set from the item when it was created) is a fallback.
function PG.isNaquadah(generator)
    if not generator then return false end
    if generator:getGeneratorItemType() == PG.ITEM_TYPE then return true end
    local modData = generator:getModData()
    return modData ~= nil and modData.generatorFullType == PG.ITEM_TYPE
end
