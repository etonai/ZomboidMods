--[[
***********************************************************
** PseudonymousEd, the Dev
** Take Saltwater 41.51
***********************************************************
Copyright 2021 PseudonymousEd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

require "TimedActions/ISBaseTimedAction"

PSWTakeSaltwater = ISBaseTimedAction:derive("PSWTakeSaltwater");

function PSWTakeSaltwater:isValid()
	return true;
end

function PSWTakeSaltwater:waitToStart()
	self.character:faceThisObject(self.well)
   return self.character:shouldBeTurning()
end

function PSWTakeSaltwater:update()
	self.character:faceThisObject(self.well)
end

function PSWTakeSaltwater:start()
	self:setActionAnim("Loot")
end

function PSWTakeSaltwater:stop()
	ISBaseTimedAction.stop(self);
end

function PSWTakeSaltwater:perform()

	self.character:getInventory():Remove("Pot");
	self.character:getInventory():AddItem("Pseudonymous.SaltwaterPot");
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function PSWTakeSaltwater:new(character, well)
   local o = {}
   setmetatable(o, self)
   self.__index = self
   o.character = character
   o.well = well
   o.fuelAmount = fuelAmount;
   o.maxTime = 50
   return o;
end
