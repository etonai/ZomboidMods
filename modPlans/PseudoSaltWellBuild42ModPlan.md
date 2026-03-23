# PseudoSaltWellB42 - Progressive Mod Development Plan

**Mod Name:** PseudoSaltWellB42
**Created:** 2025-10-12
**Target:** Project Zomboid Build 42.11.0
**Approach:** Progressive development through smaller, testable mods

---

## Overview

Instead of creating one complex mod that's hard to debug, we'll build a series of progressively more complex mods that each add specific functionality. Each mod builds on proven concepts from previous mods, making it easier to identify where problems occur.

---

## Primary Goals

1. **Dig Well**: Create a context menu on shovels to "Dig Well" (similar to digging graves)
2. **Well Tile Placement**: Replace ground tile with well tile (similar to campfire placement)
3. **Fill Container**: Add context menu on well tile to fill pots with saltwater brine

---

## Optional Goals (Future Expansion)

1. **Location-Based Wells**: Wells only placeable at certain coordinates
2. **Multiple Containers**: Support filling kettles and other containers
3. **Water Type by Location**: Coordinates determine if well produces saltwater or freshwater

---

## Game Mechanics Reference

### Grave Digging System (ISEmptyGraves.lua)
**Key Components:**
- Extends `ISBuildingObject`
- Uses shovel item with `DigGrave` tag
- Checks for natural ground floors (`floors_exterior_natural` or `blends_natural_01`)
- Places 2-tile object (grave head + grave foot)
- Uses `IsoThumpable` for world object
- Sets modData for state tracking
- Action: `maxTime = 150`, `actionAnim = BuildingHelper.getShovelAnim()`
- Validates z-level (must be 0)

### Campfire System (SCampfireSystem.lua, campingCampfire.lua)
**Key Components:**
- Places tile using `IsoObject` or `IsoThumpable`
- Uses sprite name for tile definition
- Context menu via `ISCampingMenu`
- Global object system for persistence
- State tracking via modData
- Fuel and lit state management

---

## Progressive Mod Sequence

### Mod 1: **PseudoSaltWellB42_Part1_SimpleWellDig** (Simplest - Foundation)

**Mod Name:** PseudoSaltWellB42_Part1_SimpleWellDig
**Purpose:** Prove we can add a "Dig Well" action to shovels that places a single tile.

**Components:**
1. **Item Script** (none needed - uses vanilla shovel)
   - Tag check: `DigGrave` (reuse grave digging tag)

2. **Building Object** (`ISSimpleWell.lua`)
   - File: `42/media/lua/server/BuildingObjects/ISSimpleWell.lua`
   - Extends `ISBuildingObject`
   - Single tile placement (1x1)
   - Sprite: `"location_community_cemetary_01_33"` (empty grave hole - temporary)
   - Ground validation: Natural floors only
   - Z-level: Ground level only (z=0)
   - Properties:
     ```lua
     maxTime = 150
     actionAnim = BuildingHelper.getShovelAnim(equipBothHandItem)
     craftingBank = "Shoveling"
     ```

3. **Context Menu** (`SimpleWellMenu.lua`)
   - File: `42/media/lua/client/SimpleWellMenu.lua`
   - Hook: `Events.OnFillWorldObjectContextMenu`
   - Check for shovel in inventory
   - Check for valid ground
   - Add "Dig Well" option
   - Trigger: `ISSimpleWell:new()`

4. **Mod Structure:**
   ```
   PseudoSaltWellB42_Part1_SimpleWellDig/
   ├── mod.info (id=PseudoSaltWellB42_Part1)
   ├── poster.png
   └── 42/
       └── media/
           └── lua/
               ├── client/
               │   └── SimpleWellMenu.lua
               └── server/
                   └── BuildingObjects/
                       └── ISSimpleWell.lua
   ```

**Success Criteria:**
- ✓ Shovel context menu shows "Dig Well"
- ✓ Player performs digging animation
- ✓ Single tile appears on ground
- ✓ Only works on natural ground at z=0

---

### Mod 2: **PseudoSaltWellB42_Part2_WellTileCustom** (Add Custom Tile)

**Mod Name:** PseudoSaltWellB42_Part2_WellTileCustom
**Purpose:** Replace temporary sprite with actual well tile graphic.

**Components:**
1. **Tile Definition** (`well_tiles.tiles`)
   - File: `42/media/well_tiles.tiles`
   - Define well tile sprite
   - Tile ID range: 8724+ (avoid conflicts)

2. **Texture Pack** (`well_textures.pack`)
   - File: `42/media/texturepacks/well_textures.pack`
   - Contains well tile graphics

3. **Texture Files** (`textures/`)
   - File: `42/media/textures/well_*.png`
   - Well tile graphics (top view)

4. **Updated Building Object** (`ISWellWithTile.lua`)
   - File: `42/media/lua/server/BuildingObjects/ISWellWithTile.lua`
   - Use custom sprite: `"well_tiles_01_0"` (or similar)
   - Otherwise same as Mod 1

5. **Mod.info Update:**
   ```
   pack=well_textures
   tiledef=well_tiles 8724
   ```

**Success Criteria:**
- ✓ Well displays custom graphic
- ✓ Tile looks appropriate for a well
- ✓ All Mod 1 functionality still works

---

### Mod 3: **PseudoSaltWellB42_Part3_WellFillPot** (Add Container Filling)

**Mod Name:** PseudoSaltWellB42_Part3_WellFillPot
**Purpose:** Add context menu on well tile to fill pots with saltwater.

**Dependencies:**
- Requires **PseudoSaltRecipes** mod (provides SaltwaterPot item)

**Components:**
1. **Well Object Enhancement** (`ISWellFillable.lua`)
   - File: `42/media/lua/server/BuildingObjects/ISWellFillable.lua`
   - Create well as `IsoThumpable` (not just sprite)
   - Set object name: `setName("SaltwaterWell")`
   - Add modData for well state
   - Enable interaction

2. **Context Menu Handler** (`WellContextMenu.lua`)
   - File: `42/media/lua/client/WellContextMenu.lua`
   - Hook: `Events.OnPreFillWorldObjectContextMenu`
   - Detect well object by name
   - Check player inventory for pot (`Base.Pot`)
   - Add "Fill Pot with Saltwater" option
   - Trigger timed action

3. **Timed Action** (`ISFillPotFromWell.lua`)
   - File: `42/media/lua/client/TimedActions/ISFillPotFromWell.lua`
   - Extends `ISBaseTimedAction`
   - Animation: `setActionAnim("Loot")`
   - Duration: `maxTime = 50`
   - On completion:
     - Remove `Base.Pot` from inventory
     - Add `Pseudonymous.SaltwaterPot` to inventory

4. **Translation File** (`ContextMenu_EN.txt`)
   - File: `42/media/lua/shared/Translate/EN/ContextMenu_EN.txt`
   - Add: `ContextMenu_FillPotFromWell = "Fill Pot with Saltwater"`

**Success Criteria:**
- ✓ Right-click well shows "Fill Pot with Saltwater"
- ✓ Option only appears if player has pot
- ✓ Player performs looting animation
- ✓ Pot replaced with SaltwaterPot

---

### Mod 4: **PseudoSaltWellB42_Part4_LocationBasedHoleType** (Location-Based Hole Type)

**Mod Name:** PseudoSaltWellB42_Part4_LocationBasedHoleType
**Purpose:** Determine hole type based on location. If location is in saltwater zone list, create a saltwater well. Otherwise, create just a plain hole.

**Dependencies:**
- Requires **PseudoSaltRecipes** mod (provides SaltwaterPot item)
- Builds on **Mod 3**

**Components:**
1. **Location Detector** (`SaltwaterLocationDetector.lua`)
   - File: `42/media/lua/shared/SaltwaterLocationDetector.lua`
   - Function: `isSaltwaterLocation(x, y)`
   - Check if coordinates are in saltwater zone list
   - Returns: `true` (saltwater well) or `false` (plain hole)

2. **Configuration File** (`saltwater_locations.lua`)
   - File: `42/media/lua/shared/saltwater_locations.lua`
   - Define saltwater well zones (specific tile coordinates):
     ```lua
     SaltwaterLocations = {
         { x1=8163, y1=12213, x2=8163, y2=12213 }, -- First saltwater well location
         { x1=8165, y1=12212, x2=8165, y2=12212 }, -- Second saltwater well location
     }
     ```
   - These are single-tile locations for initial testing
   - Can be expanded to zones later if needed

3. **Updated Building Object** (`ISLocationBasedHole.lua`)
   - File: `42/media/lua/server/BuildingObjects/ISLocationBasedHole.lua`
   - In `create()` method:
     - Check placement location using `isSaltwaterLocation(x, y)` where `x, y` are the coordinates where player selected to place the hole
     - If saltwater location (8163,12213 or 8165,12212): Create `IsoThumpable` with name "SaltwaterWell", sprite `"pseudoed_01_6"` (well sprite)
     - If not saltwater location: Create simple hole with sprite `"location_community_cemetary_01_33"` (grave hole sprite), no interaction
   - Example implementation:
     ```lua
     function ISLocationBasedHole:create(x, y, z, north, sprite)
         local cell = getWorld():getCell()
         local sq = cell:getGridSquare(x, y, z)

         -- Check if the selected location is in a saltwater zone
         if SaltwaterLocationDetector.isSaltwaterLocation(x, y) then
             -- Create saltwater well
             self.javaObject = IsoThumpable.new(cell, sq, "pseudoed_01_6", north, self)
             self.javaObject:setName("SaltwaterWell")
         else
             -- Create plain hole
             self.javaObject = IsoThumpable.new(cell, sq, "location_community_cemetary_01_33", north, self)
             self.javaObject:setName("Hole")
         end

         sq:AddSpecialObject(self.javaObject)
         self.javaObject:transmitCompleteItemToClients()
     end
     ```

4. **Well Type Tracking:**
   - Store hole type in modData on creation
   - Saltwater wells: `setName("SaltwaterWell")`, enable context menu interaction
   - Plain holes: Different name (e.g., "Hole"), no context menu interaction

5. **Context Menu Handler Update:**
   - Only show "Fill Pot with Saltwater" for objects named "SaltwaterWell"
   - Plain holes show no interaction options

**Success Criteria:**
- ✓ Digging in saltwater zone creates interactive saltwater well with well sprite
- ✓ Digging outside saltwater zone creates plain decorative hole with grave hole sprite
- ✓ Context menu only appears on saltwater wells
- ✓ Can fill pots from saltwater wells but not from plain holes
- ✓ Hole types use different sprites (well vs grave hole)

---

### Mod 5: **PseudoSaltWellB42_Part5_IndependentItems** (Remove PseudoSaltRecipes Dependency)

**Mod Name:** PseudoSaltWellB42_Part5_IndependentItems
**Purpose:** Remove dependency on PseudoSaltRecipes mod by adding SaltwaterPot and SaltwaterKettle items directly to PseudoSaltWellB42. Add ability to empty these containers and extract salt.

**Dependencies:**
- **None** - This mod is completely standalone
- Builds on **Mod 4**

**Components:**
1. **Item Definitions** (`PseudoSaltWellItems.txt`)
   - File: `42/media/scripts/items/PseudoSaltWellItems.txt`
   - Define items in `PseudoSaltWellB42` module (not `Pseudonymous`):
     - `PseudoSaltWellB42.SaltwaterPot` - Pot filled with saltwater
     - `PseudoSaltWellB42.SaltwaterKettle` - Kettle filled with saltwater
     - `PseudoSaltWellB42.SaltPot` - Pot with salt (after cooking)
     - `PseudoSaltWellB42.SaltKettle` - Kettle with salt (after cooking)
   - Key properties:
     ```
     item SaltwaterPot {
         Weight = 4
         DisplayName = Cooking Pot with Saltwater
         Icon = Pot_Water
         IsCookable = true
         ReplaceOnCooked = PseudoSaltWellB42.SaltPot
         ReplaceOnUse = Pot  // Returns empty pot when drunk
         ReplaceOnUseOn = Pot  // Returns empty pot when poured
         // DO NOT add PourType or EatType - breaks emptying!
     }

     item SaltPot {
         Weight = 1.3
         DisplayName = Cooking Pot with Salt
         Icon = Pot
         ReplaceOnUse = Pot  // Returns empty pot when used
         ReplaceOnUseOn = Pot  // Returns empty pot when poured
         // DO NOT add PourType or EatType
     }
     ```

2. **Update Timed Actions** (`ISFillPotFromWell.lua`, `ISFillKettleFromWell.lua`)
   - Change item names from `Pseudonymous.SaltwaterPot` to `PseudoSaltWellB42.SaltwaterPot`
   - Change item names from `Pseudonymous.SaltwaterKettle` to `PseudoSaltWellB42.SaltwaterKettle`

3. **Add Kettle Support** (`ISFillKettleFromWell.lua`)
   - File: `42/media/lua/shared/TimedActions/ISFillKettleFromWell.lua`
   - Same structure as `ISFillPotFromWell.lua` but for kettles
   - Creates `PseudoSaltWellB42.SaltwaterKettle` item

4. **Update Context Menu** (`WellFillMenu.lua`)
   - Add option for filling kettles
   - Check for both `Base.Pot` and `Base.Kettle` in inventory
   - Show appropriate menu options for each container type

5. **Add Empty Container Actions** (`ISEmptySaltwaterContainer.lua`)
   - File: `42/media/lua/shared/TimedActions/ISEmptySaltwaterContainer.lua`
   - Timed action to pour out saltwater
   - Animation: `setActionAnim("Pour")`
   - Duration: `maxTime = 50`
   - **IMPORTANT**: Must explicitly remove old item and add new item in `perform()`:
     ```lua
     function ISEmptySaltwaterContainer:perform()
         self.character:getInventory():Remove(self.container);
         self.character:getInventory():AddItem(self.emptyType);  -- "Pot" or "Kettle"
         ISBaseTimedAction.perform(self);
     end
     ```
   - Cannot rely on `ReplaceOnUseOn` - must manually handle replacement
   - Allows player to empty containers before cooking (if they change their mind)

6. **Empty Container Context Menu** (`EmptySaltwaterMenu.lua`)
   - File: `42/media/lua/client/EmptySaltwaterMenu.lua`
   - Hook: `Events.OnFillInventoryObjectContextMenu`
   - Check for `PseudoSaltWellB42.SaltwaterPot` or `PseudoSaltWellB42.SaltwaterKettle` in inventory
   - Add "Empty Container" option
   - Determine empty container type (Pot or Kettle) and pass to timed action
   - Trigger `ISEmptySaltwaterContainer` timed action

7. **Container Behavior:**
   - **Empty via context menu**: Returns empty pot/kettle (before cooking) - uses Lua timed action
   - **Use after cooking**: `ReplaceOnUse` returns empty pot/kettle (after salt extracted) - automatic
   - Players can choose to empty or cook the saltwater
   - **Critical Implementation Note**: Do NOT add `PourType` or `EatType` to saltwater containers in item definitions - this causes the vanilla "Pour on Ground" action to appear, which doesn't properly handle container replacement and causes items to disappear

**Success Criteria:**
- ✓ Mod works without PseudoSaltRecipes installed
- ✓ Can fill pots from saltwater wells → creates PseudoSaltWellB42.SaltwaterPot
- ✓ Can fill kettles from saltwater wells → creates PseudoSaltWellB42.SaltwaterKettle
- ✓ Can empty saltwater containers via context menu → returns empty pot/kettle
- ✓ Cooking saltwater pots/kettles produces salt containers
- ✓ Using/drinking from salt containers returns empty pot/kettle
- ✓ Players can choose to empty or cook saltwater containers

---

## Technical Components Breakdown

### Core Files Needed (All Mods)

**Mod.info Example (Part 1):**
```
name=PseudoSaltWellB42 Part 1: Simple Well Dig
id=PseudoSaltWellB42_Part1
description=Adds ability to dig wells with shovels (Part 1 of 5)
poster=poster.png
```

**Mod.info Example (Part 2+):**
```
name=PseudoSaltWellB42 Part 2: Custom Well Tile
id=PseudoSaltWellB42_Part2
description=Adds custom well graphics (Part 2 of 5)
poster=poster.png
pack=well_textures
tiledef=well_tiles 8724
```

**Directory Structure:**
```
PseudoSaltWellB42_Part[N]_[Name]/
├── mod.info
├── poster.png
└── 42/
    └── media/
        ├── lua/
        │   ├── client/
        │   │   ├── TimedActions/
        │   │   └── WellMenu.lua
        │   ├── server/
        │   │   └── BuildingObjects/
        │   └── shared/
        │       └── Translate/
        │           └── EN/
        ├── scripts/
        ├── texturepacks/      (Part 2+)
        ├── textures/          (Part 2+)
        └── well_tiles.tiles   (Part 2+)
```

---

## Key Lua Patterns to Follow

### Building Object Pattern:
```lua
ISWellObject = ISBuildingObject:derive("ISWellObject");

function ISWellObject:create(x, y, z, north, sprite)
    local cell = getWorld():getCell();
    local sq = cell:getGridSquare(x, y, z);

    -- Create IsoThumpable object
    self.javaObject = IsoThumpable.new(cell, sq, sprite, north, self);
    sq:AddSpecialObject(self.javaObject);

    -- Set properties
    self.javaObject:setName("SaltwaterWell");
    self.javaObject:setCanBarricade(false);
    self.javaObject:setIsThumpable(false);

    -- Set modData
    self.javaObject:getModData()["waterType"] = "saltwater";

    self.javaObject:transmitCompleteItemToClients();
end

function ISWellObject:new(sprite, equipBothHandItem)
    local o = ISBuildingObject.new(self)
    o:init();
    o:setSprite(sprite);
    o.noNeedHammer = true;
    o.equipBothHandItem = equipBothHandItem;
    o.maxTime = 150;
    o.actionAnim = BuildingHelper.getShovelAnim(equipBothHandItem);
    o.craftingBank = "Shoveling";
    return o;
end

function ISWellObject:isValid(square)
    if square:getZ() > 0 then return false end

    local floor = square:getFloor();
    if not floor then return false end

    local texture = floor:getTextureName();
    if not (luautils.stringStarts(texture, "floors_exterior_natural") or
            luautils.stringStarts(texture, "blends_natural_01")) then
        return false
    end

    return ISBuildingObject.isValid(self, square)
end
```

### Context Menu Pattern:
```lua
WellMenu = {};

WellMenu.onFillPot = function(worldobjects, player, wellObject)
    if luautils.walkAdj(player, wellObject:getSquare()) then
        ISTimedActionQueue.add(ISFillPotFromWell:new(player, wellObject));
    end
end

WellMenu.createMenu = function(player, context, worldobjects)
    local playerObj = getSpecificPlayer(player);

    -- Check if player has pot
    if playerObj:getInventory():getItemCount("Base.Pot", true) == 0 then
        return
    end

    -- Find well object
    local wellObject = nil;
    for _, obj in ipairs(worldobjects) do
        if obj:getName() == "SaltwaterWell" then
            wellObject = obj;
            break;
        end
    end

    if wellObject then
        context:addOption(
            getText("ContextMenu_FillPotFromWell"),
            worldobjects,
            WellMenu.onFillPot,
            playerObj,
            wellObject
        );
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(WellMenu.createMenu);
```

### Timed Action Pattern:
```lua
require "TimedActions/ISBaseTimedAction"

ISFillPotFromWell = ISBaseTimedAction:derive("ISFillPotFromWell");

function ISFillPotFromWell:isValid()
    return self.character:getInventory():contains("Pot", true)
end

function ISFillPotFromWell:waitToStart()
    self.character:faceThisObject(self.well)
    return self.character:shouldBeTurning()
end

function ISFillPotFromWell:update()
    self.character:faceThisObject(self.well)
end

function ISFillPotFromWell:start()
    self:setActionAnim("Loot")
end

function ISFillPotFromWell:stop()
    ISBaseTimedAction.stop(self);
end

function ISFillPotFromWell:perform()
    self.character:getInventory():Remove("Pot");
    self.character:getInventory():AddItem("Pseudonymous.SaltwaterPot");
    ISBaseTimedAction.perform(self);
end

function ISFillPotFromWell:new(character, well)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.well = well
    o.maxTime = 50
    return o;
end
```

---

## Testing Strategy

### Mod 1 Testing:
1. Load game with SimpleWellDig
2. Equip shovel
3. Right-click natural ground
4. Verify "Dig Well" appears
5. Execute action
6. Verify tile appears

### Mod 2 Testing:
1. Complete Mod 1 tests
2. Verify custom tile graphic displays
3. Check tile appears correctly in game

### Mod 3 Testing:
1. Load with PseudoSaltRecipes mod
2. Complete Mod 2 tests
3. Obtain pot (vanilla or debug)
4. Right-click well with pot in inventory
5. Verify "Fill Pot" option
6. Execute action
7. Verify SaltwaterPot in inventory

### Mod 4 Testing:
1. Complete Mod 3 tests
2. Navigate to coordinates 8163, 12213
3. Dig hole at that exact location
4. Verify saltwater well created with well sprite (can fill pots)
5. Navigate to coordinates 8165, 12212
6. Dig hole at that exact location
7. Verify saltwater well created with well sprite (can fill pots)
8. Dig hole at any other location
9. Verify plain hole created with grave sprite (no context menu)
10. Test that only saltwater wells allow pot filling

### Mod 5 Testing:
1. Disable PseudoSaltRecipes mod
2. Load Mod 5 only
3. Dig saltwater well at valid location
4. Obtain vanilla pot and kettle
5. Right-click saltwater well with pot → verify "Fill Pot with Saltwater" option
6. Fill pot → verify PseudoSaltWellB42.SaltwaterPot created
7. Right-click saltwater pot in inventory → verify "Empty Container" option
8. Empty saltwater pot → verify empty Pot returned
9. Fill pot again from well
10. Cook saltwater pot → verify PseudoSaltWellB42.SaltPot created
11. Use/drink salt pot → verify empty Pot returned
12. Right-click saltwater well with kettle → verify "Fill Kettle with Saltwater" option
13. Fill kettle → verify PseudoSaltWellB42.SaltwaterKettle created
14. Right-click saltwater kettle in inventory → verify "Empty Container" option
15. Empty saltwater kettle → verify empty Kettle returned
16. Fill kettle again from well
17. Cook saltwater kettle → verify PseudoSaltWellB42.SaltKettle created
18. Use/drink salt kettle → verify empty Kettle returned

---

## Dependencies

### External Mods Required:
- **PseudoSaltRecipes** (Mods 3+)
  - Provides: `Pseudonymous.SaltwaterPot`
  - Provides: `Pseudonymous.SaltwaterKettle`
  - Provides: Salt extraction recipes

### Vanilla Game Systems Used:
- `ISBuildingObject` - Base building class
- `IsoThumpable` - World object class
- `ISBaseTimedAction` - Timed action base class
- `BuildingHelper` - Building utility functions
- Shovel item with `DigGrave` tag
- Natural floor tiles

---

## Common Pitfalls to Avoid

1. **File Paths:** Always use correct `42/media/lua/` structure
2. **Event Hooks:** Use correct event names (e.g., `OnPreFillWorldObjectContextMenu`)
3. **Item Names:** Use full module.item format (e.g., `Base.Pot`, `Pseudonymous.SaltwaterPot`)
4. **Z-Level:** Validate z=0 for ground-level placement
5. **Floor Validation:** Check for natural floors before allowing placement
6. **ModData Sync:** Use `transmitCompleteItemToClients()` for multiplayer
7. **Translation Keys:** Define all text keys in translation files

---

## Success Metrics

### Mod 1:
- Can dig simple well
- Animation plays correctly
- Tile appears on ground

### Mod 2:
- Custom graphics display
- Tile looks appropriate

### Mod 3:
- Can fill pots from well
- SaltwaterPot item created correctly

### Mod 4:
- Location determines hole type (saltwater well vs plain hole)
- Saltwater wells functional, plain holes decorative only
- Context menu only on saltwater wells

### Mod 5:
- No external dependencies required
- Own SaltwaterPot and SaltwaterKettle items
- Supports both pot and kettle filling
- Automatic container emptying

---

## Future Enhancements

**Beyond Initial Scope:**
1. Well degradation over time
2. Water quality system
3. Well maintenance/repair
4. Pump addition for wells
5. Underground water source detection
6. Well cover/protection objects
7. Contamination system
8. Multiple water sources per well

---

## Naming Convention

**Overall Mod Series:** PseudoSaltWellB42

**Individual Parts:**
1. PseudoSaltWellB42_Part1_SimpleWellDig
2. PseudoSaltWellB42_Part2_WellTileCustom
3. PseudoSaltWellB42_Part3_WellFillPot
4. PseudoSaltWellB42_Part4_LocationBasedHoleType
5. PseudoSaltWellB42_Part5_IndependentItems

**Mod IDs:**
- PseudoSaltWellB42_Part1
- PseudoSaltWellB42_Part2
- PseudoSaltWellB42_Part3
- PseudoSaltWellB42_Part4
- PseudoSaltWellB42_Part5

---

## Version History

- **v1.0** (2025-10-12): Initial plan created
  - Defined 6 progressive mods
  - Documented all components
  - Created testing strategy
- **v1.1** (2025-10-12): Updated naming convention
  - Named series: PseudoSaltWellB42
  - Specified part naming: PseudoSaltWellB42_Part[N]_[Name]
  - Specified temporary sprite: location_community_cemetary_01_33
- **v1.2** (2025-10-13): Revised Mod 4, removed Mods 5-6
  - Mod 4 now location-based hole type (saltwater well vs plain hole)
  - Removed separate Mods 5 and 6
  - Series now consists of 4 progressive mods
- **v1.3** (2025-10-13): Added specific test coordinates for Mod 4
  - Saltwater well locations: (8163, 12213) and (8165, 12212)
  - Single-tile locations for initial testing
  - Added code example for ISLocationBasedHole:create()
- **v1.4** (2025-10-13): Added Mod 5 plan
  - Remove PseudoSaltRecipes dependency
  - Add SaltwaterPot and SaltwaterKettle items directly to mod
  - Add kettle filling support
  - Add empty container actions and salt extraction recipes
  - Series now consists of 5 progressive mods
- **v1.5** (2025-10-13): Added Mod 6 plan
  - Same as Mod 5 but with custom tiles
  - Create new well tile graphic
  - Create new hole tile graphic
  - Series now consists of 6 progressive mods

---

### Mod 6: **PseudoSaltWellB42_Part6_CustomTiles** (Custom Graphics for Wells and Holes)

**Mod Name:** PseudoSaltWellB42_Part6_CustomTiles
**Purpose:** Replace temporary sprites with custom-designed tiles for both saltwater wells and plain holes. This is identical to Mod 5 in functionality, but with custom graphics.

**Dependencies:**
- **None** - This mod is completely standalone
- Builds on **Mod 5**

**Components:**
1. **All Components from Mod 5** - Copy everything from Mod 5 as the base

2. **New Custom Tiles** (to be created by user)
   - **Saltwater Well Tile**: Custom graphic for interactive saltwater wells
     - Design should clearly indicate it's a well with water
     - Should look different from plain hole
     - Recommended size: 64x128 pixels (1x2 tiles) or 64x64 pixels (1x1 tile)

   - **Plain Hole Tile**: Custom graphic for decorative holes
     - Design should look like a dug hole without water
     - Should be clearly distinguishable from well
     - Recommended size: 64x64 pixels (1x1 tile)

3. **Tile Definition File** (`pseudoed_saltwell_01.tiles`)
   - File: `common/media/pseudoed_saltwell_01.tiles`
   - Define both tile sprites:
     ```
     tile pseudoed_saltwell_01_0
     {
         sprite = pseudoed_saltwell_01_0
     }

     tile pseudoed_saltwell_01_1
     {
         sprite = pseudoed_saltwell_01_1
     }
     ```

4. **Texture Pack** (`pseudoed_saltwell_01.pack`)
   - File: `common/media/texturepacks/pseudoed_saltwell_01.pack`
   - Contains compressed versions of tile graphics
   - Generated from texture files

5. **Texture Files** (`textures/`)
   - File: `common/media/textures/pseudoed_saltwell_01_0.png` (saltwater well graphic)
   - File: `common/media/textures/pseudoed_saltwell_01_1.png` (plain hole graphic)
   - User will create these custom graphics

6. **Updated Building Object** (`ISLocationBasedHole.lua`)
   - Change saltwater well sprite from `"pseudoed_01_6"` to `"pseudoed_saltwell_01_0"`
   - Change plain hole sprite from `"location_community_cemetary_01_33"` to `"pseudoed_saltwell_01_1"`
   - Example:
     ```lua
     if isSaltwater then
         -- Create saltwater well
         holeSprite = "pseudoed_saltwell_01_0";  -- NEW custom well tile
         holeName = "SaltwaterWell";
     else
         -- Create plain hole
         holeSprite = "pseudoed_saltwell_01_1";  -- NEW custom hole tile
         holeName = "Hole";
     end
     ```

7. **Updated Render Method** (`ISLocationBasedHole.lua`)
   - Update `render()` method to use new sprite names
   - Ensure ghost tile shows correct custom graphic based on location

8. **Mod.info Update:**
   ```
   name=PseudoSaltWellB42 Part 6: Custom Tiles
   id=PseudoSaltWellB42_Part6_CustomTiles
   description=Independent saltwater well system with custom graphics. Create saltwater wells at specific coordinates or plain holes elsewhere. Fill pots and kettles with saltwater, cook to create salt. Fully standalone with custom well and hole graphics.
   poster=poster.png
   pack=pseudoed_saltwell_01
   tiledef=pseudoed_saltwell_01 8724
   ```

**Tile Creation Process:**
1. User creates two PNG images:
   - Saltwater well graphic (shows water in hole)
   - Plain hole graphic (shows empty dug hole)
2. Save as `pseudoed_saltwell_01_0.png` and `pseudoed_saltwell_01_1.png`
3. Place in `common/media/textures/` directory
4. Create tile definition file
5. Generate texture pack (or let game generate it)

**Sprite Naming Convention:**
- Tileset name: `pseudoed_saltwell_01`
- Saltwater well: `pseudoed_saltwell_01_0`
- Plain hole: `pseudoed_saltwell_01_1`
- Starting tile ID: 8724 (to avoid conflicts)

**Success Criteria:**
- ✓ All Mod 5 functionality works identically
- ✓ Saltwater wells display custom well graphic (not borrowed sprite)
- ✓ Plain holes display custom hole graphic (not grave sprite)
- ✓ Graphics are clearly distinguishable from each other
- ✓ Ghost tiles show correct custom graphics during placement
- ✓ Mod works without PseudoSaltRecipes installed
- ✓ Can fill pots and kettles from saltwater wells
- ✓ Can empty saltwater containers
- ✓ Can extract salt from cooked containers

**Testing:**
1. Complete all Mod 5 tests to ensure functionality unchanged
2. Verify custom saltwater well graphic displays at valid coordinates
3. Verify custom hole graphic displays at invalid coordinates
4. Confirm graphics are visually appropriate and distinguishable
5. Test ghost tile rendering shows correct graphics
6. Ensure no visual glitches or tile errors

**Directory Structure:**
```
PseudoSaltWellB42_Part6_CustomTiles/
├── mod.info (with pack and tiledef)
├── poster.png
├── 42/
│   └── media/
│       ├── lua/
│       │   ├── client/
│       │   │   ├── WellFillMenu.lua
│       │   │   ├── EmptySaltwaterMenu.lua
│       │   │   └── LocationBasedHoleMenu.lua
│       │   ├── server/
│       │   │   └── BuildingObjects/
│       │   │       └── ISLocationBasedHole.lua (UPDATED with new sprite names)
│       │   └── shared/
│       │       ├── SaltwaterLocationDetector.lua
│       │       └── TimedActions/
│       │           ├── ISFillPotFromWell.lua
│       │           ├── ISFillKettleFromWell.lua
│       │           └── ISEmptySaltwaterContainer.lua
│       └── scripts/
│           ├── items/
│           │   └── PseudoSaltWellItems.txt
│           └── recipes/
│               └── PseudoSaltWellRecipes.txt
└── common/
    └── media/
        ├── pseudoed_saltwell_01.tiles (NEW)
        ├── texturepacks/
        │   └── pseudoed_saltwell_01.pack (NEW)
        └── textures/
            ├── pseudoed_saltwell_01_0.png (NEW - saltwater well graphic)
            └── pseudoed_saltwell_01_1.png (NEW - plain hole graphic)
```

**Key Differences from Mod 5:**
- Mod 5 uses borrowed sprites (`pseudoed_01_6` for well, `location_community_cemetary_01_33` for hole)
- Mod 6 uses custom-created sprites (`pseudoed_saltwell_01_0` for well, `pseudoed_saltwell_01_1` for hole)
- All Lua code is identical except sprite name constants
- Adds tile definition files and texture assets
- Mod.info includes pack and tiledef entries

**Implementation Notes:**
- Start by copying entire Mod 5 directory structure
- Only changes needed are sprite names in `ISLocationBasedHole.lua`
- User must create the two custom tile graphics
- Tile graphics should be visually distinct and clear in purpose
- Consider using different colors/styles to differentiate well from hole

---

**End of Plan**
