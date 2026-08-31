-- TEMPORARY diagnostic, DevCycle001.md Phase 15.
--
-- Phase 14's fix (using "Pseudonymous.AutoButterChurn" instead of the bare
-- "AutoButterChurn" when calling square:addWorkstationEntity) did NOT
-- resolve the bug - the converted object still disappeared. Rather than
-- guess again, this enumerates every registered GameEntityScript at game
-- start and prints its getFullName()/getModuleName()/getName(), filtered to
-- anything mentioning "butter" or "Pseudonymous" (case-insensitive), so we
-- can see the ACTUAL key our entity is registered under, ground-truth,
-- instead of reasoning about it from decompiled source alone.
--
-- DELETE THIS FILE once the correct entity-script key has been confirmed
-- and the conversion works end-to-end.

local function scanEntities()
    local all = ScriptManager.instance:getAllGameEntities()
    print("AutoButterChurnEntityDiag: total registered GameEntityScripts = " .. tostring(all:size()))

    local matchCount = 0
    for i = 0, all:size() - 1 do
        local script = all:get(i)
        local fullName = tostring(script:getFullName())
        local moduleName = tostring(script:getModuleName())
        local name = tostring(script:getName())
        local haystack = string.lower(fullName .. " " .. moduleName .. " " .. name)
        if string.find(haystack, "butter") or string.find(haystack, "pseudonymous") then
            matchCount = matchCount + 1
            print("AutoButterChurnEntityDiag: MATCH getFullName=[" .. fullName .. "] getModuleName=[" .. moduleName .. "] getName=[" .. name .. "]")
        end
    end
    print("AutoButterChurnEntityDiag: scan complete, " .. matchCount .. " matching entities found")

    -- Direct lookup tests, for comparison against the enumeration above.
    local candidates = {"AutoButterChurn", "Pseudonymous.AutoButterChurn", "pseudonymous.AutoButterChurn"}
    for _, candidate in ipairs(candidates) do
        local script = ScriptManager.instance:getGameEntityScript(candidate)
        print("AutoButterChurnEntityDiag: getGameEntityScript(\"" .. candidate .. "\") = " .. tostring(script))
    end
end

Events.OnGameStart.Add(scanEntities)
