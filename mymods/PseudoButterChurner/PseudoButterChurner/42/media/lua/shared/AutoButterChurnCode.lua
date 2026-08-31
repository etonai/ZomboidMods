-- Power gating for the AutoButterChurn entity's auto_churn_butter recipe.
--
-- component CraftLogic has no built-in "requires power" concept (see
-- doc/ideas/claude_automaticButterChurning.md and DevCycle001.md §3), so this
-- reactive check runs on every tick of a running craft (wired via the recipe's
-- OnUpdate = AutoButterChurnCode.checkPower) and force-stops the entity's
-- CraftLogic component the moment its square loses power, mirroring
-- ClothingWasherLogic's own mid-cycle power-loss shutoff.

AutoButterChurnCode = {}

function AutoButterChurnCode.checkPower(craftRecipeData)
    if craftRecipeData:getAllViableResourcesCount() <= 0 then
        return
    end

    local resource = craftRecipeData:getViableResource(0)
    if not resource then
        return
    end

    local entity = resource:getGameEntity()
    if not entity then
        return
    end

    local square = entity:getSquare()
    if not square or square:haveElectricity() then
        return
    end

    local craftLogic = entity:getComponent(ComponentType.CraftLogic)
    if craftLogic and craftLogic:isRunning() then
        craftLogic:stop(nil, true)
    end
end
