require "Definitions/AttachedWeaponDefinitions"
-- define weapons to be attached to zombies when creating them

AttachedWeaponDefinitions.MexioxLukeLightSaber = {
	chance = 100,
	outfit = {"LukeSkywalkerJedi", "LukeSkywalker"},
	weaponLocation = {"Belt Left"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 0,
	weapons = {
    "Mexiox_sw.luke_off",
	},
}

AttachedWeaponDefinitions.MexioxAnakinLightSaber = {
	chance = 100,
	outfit = {"Anakin"},
	weaponLocation = {"Belt Left"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 0,
	weapons = {
    "Mexiox_sw.anakin_off",
	},
}

AttachedWeaponDefinitions.MexioxSithLightSaber = {
	chance = 100,
	outfit = {"Sith1","Sith2","Anakin"},
	weaponLocation = {"Belt Left"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 0,
	weapons = {
    "Mexiox_sw.darthvader_off",
    "Mexiox_sw.dooku_off",
    "Mexiox_sw.kylo_off",
	},
}

AttachedWeaponDefinitions.MexioxMaceLightSaber = {
	chance = 100,
	outfit = {"Mace"},
	weaponLocation = {"Belt Left"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 0,
	weapons = {
    "Mexiox_sw.mace_off",
	},
}

AttachedWeaponDefinitions.MexioxKenobiLightSaber = {
	chance = 100,
	outfit = {"Kenobi"},
	weaponLocation = {"Belt Left"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 0,
	weapons = {
    "Mexiox_sw.kenobi_off",
	},
}

-- Define some custom weapons attached on some specific outfit, so for example police have way more chance to have guns in holster and not simply a spear in stomach or something

AttachedWeaponDefinitions.attachedWeaponCustomOutfit.LukeSkywalkerJedi = {
	chance = 100;
	maxitem = 1;
	weapons = {
		AttachedWeaponDefinitions.MexioxLukeLightSaber,
	},
}
AttachedWeaponDefinitions.attachedWeaponCustomOutfit.LukeSkywalker = {
	chance = 100;
	maxitem = 1;
	weapons = {
		AttachedWeaponDefinitions.MexioxLukeLightSaber,
	},
}
AttachedWeaponDefinitions.attachedWeaponCustomOutfit.Anakin = {
	chance = 100;
	maxitem = 1;
	weapons = {
		AttachedWeaponDefinitions.MexioxAnakinLightSaber,
	},
}
AttachedWeaponDefinitions.attachedWeaponCustomOutfit.Sith1 = {
	chance = 100;
	maxitem = 1;
	weapons = {
		AttachedWeaponDefinitions.MexioxAnakinLightSaber,
		AttachedWeaponDefinitions.MexioxSithLightSaber,
	},
}
AttachedWeaponDefinitions.attachedWeaponCustomOutfit.Sith2 = {
	chance = 100;
	maxitem = 1;
	weapons = {
		AttachedWeaponDefinitions.MexioxAnakinLightSaber,
		AttachedWeaponDefinitions.MexioxSithLightSaber,
	},
}
AttachedWeaponDefinitions.attachedWeaponCustomOutfit.Mace = {
	chance = 100;
	maxitem = 1;
	weapons = {
		AttachedWeaponDefinitions.MexioxMaceLightSaber,
	},
}
AttachedWeaponDefinitions.attachedWeaponCustomOutfit.Kenobi = {
	chance = 100;
	maxitem = 1;
	weapons = {
		AttachedWeaponDefinitions.MexioxKenobiLightSaber,
	},
}

