--***********************************************************
--** PseudoSaltWellB42 Part 4: Location-Based Hole Type
--** ISLocationBasedHole.lua
--***********************************************************
--** Creates saltwater well or plain hole based on location
--***********************************************************

-- ISBuildingObject is loaded automatically by the game
require "SaltwaterLocationDetector"

ISLocationBasedHole = ISBuildingObject:derive("ISLocationBasedHole");

--************************************************************************--
--** ISLocationBasedHole:create
--************************************************************************--
function ISLocationBasedHole:create(x, y, z, north, sprite)
    local cell = getWorld():getCell();
    self.sq = cell:getGridSquare(x, y, z);

    -- Remove any existing objects that can be removed
    for i=0,self.sq:getObjects():size()-1 do
        local object = self.sq:getObjects():get(i);
        if object:getProperties() and object:getProperties():has(IsoFlagType.canBeRemoved) then
            self.sq:transmitRemoveItemFromSquare(object)
            self.sq:RemoveTileObject(object);
            break
        end
    end

    -- Disable erosion for this square
    self.sq:disableErosion();
    local args = { x = self.sq:getX(), y = self.sq:getY(), z = self.sq:getZ() }
    sendServerCommand('erosion', 'disableForSquare', args)

    -- Decide saltwater-vs-plain from the square actually being placed on, not
    -- from wherever the context menu happened to be opened. The drag cursor
    -- can land on a different tile than the one originally right-clicked, so
    -- locking the decision to that original tile caused placement to silently
    -- fail whenever the two didn't match exactly.
    local isSaltwater = SaltwaterLocationDetector.isSaltwaterLocation(x, y);
    local holeSprite;
    local holeName;

    if isSaltwater then
        -- Create saltwater well
        holeSprite = "pseudoed_03_35";
        holeName = "SaltwaterWell";
    else
        -- Create plain hole
        holeSprite = "pseudoed_03_32";
        holeName = "Hole";
    end

    -- Create the hole/well object
    self.javaObject = IsoThumpable.new(cell, self.sq, holeSprite, north, self);
    self.sq:RecalcAllWithNeighbours(true);
    self.javaObject:setName(holeName);
    self.javaObject:setCanBarricade(false);
    self.javaObject:setIsThumpable(false);

    -- Store type in modData
    self.javaObject:getModData()["isSaltwaterWell"] = isSaltwater;

    -- Add to square
    self.sq:AddSpecialObject(self.javaObject);
    self.javaObject:transmitCompleteItemToClients();

    -- Add muscle strain from digging
    if self.character:getPrimaryHandItem() then
        local skill = self.character:getPerkLevel(Perks.Strength)
        local strain = (1 - (skill * 0.05)) * getGameTime():getMultiplier() * 50
        self.character:addCombatMuscleStrain(self.character:getPrimaryHandItem(), 1, strain)
    end
end

--************************************************************************--
--** ISLocationBasedHole:new
--************************************************************************--
function ISLocationBasedHole:new(sprite, equipBothHandItem)
    local o = ISBuildingObject.new(self)
    o:init();
    o:setSprite(sprite);
    o.noNeedHammer = true;
    o.equipBothHandItem = equipBothHandItem;
    o.maxTime = 150;
    o.actionAnim = BuildingHelper.getShovelAnim(equipBothHandItem);
    o.craftingBank = "Shoveling";
    return o;
end

--************************************************************************--
--** ISLocationBasedHole:getHealth
--************************************************************************--
function ISLocationBasedHole:getHealth()
    return 500 + buildUtil.getWoodHealth(self);
end

--************************************************************************--
--** ISLocationBasedHole:render
--************************************************************************--
function ISLocationBasedHole:render(x, y, z, square)
    local floor = square:getFloor();
    if not floor then
        return;
    end

    -- Recompute the sprite per-tile so the ghost reflects whatever square is
    -- currently under the cursor, not the square the menu was opened on.
    local isSaltwater = SaltwaterLocationDetector.isSaltwaterLocation(square:getX(), square:getY());
    local spriteName = isSaltwater and "pseudoed_03_35" or "pseudoed_03_32";
    local sprite = IsoSprite.new()
    sprite:LoadSingleTexture(spriteName)

    -- Check if valid location
    local spriteFree = ISBuildingObject.isValid(self, square) and
                      floor:getTextureName() and
                      (luautils.stringStarts(floor:getTextureName(), "floors_exterior_natural") or
                       luautils.stringStarts(floor:getTextureName(), "blends_natural_01"));

    spriteFree = spriteFree and ISLocationBasedHole.floorCanDig(square);

    -- Render ghost tile (green if valid, red if not)
    if spriteFree and z==0 then
        sprite:RenderGhostTile(x, y, z);
    else
        sprite:RenderGhostTileRed(x, y, z);
    end
end

--************************************************************************--
--** ISLocationBasedHole:isValid
--************************************************************************--
function ISLocationBasedHole:isValid(square)
    -- Must be at ground level
    if square:getZ() > 0 then
        return false
    end

    -- Must have a floor
    local floor = square:getFloor();
    if not ISBuildingObject.isValid(self, square) or not floor then
        return false
    end

    -- Must be natural ground
    local texture = floor:getTextureName();
    if not (luautils.stringStarts(texture, "floors_exterior_natural") or
            luautils.stringStarts(texture, "blends_natural_01")) then
        return false
    end

    -- Check if floor can be dug
    if not ISLocationBasedHole.floorCanDig(square) then
        return false;
    end

    return true
end

--************************************************************************--
--** ISLocationBasedHole.floorCanDig (static method)
--************************************************************************--
function ISLocationBasedHole.floorCanDig(square)
    if (not square) or (not square:getFloor()) then
        return false;
    end

    -- Cannot dig inside rooms
    if square:isInARoom() then
        return false;
    end

    local floor = square:getFloor();

    -- Check if floor has been shoveled and has natural sprites
    local sprites = floor:getModData() and floor:getModData().shovelledSprites;
    if sprites then
        for i=1,#sprites do
            local sprite = sprites[i];
            if luautils.stringStarts(sprite, "floors_exterior_natural") or
               luautils.stringStarts(sprite, "blends_natural_01") then
                return true;
            end
        end
        return false;
    else
        return true;
    end
end

--************************************************************************--
--** ISLocationBasedHole.canDigHere (static method)
--************************************************************************--
function ISLocationBasedHole.canDigHere(worldObjects)
    local squares = {}
    local didSquare = {}
    for _,worldObj in ipairs(worldObjects) do
        if not didSquare[worldObj:getSquare()] then
            table.insert(squares, worldObj:getSquare())
            didSquare[worldObj:getSquare()] = true
        end
    end
    for _,square in ipairs(squares) do
        if square:getZ() > 0 then
            return false
        end
        local floor = square:getFloor()
        if floor and floor:getTextureName() and
                (luautils.stringStarts(floor:getTextureName(), "floors_exterior_natural") or
                luautils.stringStarts(floor:getTextureName(), "blends_natural_01")) then
            return true
        end
    end
    return false
end
