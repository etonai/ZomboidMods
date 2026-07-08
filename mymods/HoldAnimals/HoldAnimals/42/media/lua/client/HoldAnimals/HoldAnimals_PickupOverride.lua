-- HoldAnimals
-- Vanilla's "Pick Up Animal" option (world context menu and radial menu) both call
-- AnimalContextMenu.onPickupAnimal, which queues vanilla ISPickupAnimal -- that action
-- puts the animal in inventory but then forces it into both hand slots, which is what
-- stops a player from usefully carrying more than one at a time.
--
-- Replacing onPickupAnimal here means every existing vanilla entry point for picking up
-- an animal (world right-click, the animal radial menu) now queues ISHoldAnimalPickup
-- instead, which leaves the item in inventory and never touches the hand slots or weight.
-- No new menu options are added -- this reuses the vanilla ones.

require "ISUI/Animal/ISAnimalContextMenu"
require "TimedActions/Animals/ISHoldAnimalPickup"

AnimalContextMenu.onPickupAnimal = function(animal, chr)
	animal:stopAllMovementNow()
	if luautils.walkAdj(chr, animal:getSquare()) then
		ISTimedActionQueue.add(ISHoldAnimalPickup:new(chr, animal))
	end
end
