--Special thanks to AuthenticPeach for his mod AuthenticZ specificaly in file AuthenticZ_Glowstick.lua was very usefull to do this!
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Hello there! I know SW fans are very smart so I do know someone will read this, if you're planning to make an adjustment to the mod, please, contact with me first (ESuances) as if you do find ways to
-- make this mod better, I will gladly add you in the workshop as a contributor to it, if you upload a different version it will make people not know which one to install
-- To do so, you can find me in most of PZ official servers on discord, or on my own https://discord.gg/xykfphXyN4
-- Plus, my comments are in spanish, if you don't understand them, you might not know what something does and run into errors
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local lightByPlayer = {}

local ColorDeLuzData = {}
ColorDeLuzData["anakin_on"] = { 0.0, 0.0, 1.0 }
ColorDeLuzData["kenobi_on"] = { 0.0, 0.0, 1.0 }
ColorDeLuzData["darthvader_on"] = {1.0, 0.0, 0.0}
ColorDeLuzData["dooku_on"] = {1.0, 0.0, 0.0}
ColorDeLuzData["kylo_on"] = {1.0, 0.0, 0.0}
ColorDeLuzData["luke_on"] = {0.0, 1.0, 0.0}
ColorDeLuzData["mace_on"] = { 1.0, 0.0, 1.0 }

local function luz(player, item)
	local color = ColorDeLuzData[item:getType()] -- Guardamos los 3 valores de rgb en la variable color dependiendo del item que se de
	lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4) -- Creamos la luz y se la asignamos a la tabla y al jugador para poder manipularla mas adelante
	getCell():addLamppost(lightByPlayer[player]) -- Agregamos la luz al juego con el color y parametros asignados
end

local function LightSaberGlow(player)
	local ListaDeSablesOn = {} -- Creamos un arreglo para guardar nueva lista de sables que si generan luz
	local item = player:getPrimaryHandItem()

	if not item then -- Nos aseguramos de que si el jugador no tiene items en las manos, eliminamos la luz, seleccionando la luz exacta que queremos eliminar
		if lightByPlayer[player] ~= nil then
			getCell():removeLamppost(lightByPlayer[player])
		end
		return -- y terminamos la funcion para que no se produzca ninguna luz
	end

	if ColorDeLuzData[item:getType()] ~= nil then -- Obtenemos los nombres de los items que tienen color asignado
		table.insert(ListaDeSablesOn, item) -- Si el item que el jugador tiene en las manos esta dentro de la tabla de ColorDeLuzData, lo insertamos tambien en ListaDeSablesOn como referenica
	end

	if lightByPlayer[player] ~= nil then -- Comprobamos que no exista luz antes creada por algun jugador en esta tabla
		getCell():removeLamppost(lightByPlayer[player]) -- Si alguna si fue creada antes (De los sables de luz) la eliminamos
	end -- Si no, se sigue al siguiente paso, asi evitamos el error que se originaba al prender el sable por primera vez

	--local siono = player:isReading() -- Esta funcion la iba a usar para ver si el jugador estaba leyendo, no lo intente mucho para ponerle que dijera algo, quizas lo intento despues

	for i, item in ipairs(ListaDeSablesOn) do -- Mientras que item este dentro de ListaDeSablesOn
		if item == player:getPrimaryHandItem() then -- Y si es que ese item lo tiene el jugador en la mano principal
			luz(player, item) -- Creamos luz con la primera funcion
			item:setBloodLevel(0.0) -- Nos aseguramos de que no tenga manchas de sangre el sable de luz, pero aun tiene una mancha extraña arriba en los sables al matar
			--player:playSound("SaberHum") -- Agregamos sonido de Hum cuando esta encendido un sable de luz (Lo termine quitando porque mas que ser algo bueno, terminaba siendo muy molesto)
		end
	end
end

local function LightSaberUpdate(key)
	if (key == getCore():getKey("Ignite_LS")) then
		local player
		for i=0,getNumActivePlayers() -1 do
			player = getSpecificPlayer(i)
		end
		local item = player:getPrimaryHandItem()
		if not item then return end

		local condicionActual
		local newitem

		if item:getType() == "anakin_off" then
			player:playSound("AnakinIgnition")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.anakin_on")
		    condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
		    player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "anakin_on" then
			player:playSound("AnakinToff")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.anakin_off")
			condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
			getCell():removeLamppost(lightByPlayer[player])
			player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "darthvader_off" then
			player:playSound("DarthIgnition")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.darthvader_on")
		    condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
		    player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "darthvader_on" then
			player:playSound("DarthToff")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.darthvader_off")
			condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
			getCell():removeLamppost(lightByPlayer[player])
			player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "dooku_off" then
			player:playSound("DarthIgnition")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.dooku_on")
		    condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
		    player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "dooku_on" then
			player:playSound("DarthToff")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.dooku_off")
			condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
			getCell():removeLamppost(lightByPlayer[player])
			player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "kenobi_off" then
			player:playSound("LukeIgnition")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.kenobi_on")
		    condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
		    player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "kenobi_on" then
			player:playSound("LukeToff")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.kenobi_off")
			condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
			getCell():removeLamppost(lightByPlayer[player])
			player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "luke_off" then -- Primero la opcion de que se tenga la version de arma de fuego
			player:playSound("LukeIgnition")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.luke_on")
		    condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
		    player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "luke_on" then
			player:playSound("LukeToff")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.luke_off")
			condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
			getCell():removeLamppost(lightByPlayer[player])
			player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "kylo_off" then
			player:playSound("KyloIgnition")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.kylo_on")
		    condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
			player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "kylo_on" then
			player:playSound("DarthToff")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.kylo_off")
			condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
			getCell():removeLamppost(lightByPlayer[player])
			player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "mace_off" then
			player:playSound("LukeIgnition")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.mace_on")
		    condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
		    player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
		if item:getType() == "mace_on" then
			player:playSound("LukeToff")
			local inventory = player:getInventory()
			newitem = inventory:AddItem("Mexiox_sw.mace_off")
			condicionActual = item:getCondition()
			newitem:setCondition(condicionActual)
			getCell():removeLamppost(lightByPlayer[player])
			player:setPrimaryHandItem(newitem)
		    inventory:Remove(item)
			LScheckHotbar(item,newitem)
		end
	end
end

function LScheckHotbar(prev_weapon, result)
	local Hotbar = getPlayerHotbar(0)
	if Hotbar ~= nil then
		local W_slot = prev_weapon:getAttachedSlot()
		local slot = Hotbar.availableSlot[W_slot]
		if (slot) and (result) and (not Hotbar:isInHotbar(result)) and (Hotbar:canBeAttached(slot, result)) then
			Hotbar:removeItem(prev_weapon, false)
			Hotbar:attachItem(result, slot.def.attachments[result:getAttachmentType()], W_slot, slot.def, false)
		end
	else	DebugSay (3,"Hotbar - N/A")
	end
end

Events.OnPlayerUpdate.Add(LightSaberGlow);
Events.OnKeyStartPressed.Add(LightSaberUpdate);

--[[
NOTAS:
Agregar al hacer el cambio de regreso a el hotbar cuando se vuelve a transformar en apagado
Intentar guardar en una variable el slot especifico en donde se encontraba el item y guardarlo
entonces al hacer el cambio, guardarlo ahi, intentar usar una variable global si no encuentro forma dentro
de la funcion
Machetes crafteables, que tengas que tener electricidad nivel 8, madera, mucho cable, componentes electronicos
una linterna de las poderosas y una gema en especifico (que podran aparecer en joyerias del mundo o rebuscando)
Ademas de tener que encontrar una revista que te muestre los crafteos (Que esta revista sea algo comun, una que se publico como de geeks pero que muestra los crafteos)
Y que cuando la termine de leer, el personaje diga algo como "hello there"
--]]

--[[
Futuras actualizaciones posibles:
Posibilidad de usar dos sables de luz al mismo tiempo y que ambos emitan luz
Posibilidad de que suene el sable de luz el mmmmm cuando esta encendido
--]]

-------------------------------------------------------------------------------------------------------------------------------------------------
--The code below is stuff that didnt work or did work for a while but I found a better solution to it, in any case, might be useful in the future
-------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- The closest thing I got to working with hotbar correctly so that when the player tries to place a turned on light saber in his hotbar
-- it would shut down as the player puts it in the hotbar, but I coulndt find a way to make isAttachedItem() to work in order to let the program know when to do the magic

--[[local condicionActual
	local newitem
	local hotbar = getPlayerHotbar(player:getPlayerNum());
	local inventory = player:getInventory():getItems()
	if not inventory then return end
	if hotbar == nil then return end
	hotbar.needsRefresh = true
	local _item
	for i=0,inventory:size()-1 do
		_item = inventory:get(i)
		print(_item:getType())
		print(player:isAttachedItem(_item))
		--if _item:getType() == "anakin_on" --[[and item:getType() ~= "anakin_on" and player:isAttachedItem(_item) == true then
			if _item:getType() == "anakin_on" and player:isAttachedItem(_item) == true then
				local W_slot = _item:getAttachedSlot()
				local slot = hotbar.availableSlot[W_slot]
				player:playSound("AnakinToff")
				local _inventory = player:getInventory()
				newitem = _inventory:AddItem("Mexiox_ls.anakin_off")
				condicionActual = _item:getCondition()
				newitem:setCondition(condicionActual)
				_inventory:Remove(_item) -- con esto comentado me dejaba el sable en la mano pero me aparecia uno nuevo apagado en el hotbar
				hotbar:removeItem(newitem, true)
				if player:isAttachedItem(_item) == true then
					hotbar:attachItem(newitem, slot.def.attachments[newitem:getAttachmentType()], W_slot, slot.def, false)
				end
			end -- idea, el sable apagado que aparece en el inventario, desparecerlo despues de esto, a ver si funciona
		--end
	end

	--hotbar:isInHotbar(_item) and
	--]]

--And I tried using this as a function itself but it would not work, only if I placed it with the LightSaberUpdate did
--------------------------------------------------------------------------

--[[local hotbar = getPlayerHotbar(0)
	local inv = player:getInventory():getItems()

	if hotbar ~= nil then
		local item = inv:get(i-1)
		if hotbar:isInHotbar(item) and item:getAttachmentType() and item:getAttachedSlot() ~= -1 then
			if ColorDeLuzData[item:getType()] ~= nil then
				local newitem
				local condicionActual
				if item:getType() == "anakin_on" then
					newitem = inv:AddItem("Mexiox_ls.anakin_off")
					condicionActual = item:getCondition()
					newitem:setCondition(condicionActual)
					local spot = item:getAttachedSlot()
					local slot = hotbar.availableSlot[spot]
					if (slot) and (newitem) and (not hotbar:isInHotbar(newitem)) and (hotbar:canBeAttached(slot, newitem)) then
						hotbar:removeItem(item, false)
						hotbar:attachItem(newitem, slot.def.attachments[newitem:getAttachmentType()], spot, slot.def, false)
					end
					inv:Remove(item)
				end
			end
		end
	else
		return
	end--]]


--[[for i=0,inventory:size()-1 do
		_item = inventory:get(i)
		print(_item:getType())
		print(player:isAttachedItem(_item))
		--if _item:getType() == "anakin_on" and item:getType() ~= "anakin_on" and player:isAttachedItem(_item) == true then
			if _item:getType() == "anakin_on" and player:isAttachedItem(_item) == true then
				local W_slot = _item:getAttachedSlot()
				local slot = hotbar.availableSlot[W_slot]
				player:playSound("AnakinToff")
				local _inventory = player:getInventory()
				newitem = _inventory:AddItem("Mexiox_ls.anakin_off")
				condicionActual = _item:getCondition()
				newitem:setCondition(condicionActual)
				--inventory:Remove(_item)
				hotbar:removeItem(_item, false)
				hotbar:attachItem(newitem, slot.def.attachments[newitem:getAttachmentType()], W_slot, slot.def, false)
			end
		--end
	end
--]]



--local ListaDeSablesOn = {"anakin_on","darthvader_on","dooku_on","kenobi_on","luke_on","kylo_on","mace_on","machete_on_rosa","machete_on_amarillo","machete_on_naranja"}
--local ListaDeSablesOff = {"anakin_off","darthvader_off","dooku_off","kenobi_off","luke_off","kylo_off","mace_off","machete_rosa_off","machete_amarillo_off","machete_naranja_off"}
--[[
ListaDeSablesOff["anakin_off"] = {"anakin_off"}
ListaDeSablesOff["darthvader_off"] = {"darthvader_off"}
ListaDeSablesOff["kenobi_off"] = {"kenobi_off"}
ListaDeSablesOff["luke_off"] = {"luke_off"}
ListaDeSablesOff["kylo_off"] = {"kylo_off"}
ListaDeSablesOff["mace_off"] = {"mace_off"}
ListaDeSablesOff["machete_rosa_off"] = {"machete_rosa_off"}
ListaDeSablesOff["machete_amarillo_off"] = {"machete_amarillo_off"}
ListaDeSablesOff["machete_naranja_off"] = {"machete_naranja_off"}
--]]

--[[local function LightSaberGlow(player)
	local item = player:getPrimaryHandItem()
	if not item then return end

	if item:getType() == "anakin_on" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "anakin_on" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
	end

		-- Remove old Lights
	if item:getType() == "darthvader_on" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "darthvader_on" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "dooku_on" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "dooku_on" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "kenobi_on" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "kenobi_on" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "luke_on" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "luke_on" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "kylo_on" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "kylo_on" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "mace_on" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "mace_on" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "machete_on_rosa" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "machete_on_rosa" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "machete_on_amarillo" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "machete_on_amarillo" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "machete_on_naranja" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "machete_on_naranja" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "machete_on_azul" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "machete_on_azul" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "machete_on_morao" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "machete_on_morao" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "machete_on_rojo" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "machete_on_rojo" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end

		-- Remove old Lights
	if item:getType() == "machete_on_verde" then
		getCell():removeLamppost(lightByPlayer[player])
	end

	if item:getType() == "machete_on_verde" then
		local color = ColorDeLuzData[item:getType()]
		lightByPlayer[player] = IsoLightSource.new(player:getX(), player:getY(), player:getZ(), color[1], color[2], color[3], 4)
		getCell():addLamppost(lightByPlayer[player])
		--habialuz = true
	end
end
--]]

--Para hacer el cambio en el hotbar solo tengo que checar que el jugador tenga algun sable encendido en el cinturon

--[[local function LightSaberUpdate(player)
	--[[if Hotbar ~= nil then
		local W_slot = item:getAttachedSlot()
		local slot = Hotbar.availableSlot[W_slot]
		if Hotbar:isInHotbar(item) then
			if ColorDeLuzData[item:getType()] ~= nil then
				local newitem = inventory:AddItem("Mexiox_ls.anakin_off")
				local condicionActual = item:getCondition()
				newitem:setCondition(condicionActual)
				Hotbar:removeItem(item, false)
				Hotbar:attachItem(newitem, slot.def.attachments[newitem:getAttachmentType()], W_slot, slot.def, false)
			end
		end
	else
		DebugSay (3,"Hotbar - N/A")
	end--]]

--[[local function check(saberon, saberoff, inventory, condicion)
	if saberon:getType() == "anakin_on" then
		saberoff = inventory:AddItem("Mexiox_ls.anakin_off")
		condicion = saberoff:setCondition()
		local Hotbar = getPlayerHotbar(0)
		if Hotbar ~= nil then
		local W_slot = saberon:getAttachedSlot()
		local slot = Hotbar.availableSlot[W_slot]
		if (slot) and (saberoff) and (not Hotbar:isInHotbar(saberoff)) and (Hotbar:canBeAttached(slot, saberoff)) then
			Hotbar:removeItem(saberon, false)
			Hotbar:attachItem(saberoff, slot.def.attachments[saberoff:getAttachmentType()], W_slot, slot.def, false)
		end
	else	DebugSay (3,"Hotbar - N/A")
	end
	end
end
--]]