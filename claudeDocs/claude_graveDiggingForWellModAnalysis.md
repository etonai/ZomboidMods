# Grave Digging Code Analysis for Well Mod Development - CLAUDE.md

**Created:** October 8, 2025
**Version:** Project Zomboid 42.11.0
**Purpose:** Analysis of grave digging mechanics to guide development of a well digging mod

## Overview

This document analyzes Project Zomboid's grave digging system to identify reusable code patterns and mechanics for creating a mod that allows players to dig single-tile wells. The grave system provides an excellent foundation since both involve digging into ground with similar tool requirements and validation logic.

## Core Grave System Architecture

### Main Components

**1. ISEmptyGraves.lua** - Primary building object
- Handles grave construction and placement logic
- Manages two-tile grave structure
- Validates ground conditions and tool requirements

**2. ISBuryCorpse.lua** - Corpse burial action
- 300-second timed action for placing corpses
- Updates grave state and sprite progression
- Handles both human and animal corpses

**3. ISFillGrave.lua** - Grave completion action
- 150-second timed action requiring shovel
- Changes grave sprite to "filled" state
- Marks grave as completed in mod data

**4. GraveHelper.lua** - Utility functions
- Updates grave corpse count and synchronization
- Handles two-tile grave coordination
- Animal corpse special handling

## Key Mechanics for Well Adaptation

### Ground Validation System
```lua
-- From ISEmptyGraves.lua:181-202
function ISEmptyGraves.shovelledFloorCanDig(square)
    if (not square) or (not square:getFloor()) then return false end
    if square:isInARoom() then return false end

    local floor = square:getFloor()
    local sprites = floor:getModData() and floor:getModData().shovelledSprites
    if sprites then
        for i=1,#sprites do
            local sprite = sprites[i]
            if luautils.stringStarts(sprite, "floors_exterior_natural") or
               luautils.stringStarts(sprite, "blends_natural_01") then
                return true
            end
        end
        return false
    else
        return true
    end
end
```

**Adaptation for Wells:**
- Keep outdoor/natural ground requirements
- Consider adding water table proximity checks
- Possibly restrict to certain terrain types
- Add elevation or geological considerations

### Tool Requirement Pattern
```lua
-- From ISEmptyGraves.lua:89 and ISFillGrave.lua:192
o.equipBothHandItem = equipBothHandItem  -- Shovel requirement
o.actionAnim = BuildingHelper.getShovelAnim(equipBothHandItem)
o.craftingBank = "Shoveling"

-- Equipment handling in ISFillGrave
ISInventoryPaneContextMenu.equipWeapon(shovel, true, true, player)
```

**Adaptation for Wells:**
- Maintain shovel requirement for consistency
- Consider adding pickaxe for rocky ground
- Implement progressive tool requirements (shovel → pickaxe → bucket)

### Context Menu Integration
```lua
-- From ISWorldObjectContextMenu.lua:3164-3168
ISWorldObjectContextMenu.onDigGraves = function(worldobjects, player, shovel)
    local bo = ISEmptyGraves:new("location_community_cemetary_01_33",
                                "location_community_cemetary_01_32",
                                "location_community_cemetary_01_34",
                                "location_community_cemetary_01_35", shovel)
    bo.player = player
    bo.character = getSpecificPlayer(player)
    getCell():setDrag(bo, bo.player)
end
```

**Adaptation for Wells:**
- Create `ISWorldObjectContextMenu.onDigWell` function
- Use single sprite instead of four grave sprites
- Implement similar drag-to-place cursor behavior

## Proposed Well System Architecture

### Core Files Structure
```
ISDigWell.lua           -- Main well building object (based on ISEmptyGraves)
ISWellConstruction.lua  -- Multi-stage construction (digging → lining → completion)
ISWellInteraction.lua   -- Water extraction and maintenance actions
WellHelper.lua          -- Utility functions for water mechanics
```

### Well State Progression
1. **Digging State** - Hole in ground, not functional
2. **Raw Well State** - Functional but basic water collection
3. **Lined Well State** - Stone-lined for improved durability/yield
4. **Covered Well State** - Protected from contamination

### Key Modifications from Grave System

**Single Tile Implementation:**
```lua
-- Remove two-tile logic from ISEmptyGraves
function ISDigWell:create(x, y, z, north, sprite)
    local cell = getWorld():getCell()
    self.sq = cell:getGridSquare(x, y, z)
    self:setInfo(self.sq, north, sprite, cell, "wellSprite")
    -- No second square creation needed
end
```

**Water Storage Instead of Corpse Storage:**
```lua
-- Replace corpse counting with water mechanics
function ISDigWell:initializeWater()
    self.javaObject:getModData()["waterAmount"] = 0
    self.javaObject:getModData()["maxWaterCapacity"] = 50
    self.javaObject:getModData()["wellQuality"] = "basic"
end
```

**Progressive Construction System:**
```lua
-- Multi-stage construction like barricading
function ISDigWell:getConstructionStage()
    return self.javaObject:getModData()["constructionStage"] or "digging"
end

function ISDigWell:advanceStage(newStage)
    self.javaObject:getModData()["constructionStage"] = newStage
    self:updateSprite()
end
```

## Implementation Strategy

### Phase 1: Basic Well Digging
- Adapt ISEmptyGraves for single-tile well
- Implement basic ground validation
- Create simple dig-to-completion mechanic
- Add basic water storage functionality

### Phase 2: Enhanced Mechanics
- Add multi-stage construction system
- Implement water accumulation over time
- Add weather effects on water collection
- Create extraction mechanics with buckets/containers

### Phase 3: Advanced Features
- Stone lining system (similar to barricading)
- Well contamination and purification
- Depth-based water yield variations
- Maintenance and repair mechanics

## Code Reuse Opportunities

### Direct Reuse (Minimal Changes)
- Ground validation functions
- Tool requirement checks
- Context menu integration pattern
- Timed action framework
- Building animation system

### Adaptation Required (Moderate Changes)
- Tile creation logic (2-tile → 1-tile)
- State management (corpses → water)
- Completion mechanics (filled grave → functional well)
- Sprite progression system

### New Implementation Needed
- Water accumulation logic
- Extraction mechanics
- Container interaction
- Quality/contamination system

## Technical Considerations

### Performance
- Water accumulation could use existing item update systems
- Leverage mod data for persistence
- Avoid heavy calculations in update loops

### Multiplayer Compatibility
- Follow grave system's client-server patterns
- Use existing synchronization methods
- Implement proper permission checks

### Mod Compatibility
- Use same ground validation as graves
- Follow existing building system conventions
- Avoid conflicts with water-related mods

## Code References

### Primary Files
- `ISEmptyGraves.lua` - Main construction logic and validation
- `ISFillGrave.lua:192` - Tool equipment pattern
- `ISBuryCorpse.lua:25` - Metabolic/energy system integration
- `GraveHelper.lua:19-45` - State management patterns

### Supporting Systems
- `ISWorldObjectContextMenu.lua:3164` - Context menu integration
- `BuildingHelper.getShovelAnim()` - Animation system
- `ISBuildingObject` - Base class inheritance
- Timed action framework for construction phases

## Conclusion

The grave digging system provides an excellent foundation for well construction due to:

1. **Similar Ground Requirements** - Both need natural, outdoor terrain
2. **Established Tool Patterns** - Shovel requirement system already implemented
3. **Proven Validation Logic** - Ground checking and placement validation
4. **Context Menu Precedent** - Digging actions already use right-click pattern
5. **Modular Architecture** - Clean separation of concerns for easy adaptation

The main adaptations involve converting from a 2-tile corpse storage system to a 1-tile water collection system, while maintaining the core digging, validation, and construction mechanics that make the grave system robust and user-friendly.

---
*This analysis is based on Project Zomboid version 42.11.0 source code examination.*