--***********************************************************
--** PseudoSaltWellB42 Part 1: Simple Well Dig
--** ISSimpleWell.lua
--***********************************************************
--** Simple well building object - uses temporary grave sprite
--***********************************************************

ISSimpleWell = ISBuildingObject:derive("ISSimpleWell");

--************************************************************************--
--** ISSimpleWell:create
--************************************************************************--
function ISSimpleWell:create(x, y, z, north, sprite)
    local cell = getWorld():getCell();
    self.sq = cell:getGridSquare(x, y, z);

    -- Remove any existing objects that can be removed
    for i=0,self.sq:getObjects():size()-1 do
        local object = self.sq:getObjects():get(i);
        if object:getProperties() and object:getProperties():Is(IsoFlagType.canBeRemoved) then
            self.sq:transmitRemoveItemFromSquare(object)
            self.sq:RemoveTileObject(object);
            break
        end
    end

    -- Disable erosion for this square
    self.sq:disableErosion();
    local args = { x = self.sq:getX(), y = self.sq:getY(), z = self.sq:getZ() }
    sendServerCommand('erosion', 'disableForSquare', args)

    -- Create the well object
    self.javaObject = IsoThumpable.new(cell, self.sq, sprite, north, self);
    self.sq:RecalcAllWithNeighbours(true);
    self.javaObject:setName("SimpleWell");
    self.javaObject:setCanBarricade(false);
    self.javaObject:setIsThumpable(false);

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
--** ISSimpleWell:new
--************************************************************************--
function ISSimpleWell:new(sprite, equipBothHandItem)
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
--** ISSimpleWell:getHealth
--************************************************************************--
function ISSimpleWell:getHealth()
    return 500 + buildUtil.getWoodHealth(self);
end

--************************************************************************--
--** ISSimpleWell:render
--************************************************************************--
function ISSimpleWell:render(x, y, z, square)
    local spriteName = self:getSprite()
    local sprite = IsoSprite.new()
    sprite:LoadSingleTexture(spriteName)

    local floor = square:getFloor();
    if not floor then
        return;
    end

    -- Check if valid location
    local spriteFree = ISBuildingObject.isValid(self, square) and
                      floor:getTextureName() and
                      (luautils.stringStarts(floor:getTextureName(), "floors_exterior_natural") or
                       luautils.stringStarts(floor:getTextureName(), "blends_natural_01"));

    spriteFree = spriteFree and ISSimpleWell.floorCanDig(square);

    -- Render ghost tile (green if valid, red if not)
    if spriteFree and z==0 then
        sprite:RenderGhostTile(x, y, z);
    else
        sprite:RenderGhostTileRed(x, y, z);
    end
end

--************************************************************************--
--** ISSimpleWell:isValid
--************************************************************************--
function ISSimpleWell:isValid(square)
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
    if not ISSimpleWell.floorCanDig(square) then
        return false;
    end

    return true
end

--************************************************************************--
--** ISSimpleWell.floorCanDig (static method)
--************************************************************************--
function ISSimpleWell.floorCanDig(square)
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
--** ISSimpleWell.canDigHere (static method)
--************************************************************************--
function ISSimpleWell.canDigHere(worldObjects)
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
