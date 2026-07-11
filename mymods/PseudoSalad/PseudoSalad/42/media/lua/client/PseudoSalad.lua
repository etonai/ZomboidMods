require "TimedActions/ISBaseTimedAction"
require "TimedActions/ISAddItemInRecipe"
require "TimedActions/ISInventoryTransferAction"

PseudoSalad = PseudoSalad or {}

PseudoSalad.BaseToResult = {
    ["Base.Bowl"] = "Base.Salad",
    ["Base.ClayBowl"] = "Base.SaladClay",
}

PseudoSalad.PreferredSteps = {
    "egg",
    "egg",
    "protein",
    "protein",
    "vegetable",
    "vegetable",
}

PseudoSalad.ProteinTypes = {
    ["Base.FishFillet"] = true,
    ["Base.Smallbirdmeat"] = true,
}

PseudoSalad.VegetableFoodTypes = {
    Vegetables = true,
    Greens = true,
}

local function getSelectedInventoryItem(items)
    if not items or #items < 1 then
        return nil
    end

    local item = items[1]
    if instanceof(item, "InventoryItem") then
        return item
    end

    if item and item.items and item.items[1] then
        return item.items[1]
    end

    return nil
end

local function getExtraItemCount(baseItem)
    local extraItems = baseItem and baseItem:getExtraItems()
    if not extraItems then
        return 0
    end

    return extraItems:size()
end

local function getRemainingRotTime(item)
    return item:getOffAgeMax() - item:getAge()
end

function PseudoSalad.isBetterFood(leftItem, rightItem)
    if not leftItem then
        return rightItem
    end
    if not rightItem then
        return leftItem
    end

    local leftRotTime = getRemainingRotTime(leftItem)
    local rightRotTime = getRemainingRotTime(rightItem)

    if rightRotTime < leftRotTime then
        return rightItem
    elseif rightRotTime > leftRotTime then
        return leftItem
    end

    if rightItem:getHungerChange() > leftItem:getHungerChange() then
        return rightItem
    elseif rightItem:getHungerChange() < leftItem:getHungerChange() then
        return leftItem
    end

    if rightItem:getFullType() < leftItem:getFullType() then
        return rightItem
    end

    return leftItem
end

function PseudoSalad.isValidIngredient(item, playerObj)
    if not item or not instanceof(item, "Food") then
        return false
    end

    if playerObj and playerObj:isKnownPoison(item) then
        return false
    end

    if item:isRotten() or item:isBurnt() or item:isSpice() then
        return false
    end

    if item:isbDangerousUncooked() and not item:isCooked() then
        return false
    end

    return true
end

function PseudoSalad.getIngredientCategory(item, playerObj)
    if not PseudoSalad.isValidIngredient(item, playerObj) then
        return nil
    end

    local fullType = item:getFullType()
    local foodType = item:getFoodType()

    if foodType == "Egg" then
        return "egg"
    end

    if PseudoSalad.ProteinTypes[fullType] and item:isCooked() then
        return "protein"
    end

    if PseudoSalad.VegetableFoodTypes[foodType] then
        return "vegetable"
    end

    return "fallback"
end

function PseudoSalad.collectCandidates(items, playerObj)
    local candidates = {
        all = {},
        egg = {},
        protein = {},
        vegetable = {},
        fallback = {},
    }

    if not items then
        return candidates
    end

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local category = PseudoSalad.getIngredientCategory(item, playerObj)
        if category then
            table.insert(candidates.all, item)
            table.insert(candidates[category], item)
        end
    end

    return candidates
end

function PseudoSalad.chooseBest(items, usageCounts, enforceLimit)
    local chosen = nil

    for _, item in ipairs(items) do
        local fullType = item:getFullType()
        local usedCount = usageCounts and usageCounts[fullType] or 0
        if not enforceLimit or usedCount < 2 then
            chosen = PseudoSalad.isBetterFood(chosen, item)
        end
    end

    return chosen
end

function PseudoSalad.findRecipe(playerObj, baseItem, containerList)
    if not playerObj or not baseItem then
        return nil
    end

    local expectedResult = PseudoSalad.BaseToResult[baseItem:getFullType()]
    if not expectedResult then
        return nil
    end

    local recipes = RecipeManager.getEvolvedRecipe(baseItem, playerObj, containerList, false)
    if not recipes then
        return nil
    end

    for i = 0, recipes:size() - 1 do
        local recipe = recipes:get(i)
        if recipe:getFullResultItem() == expectedResult then
            return recipe
        end
    end

    return nil
end

function PseudoSalad:new(playerObj, recipe, baseItem)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.playerObj = playerObj
    o.recipe = recipe
    o.baseItem = baseItem
    o.addAction = nil
    o.usedCounts = {}
    o.partialRemainders = {}

    return o
end

function PseudoSalad:choosePartialRemainder(items)
    for _, item in ipairs(items) do
        local fullType = item:getFullType()
        local itemID = item:getID()
        if self.partialRemainders[fullType] == itemID and (self.usedCounts[fullType] or 0) == 1 then
            return item
        end
    end

    return nil
end

function PseudoSalad:chooseIngredientForStep(candidates, stepCategory)
    local preferred = self:choosePartialRemainder(candidates[stepCategory] or {})
    if preferred then
        return preferred
    end

    preferred = PseudoSalad.chooseBest(candidates[stepCategory] or {}, self.usedCounts, true)
    if not preferred then
        preferred = self:choosePartialRemainder(candidates.all)
    end

    if not preferred then
        preferred = PseudoSalad.chooseBest(candidates.all, self.usedCounts, true)
    end

    if not preferred then
        preferred = PseudoSalad.chooseBest(candidates.all)
    end

    return preferred
end

function PseudoSalad:recordIngredientUse(item)
    if not item then
        return
    end

    local fullType = item:getFullType()
    self.usedCounts[fullType] = (self.usedCounts[fullType] or 0) + 1
end

function PseudoSalad:onIngredientAdded(usedItem, beforeCount, afterCount)
    if not usedItem or afterCount <= beforeCount then
        return
    end

    self:recordIngredientUse(usedItem)

    local fullType = usedItem:getFullType()
    if usedItem:getContainer() and PseudoSalad.isValidIngredient(usedItem, self.playerObj) and (self.usedCounts[fullType] or 0) < 2 then
        self.partialRemainders[fullType] = usedItem:getID()
    else
        self.partialRemainders[fullType] = nil
    end
end

function PseudoSalad:continue()
    if self.addAction and self.addAction.baseItem then
        self.baseItem = self.addAction.baseItem
    end

    if not self.baseItem or not self.recipe then
        return
    end

    local ingredientCount = getExtraItemCount(self.baseItem)
    if ingredientCount >= self.recipe:getMaxItems() or ingredientCount >= #PseudoSalad.PreferredSteps then
        return
    end

    local containerList = ISInventoryPaneContextMenu.getContainers(self.playerObj)
    local usableItems = self.recipe:getItemsCanBeUse(self.playerObj, self.baseItem, containerList)
    local candidates = PseudoSalad.collectCandidates(usableItems, self.playerObj)
    local stepCategory = PseudoSalad.PreferredSteps[ingredientCount + 1] or "fallback"
    local usedItem = self:chooseIngredientForStep(candidates, stepCategory)

    if usableItems then
        usableItems:clear()
    end

    if not usedItem then
        return
    end

    if not self.playerObj:getInventory():contains(usedItem) then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(self.playerObj, usedItem, usedItem:getContainer(), self.playerObj:getInventory(), nil))
    end

    if not self.playerObj:getInventory():contains(self.baseItem) then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(self.playerObj, self.baseItem, self.baseItem:getContainer(), self.playerObj:getInventory(), nil))
    end

    self.addAction = PseudoSaladAddItemInRecipe:new(self, self.playerObj, self.recipe, self.baseItem, usedItem)
    ISTimedActionQueue.add(self.addAction)
    ISTimedActionQueue.add(PseudoSaladContinue:new(self, self.playerObj))
end

function PseudoSalad.start(planner)
    if planner then
        planner:continue()
    end
end

function PseudoSalad.addContextOption(player, context, items)
    local baseItem = getSelectedInventoryItem(items)
    if not baseItem or not PseudoSalad.BaseToResult[baseItem:getFullType()] then
        return
    end

    local playerObj = getSpecificPlayer(player)
    if not playerObj then
        return
    end

    local containerList = ISInventoryPaneContextMenu.getContainers(playerObj)
    local recipe = PseudoSalad.findRecipe(playerObj, baseItem, containerList)
    if not recipe then
        return
    end

    local usableItems = recipe:getItemsCanBeUse(playerObj, baseItem, containerList)
    local candidates = PseudoSalad.collectCandidates(usableItems, playerObj)
    local hasIngredients = #candidates.all > 0
    if usableItems then
        usableItems:clear()
    end

    local planner = PseudoSalad:new(playerObj, recipe, baseItem)
    local option = context:addOption(getText("ContextMenu_PseudoSalad_MakeAutoSalad"), planner, PseudoSalad.start)
    if not hasIngredients then
        option.notAvailable = true
    end

    local tooltip = ISInventoryPaneContextMenu.addToolTip()
    tooltip:setName(getText("ContextMenu_PseudoSalad_MakeAutoSalad"))
    if hasIngredients then
        tooltip.description = getText("ContextMenu_PseudoSalad_Tooltip")
    else
        tooltip.description = getText("ContextMenu_PseudoSalad_TooltipNoIngredients")
    end
    option.toolTip = tooltip
end

PseudoSaladContinue = ISBaseTimedAction:derive("PseudoSaladContinue")

PseudoSaladAddItemInRecipe = ISAddItemInRecipe:derive("PseudoSaladAddItemInRecipe")

function PseudoSaladAddItemInRecipe:complete()
    local beforeCount = getExtraItemCount(self.baseItem)
    local result = ISAddItemInRecipe.complete(self)
    local afterCount = getExtraItemCount(self.baseItem)

    if result and self.planner then
        self.planner:onIngredientAdded(self.usedItem, beforeCount, afterCount)
    end

    return result
end

function PseudoSaladAddItemInRecipe:new(planner, character, recipe, baseItem, usedItem)
    local o = ISAddItemInRecipe.new(self, character, recipe, baseItem, usedItem)
    o.planner = planner
    return o
end

function PseudoSaladContinue:isValid()
    return self.target ~= nil
end

function PseudoSaladContinue:update()
end

function PseudoSaladContinue:start()
end

function PseudoSaladContinue:stop()
    ISBaseTimedAction.stop(self)
end

function PseudoSaladContinue:perform()
    ISBaseTimedAction.perform(self)
    self.target:continue()
end

function PseudoSaladContinue:new(target, character)
    local o = ISBaseTimedAction.new(self, character)
    o.target = target
    o.stopOnWalk = false
    o.stopOnRun = false
    o.maxTime = 1
    return o
end

Events.OnPreFillInventoryObjectContextMenu.Add(PseudoSalad.addContextOption)
