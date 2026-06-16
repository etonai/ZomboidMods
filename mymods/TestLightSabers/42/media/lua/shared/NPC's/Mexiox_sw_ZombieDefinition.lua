
require 'NPCs/ZombiesZoneDefinition'

-- Code to add sandbox settings for spawnchances

local function HazloOtravez() --Lo hace epicamente
	local LukeSkywalkerJedi_Spawnrate = SandboxVars.Mexiox_sw.LukeSkywalkerJedi_Chance;
	local Kenobi_Spawnrate = SandboxVars.Mexiox_sw.Kenobi_Chance;
	local Anakin_Spawnrate = SandboxVars.Mexiox_sw.Anakin_Chance;
	local Sith1_Spawnrate = SandboxVars.Mexiox_sw.Sith1_Chance;
	local Sith2_Spawnrate = SandboxVars.Mexiox_sw.Sith2_Chance;
	local Mace_Spawnrate = SandboxVars.Mexiox_sw.Mace_Chance;
	local LukeSkywalker_Spawnrate = SandboxVars.Mexiox_sw.LukeSkywalker_Chance;

	table.insert(ZombiesZoneDefinition.Default,{name = "LukeSkywalkerJedi", chance = LukeSkywalkerJedi_Spawnrate});

	table.insert(ZombiesZoneDefinition.Default,{name = "Kenobi", chance = Kenobi_Spawnrate});

	table.insert(ZombiesZoneDefinition.Default,{name = "Anakin", chance = Anakin_Spawnrate});

	table.insert(ZombiesZoneDefinition.Default,{name = "Sith1", chance = Sith1_Spawnrate});

	table.insert(ZombiesZoneDefinition.Default,{name = "Sith2", chance = Sith2_Spawnrate});

	table.insert(ZombiesZoneDefinition.Default,{name = "Mace", chance = Mace_Spawnrate});

	table.insert(ZombiesZoneDefinition.Default,{name = "LukeSkywalker", chance = LukeSkywalker_Spawnrate});

end
Events.OnPostDistributionMerge.Add(HazloOtravez);