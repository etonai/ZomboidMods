-- HoldAnimals
-- Same as vanilla ISPickupAnimal (media/lua/shared/TimedActions/Animals/ISPickupAnimal.lua)
-- except the picked-up animal item is left in inventory instead of being forced into
-- both hand slots. Since that means it's charged the "unequipped" encumbrance rate
-- instead of vanilla's discounted "equipped" rate, HoldAnimals_WeightUtils pre-applies
-- that discount so the animal's real encumbrance cost matches vanilla instead of
-- inflating (see HoldAnimals_WeightUtils.lua for why).

require "TimedActions/ISBaseTimedAction"
require "HoldAnimals/HoldAnimals_WeightUtils"

ISHoldAnimalPickup = ISBaseTimedAction:derive("ISHoldAnimalPickup")

function ISHoldAnimalPickup:isValid()
	return self.animal:isExistInTheWorld() and self.character:getSquare():DistTo(self.animal:getSquare()) < 3
end

function ISHoldAnimalPickup:waitToStart()
	self.character:faceThisObject(self.animal)
	return self.character:shouldBeTurning()
end

function ISHoldAnimalPickup:update()
	self.character:faceThisObject(self.animal)
end

function ISHoldAnimalPickup:start()
	self.animal:getBehavior():setBlockMovement(true)
	self:setActionAnim("Loot")
	self.character:SetVariable("LootPosition", "Low")
	self.character:reportEvent("EventLootItem")
	self.sound = self.animal:playBreedSound("pick_up")
end

function ISHoldAnimalPickup:stop()
	self.character:stopOrTriggerSound(self.sound)
	self.animal:getBehavior():setBlockMovement(false)
	ISBaseTimedAction.stop(self)
end

function ISHoldAnimalPickup:perform()
	self.character:stopOrTriggerSound(self.sound)
	self.animal:getBehavior():setBlockMovement(false)

	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISHoldAnimalPickup:complete()
	local invItem = instanceItem("Base.Animal")
	invItem:setAnimal(self.animal)
	HoldAnimals.WeightUtils.applyNormalWeight(invItem)
	self.character:getInventory():AddItem(invItem)

	self.character:getAttachedAnimals():remove(self.animal)
	self.animal:getData():setAttachedPlayer(nil)
	self.animal:setWild(false)

	self.animal:removeFromWorld()
	self.animal:removeFromSquare()
	self.animal:setSquare(nil)

	sendPickupAnimal(self.animal, self.character, invItem)

	return true
end

function ISHoldAnimalPickup:getDuration()
	if self.character:isTimedActionInstant() then
		return 1
	end
	return 30
end

function ISHoldAnimalPickup:new(character, animal, remove)
	local o = ISBaseTimedAction.new(self, character)
	o.animal = animal
	o.remove = remove
	o.maxTime = o:getDuration()
	return o
end
