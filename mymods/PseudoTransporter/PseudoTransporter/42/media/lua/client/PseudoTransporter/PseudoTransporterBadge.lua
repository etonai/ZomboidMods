-- PseudoTransporter: "Transport" inventory option on the Transporter Badge.

local PT = PseudoTransporter
local BADGE_TYPE = "PseudoTransporter.TransporterBadge"

local function hasBadge(items)
    for _, entry in ipairs(items) do
        if instanceof(entry, "InventoryItem") then
            if entry:getFullType() == BADGE_TYPE then return true end
        elseif entry.items then      -- a stack: { items = { ... } }
            for _, it in ipairs(entry.items) do
                if it:getFullType() == BADGE_TYPE then return true end
            end
        end
    end
    return false
end

local function onFillInventoryObjectContextMenu(playerNum, context, items)
    if not hasBadge(items) then return end
    local playerObj = getSpecificPlayer(playerNum)
    local option = context:addOption(getText("UI_PseudoTransporter_Transport"), playerObj, PT.transportTo, PT.ROLE_CONTROL)
    if not PT.getRegistry()[PT.ROLE_CONTROL] then
        option.notAvailable = true
        local tip = ISWorldObjectContextMenu.addToolTip()
        tip.description = getText("UI_PseudoTransporter_NoControl")
        option.toolTip = tip
    end
end

Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)
