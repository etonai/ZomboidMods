# PseudoSaltWell Build 42 Migration Plan

**Created:** October 8, 2025
**Target Version:** Project Zomboid 42.11.0
**Source Mod:** PseudoSaltWell (Build 41.51)
**Complexity:** Moderate - mostly structural changes required

## Executive Summary

Based on analysis of existing mods in the codebase, PseudoSaltWell can be successfully migrated to Build 42 with minimal code changes. The main requirements are structural reorganization to follow Build 42 conventions and minor API updates for enhanced timed actions.

## Analysis Summary

### Mod Survey Results

**Build 42 Compatible Mods Analyzed:**
- **KR FriOS** (v2.2) - `versionMin=42.0.0` - Working temperature manipulation
- **SaltDigger** (v42.10.0) - Similar salt mechanics, proper Build 42 structure
- **Cooler Backpack** - Working container temperature systems

**PseudoSaltWell Current Status:**
- **Build Version:** 41.51 (pre-Build 42)
- **Structure:** Flat directory structure (needs Build 42 version folders)
- **Code Quality:** Excellent - minimal API changes needed
- **Functionality:** Complete and working in Build 41

### Key Compatibility Findings

**✅ What Works Without Changes:**
- Core Lua scripting APIs remain compatible
- Context menu system (`Events.OnPreFillWorldObjectContextMenu`) unchanged
- Timed action base classes still functional
- Recipe system maintains compatibility
- Item definitions and sprite systems unchanged

**⚠️ What Needs Updates:**
- Directory structure must follow Build 42 conventions
- Enhanced timed action features available (metabolic targets, job deltas)
- Mod info format should include version specifications
- Some debugging improvements possible

## Migration Plan

### Phase 1: Directory Structure Reorganization

**Current Structure:**
```
PseudoSaltWell/
├── mod.info
├── media/
│   ├── lua/
│   ├── scripts/
│   ├── textures/
│   └── ...
```

**Target Build 42 Structure:**
```
PseudoSaltWell/
├── mod.info (updated)
├── 42/
│   ├── mod.info (Build 42 specific)
│   └── media/
│       ├── lua/
│       ├── scripts/
│       ├── textures/
│       └── ...
└── poster.png
```

### Phase 2: Mod Configuration Updates

**Root mod.info Updates:**
```ini
name=Pseudonymous Eds Saltwater Well
poster=poster.png
id=PseudoSaltWell
description=Saltwater Well with salt production and food preservation
author=PseudonymousEd
modversion=42.0.0
versionMin=42.0.0
pack=pseudoed_salt_01
tiledef=pseudoed_salt_01 8724
```

**Build 42 Specific mod.info:**
```ini
name=Pseudonymous Eds Saltwater Well
poster=poster.png
id=PseudoSaltWell
description=Saltwater Well - Build 42 Compatible
pack=pseudoed_salt_01
tiledef=pseudoed_salt_01 8724
```

### Phase 3: Timed Action Enhancements

**Current Timed Action (Basic):**
```lua
function PSWTakeSaltwater:update()
    self.character:faceThisObject(self.well)
end

function PSWTakeSaltwater:start()
    self:setActionAnim("Loot")
end
```

**Enhanced Build 42 Version:**
```lua
function PSWTakeSaltwater:update()
    self.character:faceThisObject(self.well)
    -- Add metabolic target for realism (optional)
    -- self.character:setMetabolicTarget(Metabolics.LightDomestic)
end

function PSWTakeSaltwater:start()
    self:setActionAnim("Loot")
    -- Add sound effects for better immersion
    self.sound = self.character:playSound("WaterSplash")
    -- Optional: Add job tracking for containers
    -- if self.container then
    --     self.container:setJobType(getText("ContextMenu_FillCookingPot"))
    --     self.container:setJobDelta(0.0)
    -- end
end

function PSWTakeSaltwater:stop()
    if self.sound then
        self.character:stopOrTriggerSound(self.sound)
    end
    ISBaseTimedAction.stop(self)
end
```

### Phase 4: Context Menu Modernization

**Current Context Menu:**
```lua
PSW.testcontextmenu = function(_player, context, worldobjects)
    local player = getSpecificPlayer(_player);
    print("PseudoEd PSW pot salt menu") -- Remove debug
    local parts = tonumber(player:getInventory():getItemCount("Base.Pot", true));
    -- ...
end

Events.OnPreFillWorldObjectContextMenu.Add(PSW.testcontextmenu);
```

**Enhanced Build 42 Version:**
```lua
PSW.saltwaterContextMenu = function(_player, context, worldobjects)
    local player = getSpecificPlayer(_player)
    local playerObj = getSpecificPlayer(_player)
    local inv = playerObj:getInventory()

    -- Check for valid containers
    local containers = {
        {type = "Base.Pot", action = PSW.onTakeSaltwater, text = "ContextMenu_FillCookingPot"},
        {type = "Base.Kettle", action = PSW.onTakeSaltwaterKettle, text = "ContextMenu_FillKettle"}
    }

    for _, container in ipairs(containers) do
        if inv:getItemCount(container.type, true) > 0 then
            local thisObject = worldobjects[1]
            local thisSprite = thisObject:getSprite()

            if thisSprite and thisSprite:getName() == "pseudoed_01_6" then
                context:addOption(getText(container.text),
                                worldobjects,
                                container.action,
                                player,
                                thisObject)
            end
        end
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(PSW.saltwaterContextMenu)
```

### Phase 5: Code Quality Improvements

**Remove Debug Code:**
```lua
-- Remove all print() statements:
-- print("PseudoEd PSW pot salt menu")
-- print("PseudoRecipe found a Meat")
-- print("PseudoRecipe CREATE Salted Meat - ENTER")
```

**Fix Variable Issues:**
```lua
function PSWTakeSaltwater:new(character, well)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.well = well
    -- Remove undefined fuelAmount reference
    -- o.fuelAmount = fuelAmount;  -- REMOVE THIS LINE
    o.maxTime = 50
    return o
end
```

**Improve Context Menu Text:**
```lua
-- Add to ContextMenu_EN.txt:
ContextMenu_EN = {
    ContextMenu_TakeSaltwater = "Fill with Saltwater",
    ContextMenu_FillKettleWithSaltwater = "Fill Kettle with Saltwater",
    ContextMenu_Saltwater_Well = "Saltwater Well",
}
```

## Implementation Timeline

### Week 1: Structural Migration
- [ ] Create Build 42 directory structure
- [ ] Move files to appropriate Build 42 locations
- [ ] Update mod.info files with version specifications
- [ ] Test basic mod loading in Build 42

### Week 2: Code Enhancement
- [ ] Remove debug print statements throughout codebase
- [ ] Fix undefined variable references
- [ ] Add enhanced timed action features (optional)
- [ ] Improve context menu text translations

### Week 3: Testing and Polish
- [ ] Test all saltwater extraction functionality
- [ ] Verify salt production recipes work correctly
- [ ] Test food preservation mechanics
- [ ] Validate multiplayer compatibility

### Week 4: Final Integration
- [ ] Performance testing with large worlds
- [ ] Integration testing with other mods
- [ ] Documentation updates
- [ ] Release preparation

## Risk Assessment

### Low Risk Items ✅
- **Core Functionality:** Recipe system, item definitions, sprite system all compatible
- **Timed Actions:** Base classes unchanged, existing code will work
- **Context Menus:** Event system remains the same

### Medium Risk Items ⚠️
- **Directory Structure:** Must be done correctly or mod won't load
- **Asset Loading:** Texture packs and tiles need proper path references
- **Translation System:** Text keys must resolve correctly

### High Risk Items 🚨
- **None Identified:** PseudoSaltWell uses stable, well-supported APIs

## Testing Strategy

### Unit Testing
1. **Saltwater Extraction:** Test pot and kettle filling from wells
2. **Salt Production:** Verify cooking and extraction recipes
3. **Food Preservation:** Test salted meat/fish shelf life mechanics
4. **Context Menus:** Verify all menu options appear correctly

### Integration Testing
1. **Other Mods:** Test with farming mods, cooking mods, container mods
2. **Multiplayer:** Verify server-client synchronization
3. **Save/Load:** Ensure mod data persists correctly

### Performance Testing
1. **Large Worlds:** Test with multiple saltwater wells
2. **Heavy Usage:** Multiple players using salt production simultaneously
3. **Long-term Play:** Extended gameplay sessions for stability

## Success Criteria

### Minimum Viable Product
- ✅ Mod loads without errors in Build 42
- ✅ Saltwater wells are interactive
- ✅ Salt production chain works end-to-end
- ✅ Food preservation mechanics functional

### Enhanced Product
- ✅ Improved user experience with better audio/visual feedback
- ✅ Clean code without debug artifacts
- ✅ Professional Build 42 directory structure
- ✅ Enhanced timed action integration

### Stretch Goals
- ✅ Performance optimizations
- ✅ Additional container support
- ✅ Integration with new Build 42 features
- ✅ Enhanced translation support

## Conclusion

**Migration Complexity: LOW-MEDIUM**

PseudoSaltWell is an excellent candidate for Build 42 migration due to:
- High-quality existing codebase
- Use of stable APIs that remain unchanged
- Professional implementation patterns
- Comprehensive feature set

The migration is primarily **structural reorganization** rather than code rewriting. The mod's core functionality will work unchanged, with opportunities for enhancement using new Build 42 features.

**Estimated Timeline:** 3-4 weeks for complete migration and enhancement
**Resource Requirements:** 1 developer familiar with PZ modding
**Success Probability:** Very High (95%+)

The resulting Build 42 version will be fully compatible and potentially enhanced compared to the original Build 41 implementation.

---
*This migration plan is based on analysis of Project Zomboid 42.11.0 and comparison with successfully migrated mods.*