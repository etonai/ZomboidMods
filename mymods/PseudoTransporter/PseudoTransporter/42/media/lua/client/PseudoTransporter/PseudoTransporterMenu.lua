-- PseudoTransporter: "Transport" context-menu option and teleport.

local PT = PseudoTransporter

-- Control is "powered" when its radio device is switched on (the engine switches a
-- device off when its battery is empty or its square has no power).
local function controlHasPower(obj)
    local dd = obj.getDeviceData and obj:getDeviceData()
    return dd ~= nil and dd:getIsTurnedOn()
end

local function doTransport(playerObj, destRole)
    PT.transportTo(playerObj, destRole)
end

local function boosterNumber(role)
    return role:sub(-1)
end

local function addControlMenu(context, playerObj, obj)
    local option = context:addOption(getText("UI_PseudoTransporter_Transport"))
    if not controlHasPower(obj) then
        option.notAvailable = true
        local tip = ISWorldObjectContextMenu.addToolTip()
        tip.description = getText("UI_PseudoTransporter_NeedsPower")
        option.toolTip = tip
        return
    end
    local sub = ISContextMenu:getNew(context)
    context:addSubMenu(option, sub)
    local registry = PT.getRegistry()
    for _, role in ipairs(PT.BOOSTER_ROLES) do
        local label = getText("UI_PseudoTransporter_BoosterName", boosterNumber(role))
        local subOption = sub:addOption(label, playerObj, doTransport, role)
        if not registry[role] then
            subOption.notAvailable = true
            local tip = ISWorldObjectContextMenu.addToolTip()
            tip.description = getText("UI_PseudoTransporter_BoosterNotPlaced")
            subOption.toolTip = tip
        end
    end
end

local function onFillWorldObjectContextMenu(playerNum, context, worldobjects, test)
    if test then return end
    local playerObj = getSpecificPlayer(playerNum)
    for _, obj in ipairs(worldobjects) do
        local role = PT.getObjectRole(obj)
        if role == PT.ROLE_CONTROL then
            addControlMenu(context, playerObj, obj)
            return
        elseif PT.isBoosterRole(role) then
            -- Boosters only go to the Control; no power needed.
            context:addOption(getText("UI_PseudoTransporter_Transport"), playerObj, doTransport, PT.ROLE_CONTROL)
            return
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
