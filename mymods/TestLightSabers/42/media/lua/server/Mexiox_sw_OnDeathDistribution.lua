-- This code is made by "Afterworlds" and has took from his mod "They Knew"
-- Huge Thanks to the mod Undead Survivor
function LSCheckDrops(zombie)
	if not zombie:getOutfitName() then return false end
	local outfit = tostring(zombie:getOutfitName());
	local inv = zombie:getInventory();

	if outfit == "Mace" then
		if inv:contains("Mexiox_sw.mace_off") == false then
			inv:AddItems("Mexiox_sw.mace_off", 1);
		end
		if 30 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.PurplekyberCrystal", 1);
		end
		if 5 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.revista_machetes", 1);
		end
	end
	
	if outfit == "LukeSkywalkerJedi" then
		if inv:contains("Mexiox_sw.luke_off") == false then
			inv:AddItems("Mexiox_sw.luke_off", 1);
		end
		if 30 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.GreenkyberCrystal", 1);
		end
		if 5 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.revista_machetes", 1);
		end
	end
	
	if outfit == "LukeSkywalker" then
		if inv:contains("Mexiox_sw.luke_off") == false then
			inv:AddItems("Mexiox_sw.luke_off", 1);
		end
		if 30 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.GreenkyberCrystal", 1);
		end
		if 5 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.revista_machetes", 1);
		end
	end
	
	if outfit == "Anakin" then
		if inv:contains("Mexiox_sw.anakin_off") == false then
			inv:AddItems("Mexiox_sw.anakin_off", 1);
		end
		if 5 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.darthvader_off", 1);
		end
		if 30 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.BluekyberCrystal", 1);
		end
		if 5 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.revista_machetes", 1);
		end
	end
	
	if outfit == "Sith1" then
		if inv:contains("Mexiox_sw.darthvader_off") == false and inv:contains("Mexiox_sw.dooku_off") == false and inv:contains("Mexiox_sw.kylo_off") == false then
			inv:AddItems("Mexiox_sw.darthvader_off", 1);
		end
		if 30 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.RedkyberCrystal", 1);
		end
		if 15 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.revista_machetes", 1);
		end
	end
	
	if outfit == "Sith2" then
		if inv:contains("Mexiox_sw.darthvader_off") == false and inv:contains("Mexiox_sw.dooku_off") == false and inv:contains("Mexiox_sw.kylo_off") == false then
			inv:AddItems("Mexiox_sw.kylo_off", 1);
		end
		if 30 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.RedkyberCrystal", 1);
		end
		if 15 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.revista_machetes", 1);
		end
	end

	if outfit == "Kenobi" then
		if inv:contains("Mexiox_sw.kenobi_off") == false then
			inv:AddItems("Mexiox_sw.kenobi_off", 1);
		end
		if 30 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.BluekyberCrystal", 1);
		end
		if 15 >= ZombRand(1, 100) then
			inv:AddItems("Mexiox_sw.revista_machetes", 1);
		end
	end
end

Events.OnZombieDead.Add(LSCheckDrops);
