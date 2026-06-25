require "PseudoButterCandle_LightObject"

PseudoButterCandle = PseudoButterCandle or {}
PseudoButterCandle.Utils = PseudoButterCandle.Utils or {}

local Utils = PseudoButterCandle.Utils

Utils.modKey = "PseudoButterCandle"
Utils.litTag = "pseudobuttercandle:buttercandlelit"
Utils.lights = Utils.lights or {}
Utils.loaders = Utils.loaders or {}

function Utils.hasTag(item, selector)
  if not item or not item.getTags then return false end

  local itemTags = item:getTags()
  local itemTagArray = itemTags:toArray()

  for i = 1, itemTags:size() do
    if itemTagArray[i] and itemTagArray[i]:toString() == selector then
      return true
    end
  end

  return false
end

function Utils.isLitButterCandle(item)
  return Utils.hasTag(item, Utils.litTag)
end

function Utils.isEmpty(obj)
  if not obj then return true end
  for _, _ in pairs(obj) do
    return false
  end
  return true
end

function Utils.getChunkIDFromCoords(x, y)
  return math.floor(x / 8) .. "," .. math.floor(y / 8)
end

function Utils.getChunkID(chunk)
  local square = chunk:getGridSquare(0, 0, 0) or chunk:getGridSquare(0, 0, -1)
  if not square then return nil end

  return Utils.getChunkIDFromCoords(square:getX(), square:getY())
end

function Utils.addLightToWorld(itemID, x, y, z, radius)
  Utils.removeLightFromWorld(itemID)

  local light = PseudoButterCandle_LightObject:new(x, y, z, radius)
  light:spawnLight()
  Utils.lights[itemID] = light
end

function Utils.removeLightFromWorld(itemID)
  local light = Utils.lights[itemID]
  if not light then return end

  light:destroy()
  Utils.lights[itemID] = nil
end

function Utils.removeLoaderFromWorld(itemID, chunkID)
  if not chunkID and Utils.lights[itemID] then
    local light = Utils.lights[itemID]
    chunkID = Utils.getChunkIDFromCoords(light.x, light.y)
  end

  if chunkID and Utils.loaders[chunkID] then
    Utils.loaders[chunkID][itemID] = nil

    if Utils.isEmpty(Utils.loaders[chunkID]) then
      Utils.loaders[chunkID] = nil
    end
  end

  if Utils.isEmpty(Utils.loaders) then
    Events.LoadChunk.Remove(Utils.chunkChecker)
  end
end

function Utils.chunkChecker(chunk)
  local chunkID = Utils.getChunkID(chunk)
  if not chunkID or not Utils.loaders[chunkID] then return end

  for itemID, data in pairs(Utils.loaders[chunkID]) do
    if data.state == "light" then
      Utils.addLightToWorld(itemID, data.x, data.y, data.z, data.radius)
    elseif data.state == "extinguish" then
      Utils.removeLightFromWorld(itemID)
    end

    Utils.removeLoaderFromWorld(itemID, chunkID)
  end
end

function Utils.tryAddLightToWorld(itemID, x, y, z, chunkID, radius)
  if not itemID or not x or not y or not z then return end

  if getSquare(x, y, z) then
    Utils.addLightToWorld(itemID, x, y, z, radius)
    return
  end

  chunkID = chunkID or Utils.getChunkIDFromCoords(x, y)

  if Utils.isEmpty(Utils.loaders) then
    Events.LoadChunk.Add(Utils.chunkChecker)
  end

  Utils.loaders[chunkID] = Utils.loaders[chunkID] or {}
  Utils.loaders[chunkID][itemID] = {
    x = x,
    y = y,
    z = z,
    state = "light",
    radius = radius,
  }
end

function Utils.tryRemoveLightFromWorld(itemID, chunkID)
  local light = Utils.lights[itemID]
  if not light then return end

  local square = getSquare(light.x, light.y, light.z)
  if square then
    Utils.removeLightFromWorld(itemID)
    return
  end

  chunkID = chunkID or Utils.getChunkIDFromCoords(light.x, light.y)
  Utils.loaders[chunkID] = Utils.loaders[chunkID] or {}
  Utils.loaders[chunkID][itemID] = {
    x = light.x,
    y = light.y,
    z = light.z,
    state = "extinguish",
  }
end

function Utils.getItemByID(id, square)
  if not id or not square then return nil end

  local numericId = tonumber(id) or id
  local objects = square:getWorldObjects()
  for i = 0, objects:size() - 1 do
    local worldObject = objects:get(i)
    local item = worldObject and worldObject:getItem()

    if item and item:getID() == numericId then
      return item
    end
  end

  return nil
end

function Utils.sendLightCommand(item, square, character)
  if not item or not square or not character then return end

  sendClientCommand(character, "PseudoButterCandle", "light", {
    itemId = item:getID(),
    chunkId = Utils.getChunkIDFromCoords(square:getX(), square:getY()),
    x = square:getX(),
    y = square:getY(),
    z = square:getZ(),
  })
end

function Utils.sendExtinguishCommand(item, character)
  if not item or not character then return end

  sendClientCommand(character, "PseudoButterCandle", "extinguish", {
    itemId = item:getID(),
  })
end

function Utils.removeWorldItem(item, square)
  if not item then return end

  local worldItem = item:getWorldItem()
  if not worldItem then
    item:Use()
    return
  end

  square = square or worldItem:getSquare()
  if square then
    square:transmitRemoveItemFromSquare(worldItem)
    square:removeWorldObject(worldItem)
  end

  item:setWorldItem(nil)
end
