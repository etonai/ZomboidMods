# Root Cellar Box Mod - Development Plan

**Mod Name:** Root Cellar Box
**Created:** October 8, 2025
**Target Version:** Project Zomboid 42.11.0
**Complexity:** Moderate

## Mod Concept

A **Root Cellar Box** that looks and functions like a regular wooden crate but provides refrigeration when placed underground (z < 0). This leverages the natural cooling properties of underground spaces for food preservation without requiring electricity.

## Core Mechanics

### Visual Design
- **Appearance:** Identical to existing wooden crate
- **Capacity:** Same as regular wooden crate (50 units)
- **Placement:** Can be placed anywhere like normal crates

### Refrigeration Logic
- **Trigger Condition:** Container z-coordinate < 0 (underground/basement)
- **Above Ground:** Functions as normal wooden crate (no refrigeration)
- **Underground:** Acts as unpowered refrigerator with 2% food aging rate
- **Temperature:** 0.2°C when underground (same as powered fridge)

## Technical Implementation

### Phase 1: Basic Container Creation

#### File Structure
```
RootCellarBox/
├── mod.info
├── media/
│   ├── lua/
│   │   ├── server/
│   │   │   └── RootCellarBox.lua
│   │   └── shared/
│   │       ├── Definitions/
│   │       │   └── RootCellarBoxItems.lua
│   │       └── Moveables/
│   │           └── RootCellarBoxMoveables.lua
│   ├── scripts/
│   │   └── items_rootcellarbox.txt
│   └── textures/
│       └── Item_RootCellarBox.png (copy of wooden crate texture)
```

#### Item Definition (items_rootcellarbox.txt)
```
item RootCellarBox
{
    Weight = 5.0,
    Type = Normal,
    DisplayName = Root Cellar Box,
    Icon = WoodenCrate,
    WorldStaticModel = WoodenCrate,
    Tags = Container,
    CanBePlace = true,
}
```

#### Moveable Definition (RootCellarBoxMoveables.lua)
```lua
-- Based on existing wooden crate definition
ISMoveableSpriteProps.RootCellarBox = {
    sprite = "fixtures_containers_01_0", -- Same sprite as wooden crate
    northSprite = "fixtures_containers_01_1",
    eastSprite = "fixtures_containers_01_2",
    southSprite = "fixtures_containers_01_3",
    containerType = "crate",
    isContainer = true,
    canBeApplied = true,
}
```

### Phase 2: Location-Based Temperature Control

#### Core Logic (RootCellarBox.lua)
```lua
-- Track all root cellar boxes
RootCellarBoxes = {}

-- Container type identifier
ROOT_CELLAR_BOX_TYPE = "RootCellarBox"

-- Check if container is a root cellar box
function isRootCellarBox(container)
    if not container then return false end
    local parent = container:getParent()
    if not parent then return false end

    -- Check if the containing object is our root cellar box
    local sprite = parent:getSprite()
    if sprite and sprite:getName() then
        -- Match based on sprite or object name
        return sprite:getName() == "fixtures_containers_01_0" and
               parent:getModData().isRootCellarBox == true
    end
    return false
end

-- Check if location is underground
function isUnderground(container)
    if not container then return false end
    local parent = container:getParent()
    if not parent then return false end

    local square = parent:getSquare()
    if not square then return false end

    return square:getZ() < 0
end

-- Apply refrigeration based on location
function updateRootCellarBox(container)
    if not isRootCellarBox(container) then return end

    if isUnderground(container) then
        -- Underground: Act as refrigerator
        container:setCustomTemperature(0.2)  -- Fridge temperature
        container:setAgeFactor(0.02)         -- 2% aging rate (same as powered fridge)
        container:setCookingFactor(0.0)      -- No cooking
        container:getModData().isRefrigerating = true
    else
        -- Above ground: Normal container
        container:setCustomTemperature(1.0)  -- Room temperature
        container:setAgeFactor(1.0)          -- Normal aging
        container:setCookingFactor(1.0)      -- Normal cooking
        container:getModData().isRefrigerating = false
    end
end

-- Monitor all root cellar boxes
function checkAllRootCellarBoxes()
    for _, container in pairs(RootCellarBoxes) do
        if container and container:getParent() then
            updateRootCellarBox(container)
        else
            -- Clean up invalid references
            table.remove(RootCellarBoxes, _)
        end
    end
end

-- Register container when created
function onContainerCreate(container)
    if isRootCellarBox(container) then
        table.insert(RootCellarBoxes, container)
        updateRootCellarBox(container)
    end
end

-- Event handlers
Events.OnTick.Add(function()
    -- Check every 10 seconds (reduce performance impact)
    if getGameTime():getMinutes() % 10 == 0 then
        checkAllRootCellarBoxes()
    end
end)

Events.OnContainerUpdate.Add(onContainerCreate)
```

### Phase 3: Enhanced Features

#### Visual Feedback System
```lua
-- Add tooltip information
function addRootCellarTooltip(container)
    if not isRootCellarBox(container) then return end

    local parent = container:getParent()
    if not parent then return end

    local tooltip = parent:getTooltip() or ""

    if isUnderground(container) then
        tooltip = tooltip .. "\n" .. getText("IGUI_RootCellar_Cooling")
    else
        tooltip = tooltip .. "\n" .. getText("IGUI_RootCellar_Normal")
    end

    parent:setTooltip(tooltip)
end
```

#### Food Quality Indicators
```lua
-- Update food items when container changes state
function updateContainerFood(container)
    if not container then return end

    local items = container:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item:IsFood() then
            -- Force temperature update
            local temp = container:getCustomTemperature() or 1.0
            item:setHeat(temp)

            -- Update aging if underground
            if isUnderground(container) then
                item:setLastAged(getGameTime():getWorldAgeHours())
            end
        end
    end
end
```

### Phase 4: Integration and Polish

#### Building System Integration
```lua
-- Integrate with ISMoveableDefinitions
function addToMoveableSystem()
    -- Add to moveable items list
    local moveableItem = {
        name = "RootCellarBox",
        sprite = "fixtures_containers_01_0",
        northSprite = "fixtures_containers_01_1",
        eastSprite = "fixtures_containers_01_2",
        southSprite = "fixtures_containers_01_3",
        containerType = "crate",
        isContainer = true,
        canBePlace = true,
        scrapSize = 5,
        scrapThump = 3,
        scrapWeapon = 2,
        blockAllTheSquare = false,
        canBarricade = false,
        isThumpable = false,
        scrap = {
            "Base.Plank", "Base.Plank", "Base.Plank",
            "Base.Nails", "Base.Nails"
        }
    }

    ISMoveableDefinitions.RootCellarBox = moveableItem
end
```

#### Context Menu Integration
```lua
-- Add context menu option for regular wooden crates
function addRootCellarConversion(context, worldobjects, player)
    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()

    for _, obj in pairs(worldobjects) do
        if obj:getSprite() and obj:getSprite():getName() == "fixtures_containers_01_0" then
            -- Check if it's already a root cellar box
            if not obj:getModData().isRootCellarBox then
                -- Add conversion option (optional feature)
                local option = context:addOption(getText("ContextMenu_ConvertToRootCellar"))
                option:setOnClick(convertToRootCellar, obj, player)
            end
        end
    end
end

function convertToRootCellar(obj, player)
    obj:getModData().isRootCellarBox = true
    obj:transmitModData()

    -- Update container immediately
    local container = obj:getContainer()
    if container then
        updateRootCellarBox(container)
    end
end
```

## Implementation Timeline

### Week 1: Foundation
- [ ] Create basic mod structure and files
- [ ] Define root cellar box item and moveable
- [ ] Implement basic container creation system
- [ ] Test item placement and basic functionality

### Week 2: Core Logic
- [ ] Implement location detection (z < 0)
- [ ] Add temperature control system
- [ ] Create container monitoring system
- [ ] Test refrigeration functionality underground

### Week 3: Enhancement
- [ ] Add visual feedback and tooltips
- [ ] Implement food temperature updates
- [ ] Add performance optimizations
- [ ] Test in various basement/underground scenarios

### Week 4: Polish and Testing
- [ ] Add context menu integration (optional)
- [ ] Create comprehensive testing scenarios
- [ ] Optimize performance and memory usage
- [ ] Final testing and bug fixes

## Technical Challenges and Solutions

### Challenge 1: Container Detection
**Problem:** Identifying which containers are root cellar boxes
**Solution:** Use mod data flags and sprite matching

### Challenge 2: Performance
**Problem:** Checking z-coordinate frequently may impact performance
**Solution:** Update check every 10 game-minutes rather than every tick

### Challenge 3: Container State Persistence
**Problem:** Maintaining refrigeration state across save/load
**Solution:** Store state in container mod data with proper serialization

### Challenge 4: Moving Containers
**Problem:** Container moved from underground to surface or vice versa
**Solution:** Regular location checks and state updates

## Testing Plan

### Test Scenarios
1. **Basic Functionality**
   - Place root cellar box above ground → normal container behavior
   - Place root cellar box underground → refrigeration active
   - Move container between levels → state changes appropriately

2. **Food Preservation**
   - Store food underground → verify slow aging
   - Store food above ground → verify normal aging
   - Move food between containers → verify temperature changes

3. **Multiplayer Compatibility**
   - Test in multiplayer environment
   - Verify state synchronization between clients
   - Test container sharing between players

4. **Performance Testing**
   - Multiple root cellar boxes in same area
   - Large numbers of food items
   - Long-term gameplay sessions

## Success Criteria

- ✅ Root cellar box visually identical to wooden crate
- ✅ Same storage capacity as wooden crate
- ✅ Refrigeration only active when z < 0
- ✅ Food aging rate matches powered refrigerator when underground
- ✅ No performance impact during normal gameplay
- ✅ Compatible with existing save games
- ✅ Works in both single-player and multiplayer

## Future Enhancements

### Potential Additions
- **Ice Integration:** Require ice blocks for enhanced cooling
- **Humidity Control:** Different preservation rates based on container materials
- **Temperature Zones:** Different cooling effectiveness at different depths
- **Seasonal Effects:** Better cooling in winter, reduced effectiveness in summer
- **Root Vegetables:** Special bonuses for storing root vegetables
- **Multiple Sizes:** Small, medium, and large root cellar containers

### Advanced Features
- **Construction Recipe:** Require specific materials to build root cellar boxes
- **Insulation Upgrades:** Add materials to improve cooling efficiency
- **Ventilation System:** Prevent food spoilage through air circulation mechanics
- **Historical Accuracy:** Research real root cellar techniques for authentic mechanics

---

**Estimated Development Time:** 4 weeks
**Required Skills:** Lua scripting, Project Zomboid modding, game balance testing
**Dependencies:** Base game container system, temperature mechanics
**Risk Level:** Low - leverages proven techniques from existing mods