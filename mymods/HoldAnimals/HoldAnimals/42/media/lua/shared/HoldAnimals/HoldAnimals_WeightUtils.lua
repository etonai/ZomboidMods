-- HoldAnimals
-- Vanilla's carried-animal weight (AnimalInventoryItem.initAnimalData(), Java) is
-- baseEncumbrance * animalSize -- a hand-tuned per-species "how awkward is this to carry"
-- constant, not a real mass. It has no relationship to the animal's actual body weight
-- (AnimalData.getWeight(), the kg number shown on the in-world Animal Info panel), and
-- animalSize is scoped per growth stage rather than the whole lifecycle, so a baby-stage
-- animal (e.g. a chick) can already sit at ~90-100% of its stage's size range.
--
-- HoldAnimals ignores baseEncumbrance/animalSize entirely and instead sets carried weight
-- to the animal's real body weight, so a chick that's genuinely ~30g in the Animal Info
-- panel costs ~0.03 encumbrance to carry, not a fixed per-species game-balance number.
-- Unlike Backpack Barnyard, which flattens every animal's weight to a nominal 0.01
-- regardless of species, this keeps a cow meaningfully heavier to carry than a chick --
-- it's just now the animal's true weight driving that difference, not a design constant.

HoldAnimals = HoldAnimals or {}
HoldAnimals.WeightUtils = HoldAnimals.WeightUtils or {}

local WeightUtils = HoldAnimals.WeightUtils

local APPLIED_KEY = "HoldAnimals_NormalWeightApplied"

local function getRealWeight(item)
	local animal = item.getAnimal and item:getAnimal()
	if animal then
		local data = animal.getData and animal:getData()
		if data and data.getWeight then
			return data:getWeight()
		end
	end
	-- Fallback if the animal/body-weight data can't be resolved: fall back to
	-- whatever vanilla already computed (baseEncumbrance * animalSize) rather than guessing.
	return item:getActualWeight()
end

-- Idempotent: safe to call on the same item more than once (e.g. on every OnGameStart)
-- without re-deriving/overwriting an already-set weight. This snapshots the animal's
-- weight at pickup time, same as vanilla's own carry-weight is a one-time snapshot rather
-- than something that keeps updating while the animal is carried.
function WeightUtils.applyNormalWeight(item)
	if not item or not instanceof(item, "AnimalInventoryItem") then return end

	local modData = item:getModData()
	if modData[APPLIED_KEY] then return end

	local weight = getRealWeight(item)
	item:setWeight(weight)
	item:setActualWeight(weight)
	item:setCustomWeight(true)

	modData[APPLIED_KEY] = true
end

local function applyToContainer(container, seen)
	if not container or not container.getItems then return end
	seen = seen or {}
	if seen[container] then return end
	seen[container] = true

	local items = container:getItems()
	if not items then return end

	for i = 0, items:size() - 1 do
		local item = items:get(i)
		WeightUtils.applyNormalWeight(item)
		if item.getInventory and item:getInventory() then
			applyToContainer(item:getInventory(), seen)
		end
	end
end

function WeightUtils.applyToPlayer(playerObj)
	if not playerObj or not playerObj.getInventory then return end

	applyToContainer(playerObj:getInventory())

	local wornItems = playerObj:getWornItems()
	if wornItems then
		for i = 0, wornItems:size() - 1 do
			local worn = wornItems:get(i)
			local item = worn and worn:getItem()
			if item and item.getInventory and item:getInventory() then
				applyToContainer(item:getInventory())
			end
		end
	end
end

local function applyToPlayerIndex(playerIndex, playerObj)
	playerObj = playerObj or (getSpecificPlayer and getSpecificPlayer(playerIndex))
	if playerObj then WeightUtils.applyToPlayer(playerObj) end
end

if Events then
	if Events.OnCreatePlayer then
		Events.OnCreatePlayer.Add(applyToPlayerIndex)
	end
	if Events.OnGameStart then
		Events.OnGameStart.Add(function()
			if getNumActivePlayers and getSpecificPlayer then
				for playerIndex = 0, getNumActivePlayers() - 1 do
					applyToPlayerIndex(playerIndex)
				end
			end
		end)
	end
end
