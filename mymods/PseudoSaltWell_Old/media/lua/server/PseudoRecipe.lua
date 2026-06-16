function PseudonymousGetSalt(items, result, player)
	--print("PseudoRecipe GetSalt")
	--player:Say("Hi OnCreate GetSalt")
	player:getInventory():AddItem("Base.Salt");
	player:getInventory():AddItem("Base.Salt");
end

function PseudonymousGetSaltFromKettle(items, result, player)
	player:getInventory():AddItem("Base.Salt");
end

function SaltFishFillet_OnTest(items, result, player)
	print("PseudoRecipe TEST GetSalt")
	--player:Say("Hi OnTest GetSalt")
	--if instanceof(sourceItem, "Food") then
    --    return sourceItem:getActualWeight() > 0.6
    --end
    return true

end

function MakeSaltedMeat(items, result, player)
	print("PseudoRecipe CREATE Salted Meat - ENTER")
	--player:Say("Hi OnCreate GetSalt")
    --local meat = nil;
    for i=0,items:size() - 1 do
        --if instanceof(items:get(i), "Food") then
		local meat = items:get(i)
		if meat:getType() == "Chicken" or meat:getType() == "Steak" or meat:getType() == "Smallanimalmeat" or meat:getType() == "Smallbirdmeat" or meat:getType() == "Rabbitmeat" or meat:getType() == "MuttonChop" or meat:getType() == "PorkChop" then
				-- meat = items:get(i);
			print("PseudoRecipe found a Meat")
			
			local hunger = meat:getBaseHunger();
			result:setBaseHunger(hunger);
			result:setHungChange(hunger);
			result:setActualWeight(meat:getActualWeight())
			result:setWeight(result:getActualWeight());
			result:setCustomWeight(true)
			result:setCarbohydrates(meat:getCarbohydrates());
			result:setLipids(meat:getLipids());
			result:setProteins(meat:getProteins());
			result:setCalories(meat:getCalories());
			result:setCooked(meat:isCooked());
			
			print("PseudoRecipe some stats")
			print("weight " .. meat:getActualWeight());
			print("carbs " .. meat:getCarbohydrates());
			print("proteins " .. meat:getProteins());
			print("calories " .. meat:getCalories());
		end
	end
	
	print("PseudoRecipe CREATE Salted Meat - EXIT")
end

function SaltFishFillet_OnCreate(items, result, player)
	print("PseudoRecipe CREATE Fish Fillet - ENTER")
	--player:Say("Hi OnCreate GetSalt")
    local fish = nil;
    for i=0,items:size() - 1 do
        --if instanceof(items:get(i), "FishFillet") then
		fish = items:get(i)
		if fish:getType() == "FishFillet" then
            --fish = items:get(i);
			print("PseudoRecipe found a FishFillet")
			
			local hunger = fish:getBaseHunger();
			result:setBaseHunger(hunger);
			result:setHungChange(hunger);
			result:setActualWeight(fish:getActualWeight())
			result:setWeight(result:getActualWeight());
			result:setCustomWeight(true)
			result:setCarbohydrates(fish:getCarbohydrates());
			result:setLipids(fish:getLipids());
			result:setProteins(fish:getProteins());
			result:setCalories(fish:getCalories());
			result:setCooked(fish:isCooked());
			
			print("PseudoRecipe some stats")
			print("weight " .. fish:getActualWeight());
			print("carbs " .. fish:getCarbohydrates());
			print("proteins " .. fish:getProteins());
			print("calories " .. fish:getCalories());
        end
    end
	print("PseudoRecipe CREATE Fish Fillet - EXIT")
end
