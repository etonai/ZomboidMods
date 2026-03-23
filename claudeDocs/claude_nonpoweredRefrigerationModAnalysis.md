# Non-Powered Refrigeration Storage Mod Analysis - CLAUDE.md

**Created:** October 8, 2025
**Version:** Project Zomboid 42.11.0
**Purpose:** Analysis of feasibility for creating a mod that implements refrigeration without electricity

## Overview

This document analyzes the technical feasibility of creating a Project Zomboid mod that implements a storage container with refrigeration properties (food preservation) without requiring electrical power. The analysis is based on examination of the game's Java engine code and Lua scripting capabilities.

## Current Refrigeration System Analysis

### Core Mechanics (Java Engine)
Based on examination of the source code:

**Temperature System:**
- Powered refrigerators maintain 0.2°C temperature (`ItemContainer.java:2169`)
- Temperature determined by `getTemprature()` method in `ItemContainer.java:2159-2174`
- Power status checked via `isPowered()` method (`ItemContainer.java:2112`)

**Food Preservation:**
- Fridge containers have `ageFactor = 0.02` (2% normal aging rate)
- Freezers have `FreezerAgeMultiplier = 0.0` (no aging when frozen)
- Food items inherit container temperature when placed inside

**Container Types:**
- "fridge" and "freezer" container types recognized
- Objects with "IsFridge" sprite property treated as refrigerators
- Custom temperature can be set via `customTemperature` field

## Mod Implementation Feasibility

### Lua API Limitations
Project Zomboid mods are restricted to Lua scripting only - Java engine code cannot be modified. This creates significant constraints:

1. **Core Logic Inaccessible:** The `getTemprature()` method logic cannot be directly modified
2. **Power Check Hardcoded:** The `isPowered()` requirement is enforced at the Java level
3. **Container Behavior Fixed:** Fundamental container mechanics are Java-controlled

### Potential Lua-Only Approaches

#### Option 1: Custom Temperature Property (Most Promising)
The `customTemperature` field is checked before power validation in the engine:

```lua
-- Theoretical implementation
container:setCustomTemperature(0.2) -- Bypass power requirement
```

**Feasibility:** High if `setCustomTemperature()` is exposed to Lua
**Testing Required:** Verify Lua API access to this property

#### Option 2: Event-Based Food Management
Manual food preservation through Lua events:

```lua
Events.OnObjectUpdate.Add(function(obj)
    if obj:getContainer() and obj:getContainer():getType() == "icebox" then
        -- Custom aging logic
        obj:setAgeingFactor(0.02)
    end
end)
```

**Feasibility:** Medium - depends on event system granularity
**Limitations:** May not integrate seamlessly with engine food systems

#### Option 3: Custom Container Type
Create new container type with special properties:

```lua
-- Define new container type in Lua
containerType = "icebox"
ageFactor = 0.02
```

**Feasibility:** Low - container type behavior likely hardcoded
**Testing Required:** Verify if new types inherit preservation properties

#### Option 4: Sprite Property Exploitation
Use existing "IsFridge" sprite property system:

```lua
-- Set sprite property to trigger fridge behavior
sprite:setProperty("IsFridge", true)
```

**Feasibility:** Medium - may still require power check bypass
**Limitations:** Would still be subject to electricity requirements

## Implementation Strategy

### Recommended Approach
1. **Primary:** Test `customTemperature` property access from Lua
2. **Fallback:** Implement event-based food preservation system
3. **Theme:** Ice box, root cellar, or insulated cooler for realism

### Code Structure
```
media/lua/shared/IceboxDefinitions.lua     -- Container definitions
media/lua/client/ISUI/IceboxUI.lua         -- User interface
media/lua/server/IceboxBehavior.lua        -- Server-side logic
```

### Testing Requirements
Before full implementation, verify:
- Lua API access to `setCustomTemperature()`
- Food aging event system availability
- Custom container type recognition
- Sprite property modification capabilities

## Realistic Thematic Options

### Historical/Realistic Implementations
- **Ice Box:** Pre-electric refrigeration using ice blocks
- **Root Cellar Crate:** Underground storage simulation
- **Insulated Cooler:** Modern camping cooler with ice
- **Salt Preservation Barrel:** Curing/preservation container

### Game Balance Considerations
- **Resource Cost:** Require ice, salt, or other consumables
- **Capacity Limits:** Smaller than electric refrigerators
- **Maintenance:** Periodic "refueling" with preservation materials
- **Temperature Zones:** Different effectiveness based on location

## Conclusion

Creating a non-powered refrigeration mod is **potentially feasible** but depends heavily on Lua API capabilities not fully documented. The most promising approach involves exploiting the `customTemperature` property if accessible from Lua.

**Recommended Next Steps:**
1. Research existing mods that modify container behavior
2. Test Lua API access to ItemContainer temperature properties
3. Prototype basic container with custom properties
4. Implement fallback event-based system if direct approach fails

**Success Probability:** 60% - contingent on engine exposing sufficient container properties to Lua scripting

## Code References

- `ItemContainer.java:2159-2174` - Temperature calculation logic
- `ItemContainer.java:2112` - Power status checking
- `ItemContainer.java:114-116` - Fridge container initialization
- `Food.java:106` - Freezer age multiplier
- `ISMoveableDefinitions.lua:437-445` - Refrigerator scrap definitions

---
*This analysis is based on Project Zomboid version 42.11.0 source code examination and is subject to change with game updates.*