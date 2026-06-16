--[[
***********************************************************
** PseudonymousEd, the Dev
** Pseudonymous Saltwater Wells - Build 42
***********************************************************
Copyright 2021 PseudonymousEd
Updated 2025 for Build 42 compatibility

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

PSW = {};

PSW.testcontextmenu = function(_player, context, worldobjects)
    local player = getSpecificPlayer(_player);

	print("PseudoEd PSW pot salt menu")

	local parts = tonumber(player:getInventory():getItemCount("Base.Pot", true));
	if parts > 0 then
		local thisObject = worldobjects[1];

		local thisModData = thisObject:getModData()

		local thisSprite = thisObject:getSprite()
		if thisSprite then
			local spriteName = thisObject:getSprite():getName()

			if spriteName ~= nil and spriteName == "pseudoed_01_6" then

				local contextMenu = "ContextMenu_FillCookingPot"
				context:addOption(getText(contextMenu),
								  worldobjects,
								  PSW.onTakeSaltwater,
								  player,
								  thisObject);
			end
		end
	end
end

PSW.saltkettlecontextmenu = function(_player, context, worldobjects)
    local player = getSpecificPlayer(_player);

	print("PseudoEd PSW Kettle salt menu")
	local parts = tonumber(player:getInventory():getItemCount("Base.Kettle", true));
	if parts > 0 then
		local thisObject = worldobjects[1];

		local thisModData = thisObject:getModData()

		local thisSprite = thisObject:getSprite()
		if thisSprite then
			local spriteName = thisObject:getSprite():getName()

			if spriteName ~= nil and spriteName == "pseudoed_01_6" then

				local contextMenu = "ContextMenu_FillKettle"
				context:addOption(getText(contextMenu),
								  worldobjects,
								  PSW.onTakeSaltwaterKettle,
								  player,
								  thisObject);
			end
		end
	end
end

PSW.onTakeSaltwater = function(worldobjects, player, thisObject)
	if luautils.walkAdj(player, thisObject:getSquare()) then
		ISTimedActionQueue.add(PSWTakeSaltwater:new(player,thisObject));
	end
end

PSW.onTakeSaltwaterKettle = function(worldobjects, player, thisObject)
	if luautils.walkAdj(player, thisObject:getSquare()) then
		ISTimedActionQueue.add(PSWTakeSaltwaterKettle:new(player,thisObject));
	end
end


Events.OnPreFillWorldObjectContextMenu.Add(PSW.testcontextmenu);
Events.OnPreFillWorldObjectContextMenu.Add(PSW.saltkettlecontextmenu);
