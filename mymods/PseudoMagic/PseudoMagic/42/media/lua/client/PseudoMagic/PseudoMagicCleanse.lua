-- PseudoMagic: Ring of the Mage "Cleanse" (DevCycle 15). Removes all blood and dirt from the character's body
-- and from every worn or carried clothing item, container and weapon (including items inside bags), and leaves
-- the character and clothes dry. Worn makeup is left on. Single-player: no network sync is done.
-- Mirrors what the vanilla ISWashYourself / ISWashClothing actions write (see doc/ideas/RingAutoCleanAnalysis.md),
-- without water, soap or a timed action, and without the vanilla "clothing becomes wet" side effect.

PseudoMagicCleanse = PseudoMagicCleanse or {}

local function bloodPartCount()
    return BloodBodyPartType.MAX:index()
end

-- Body: blood and dirt on every body part.
local function cleanBody(playerObj)
    local visual = playerObj:getHumanVisual()
    for i = 1, bloodPartCount() do
        local part = BloodBodyPartType.FromIndex(i - 1)
        visual:setBlood(part, 0)
        visual:setDirt(part, 0)
    end
end

-- Clothing and containers: blood and dirt on every part the item covers.
local function cleanItemParts(item)
    local covered = BloodClothingType.getCoveredParts(item:getBloodClothingType())
    if not covered then return end
    for j = 0, covered:size() - 1 do
        local part = covered:get(j)
        item:setBlood(part, 0)
        item:setDirt(part, 0)
    end
end

local function cleanClothing(item)
    cleanItemParts(item)
    item:setDirtiness(0)
    item:setBloodLevel(0)
    item:setWetness(0) -- not wet afterward
end

local function cleanContainer(item)
    cleanItemParts(item)
    item:setBloodLevel(0)
end

local function cleanWeapon(item)
    item:setBloodLevel(0)
end

-- Dry the character: every body part, and the overall wetness stat.
local function dryBody(playerObj)
    local parts = playerObj:getBodyDamage():getBodyParts()
    for i = 0, parts:size() - 1 do
        parts:get(i):setWetness(0)
    end
    playerObj:getStats():set(CharacterStat.WETNESS, CharacterStat.WETNESS:getMinimumValue())
end

local function cleanCategory(inv, category, cleanFn)
    local list = inv:getAllCategoryRecurse(category, ArrayList.new())
    for i = 0, list:size() - 1 do
        cleanFn(list:get(i))
    end
end

function PseudoMagicCleanse.cleanse(playerObj)
    if not playerObj then return end
    local inv = playerObj:getInventory()

    cleanBody(playerObj)
    cleanCategory(inv, "Clothing", cleanClothing)
    cleanCategory(inv, "Container", cleanContainer)
    cleanCategory(inv, "Weapon", cleanWeapon)
    dryBody(playerObj)

    -- refresh the model and equipped items, as ISWashClothing does
    playerObj:resetModel()
    playerObj:updateHandEquips()
    triggerEvent("OnClothingUpdated", playerObj)
end
