# Project Zomboid Mods Inventory - notmymods Directory

**Document Created:** 2025-10-12
**Project Zomboid Version:** 42.11.0
**Purpose:** Comprehensive catalog of third-party mods in the notmymods directory

## Overview

This document catalogs all mods located in the `notmymods/` directory. These are third-party mods being analyzed for functionality, mechanics, and potential reference for mod development.

---

## Mod Inventory

### 1. Cooler Backpack

**Mod ID:** Not specified (no mod.info file present)
**Author:** Unknown
**Version:** Build 42 compatible

**Description:**
Implements functional cooling for backpacks and containers with battery-powered temperature control system.

**Key Features:**
- Battery-powered cooling system for portable containers
- Custom temperature control (`setCustomTemperature`, `setAgeFactor`, `setCookingFactor`)
- Battery capacity tracking and consumption (0.01 per tick cycle)
- ModData storage for battery state persistence
- Nested container support (searches through inventory hierarchies)
- Tooltip display showing battery level (e.g., "50/100")

**Technical Implementation:**
- Uses `ModData.TCM.Battery` and `ModData.TCM.BatteryCapacity` for state tracking
- Cooling effect: `setCustomTemperature(0.01)`, `setAgeFactor(0.1)`, `setCookingFactor(0.0)`
- Battery drain: 0.01 per tick (approximately every 20 game ticks)
- Recursively searches for cooler containers in nested inventories

**Files:**
- `42/media/lua/client/Cooler_Upgrade.lua`
- `42/media/lua/server/coolerbackpack_food.lua`
- `42/media/lua/server/coolerbackpack.lua`

---

### 2. Diederiks Tile Palooza

**Mod ID:** Diederiks Tile Palooza
**Author:** Unknown
**URL:** http://theindiestone.com/forums

**Description:**
A mod to regulate custom tiles which are used in different mods. Provides a tile library/framework for other mods.

**Key Features:**
- Custom tile definitions starting at tile ID 7001
- Pack: `diederiks_tile_palooza`
- Tiledef: `diederikv_tile_def 7001`

**Purpose:** Framework/library mod for custom tiles used by multiple other mods

---

### 3. Eris Food Expiry

**Mod ID:** Not specified (no mod.info file present)
**Author:** Eris (with multiple translators)
**Version:** Build 42 compatible

**Description:**
Displays detailed food expiration information with visual progress bars and tooltips showing when food will become stale or rotten.

**Key Features:**
- Visual inventory bar showing food freshness
- Detailed tooltip with time until stale/rotten (years, months, weeks, days, hours, minutes, seconds)
- Respects sandbox settings (FridgeFactor, FoodRotSpeed)
- Optional Nutritionist trait requirement for detailed info
- Multi-language support (Russian, Chinese, Spanish, Portuguese, Czech)
- PZAPI ModOptions integration for configuration

**Technical Implementation:**
- Calculates freshness based on item age vs. total rot time
- Applies fridge/freezer modifiers from sandbox options
- Shows time remaining in configurable intervals (default: 3 intervals)
- Color-coded progress bars (green=fresh, yellow=ok, red=rotten)
- Patches `ISInventoryPane.drawItemDetails` and `ISToolTipInv.render`

**Configuration Options:**
- Resolution settings (affects UI element positioning)
- RequireTrait (toggle Nutritionist requirement)
- Verbose logging

**Files:**
- `common/media/lua/client/eris_food_expiry_ModOption.lua`
- `common/media/lua/client/eris_food_expiry.lua`

---

### 4. Example Mod

**Mod ID:** exampleMod
**Author:** The Indie Stone
**URL:** http://theindiestone.com/forums/index.php/topic/2011-how-to-use-the-upcoming-modloader/

**Description:**
Project Zomboid's official Example Mod demonstrating mod structure and basic modding concepts.

**Purpose:** Reference/tutorial mod for learning Project Zomboid modding

---

### 5. KR FriOS (Portable Fridges & Freezers)

**Mod ID:** KRFriOS
**Author:** D4RK-C0MP4N1
**Mod Version:** 2.2
**Minimum Game Version:** 41.78

**Description:**
Adds portable fridges, coolers, and freezers that automatically cool food using FriOS Core Batteries. Includes a solar battery charger that works with vanilla batteries.

**Key Features:**
- Portable refrigeration system with battery power
- FriOS Core Battery item for powering cooling devices
- Solar battery charger for recharging batteries
- Vanilla battery compatibility
- Automatic food spoilage reduction

**Technical Implementation:**
- Server-side system (`FriOSSystemR.lua`)
- Client-side player checks (`FriOS_PlayerCheck.lua`)
- Custom item distribution (`FriOSU_Distribution.lua`)

**Files:**
- `42/media/lua/server/FriOSSystemR.lua`
- `42/media/lua/client/FriOS_PlayerCheck.lua`
- `42/media/lua/server/FriOSU_Distribution.lua`

---

### 6. Lesley's Cookable Containers

**Mod ID:** Not specified (no mod.info file present)
**Author:** Lesley
**Version:** Build 42 compatible

**Description:**
Allows certain containers (e.g., tin cans, metal containers) to be used directly for cooking instead of requiring separate pots and pans.

**Key Features:**
- Makes containers cookable/microwaveable
- Expands cooking options with improvised containers
- Two systems: cookable and microwaveable items

**Files:**
- `42/media/lua/shared/cookables.lua`
- `42/media/lua/shared/microwaveables.lua`

---

### 7. Material Weight Reducer

**Mod ID:** Not specified (no mod.info file present)
**Author:** Unknown
**Version:** Build 42 and common (dual-version support)

**Description:**
Reduces the weight of construction and crafting materials to make inventory management less punishing.

**Purpose:** Quality-of-life improvement for material transportation and storage

**Files:**
- `42/media/lua/shared/MaterialWeight.lua`
- `common/media/lua/shared/MaterialWeight.lua`

---

### 8. Mexiox's Light Sabers Without Machetes

**Mod ID:** Mexiox_sw
**Author:** Mexiox
**Languages:** English, Spanish

**Description:**
Star Wars-themed mod adding light sabers and clothing without the machete crafting components. This is a subset version that excludes kyber crystals, magazines, and machete integration.

**Key Features:**
- Star Wars light saber weapons
- Star Wars themed clothing/outfits
- Custom zombie drops (light sabers from specific zombies)
- Attached weapon system support
- Custom hair and outfit definitions
- Key binding system for light saber activation

**Technical Implementation:**
- Attached weapon definitions for visual display
- Zombie loot table modifications
- Custom NPC/zombie definitions
- Client-side light saber effects
- Key binding for light saber on/off toggle

**Important Note:** Mutually exclusive with other Mexiox light saber mods - only enable one version

**Files:**
- `42/media/lua/shared/Definitions/Mexiox_sw_AttachedWeaponDefinitions.lua`
- `42/media/lua/shared/Mexiox_sw_keyBinding.lua`
- `42/media/lua/shared/NPC's/Mexiox_sw_ZombieDefinition.lua`
- `42/media/lua/server/Mexiox_sw_OnDeathDistribution.lua`
- `42/media/lua/client/Mexiox_sw_LightSaber.lua`
- `42/media/lua/shared/Definitions/Mexiox_sw_HairOutfitDefinitions.lua`

---

### 9. Salt Digger

**Mod ID:** SaltDigger
**Author:** Unknown

**Description:**
Adds the ability to dig inside graves to obtain salt rocks, providing an alternative source of salt for food preservation.

**Key Features:**
- Context menu option to search graves for salt
- Timed action for digging
- Salt rock item obtainable from graves
- Integrates with grave/cemetery tiles

**Technical Implementation:**
- Context menu injection (`Salt_SearchForSaltMenu.lua`)
- Timed action system (`Salt_DigForSalt.lua`)
- Empty graves building object integration

**Files:**
- `common/media/lua/client/Context/Salt_SearchForSaltMenu.lua`
- `common/media/lua/server/BuildingObjects/Salt_EmptyGraves.lua`
- `common/media/lua/client/TimedActions/Salt_DigForSalt.lua`

---

### 10. SmokinJoes Coolers

**Mod ID:** SmokinJoesCoolers
**Author:** SmokinJoe

**Description:**
Makes coolers and other insulated containers actually functional to help keep food cool or hot, slowing spoilage.

**Key Features:**
- Functional cooler containers (no power required)
- Passive temperature regulation
- Works with vanilla cooler items
- Food spoilage reduction in coolers

**Purpose:** Quality-of-life improvement making coolers work as expected in real life

**Note:** Similar concept to "Cooler Backpack" and "KR FriOS" but uses passive cooling rather than battery power

---

### 11. SS Dart

**Mod ID:** SS Dart
**Author:** Unknown

**Description:**
Adds a spaceship (presumably a vehicle or map location).

**Key Features:**
- Spaceship-themed content
- Limited information available from mod.info

**Note:** Very minimal description - likely adds a vehicle, map location, or building with spaceship theme

---

### 12. Vanilla Appliances Extended

**Mod ID:** VanillaAppliancesExtended
**Author:** Unknown

**Description:**
Example mod containing two maps with extended appliance functionality. Adds additional appliance objects or extends existing vanilla appliances.

**Key Features:**
- Custom tile definitions starting at tile ID 691
- Pack: `VanillaAppliancesExtended`
- Tiledef: `VanillaAppliancesExtended 691`
- Contains two maps

**Purpose:** Expands vanilla appliance options with new tiles and objects

---

### 13. WaterPipes (Plumbing)

**Mod ID:** Plumbing
**Author:** Unknown

**Description:**
Comprehensive plumbing system allowing players to build water pumps, pipes, and connect them to barrels, toilets, sinks for water distribution.

**Key Features:**
- Water pump construction
- Pipe network building
- Connects to: barrels, toilets, sinks
- Valve controls for water flow
- Flowmeter for monitoring water
- Water pump maintenance (filters, repairs)
- Sprinkler system support
- Integration with vanilla plumbing objects

**Technical Implementation:**
- Extensive action system (install, remove, repair, turn on/off)
- Server-side water management (`WPServer.lua`, `WPServerCommands.lua`)
- Client-side UI windows (pump info, flowmeter info)
- Sound effects for pumps (`WPSound.lua`)
- Sprinkler functionality (`WPSprinkler.lua`)
- Global mod data storage (`WPGMD.lua`)
- Virtual pipe system (`WPVirtual.lua`)
- ISO object handlers (`WPIso.lua`)
- Moveables integration patches
- Build recipe code for custom recipes

**Actions Available:**
- Attach/Disassemble pumps
- Install/Remove pipes
- Switch valves
- Turn pumps on/off
- Add filters to pumps
- Repair pumps
- Check flowmeter info
- Check pump info

**Files (19+ Lua files):**
- Client Actions: `TADisassemblePump.lua`, `TAInstallPipe.lua`, `TASwitchValve.lua`, `TAAttachPump.lua`, `TAInfoPump.lua`, `TAAddFilterPump.lua`, `TATurnOffPump.lua`, `TARemovePipe.lua`, `TARepairPump.lua`, `TATurnOnPump.lua`, `TAInfoFlowmeter.lua`
- Client UI: `ISFlowmeterInfoWindow.lua`, `ISWaterPumpInfoWindow.lua`
- Client Support: `WPSound.lua`, `WPSprinkler.lua`, `WPMenu.lua`, `WPObjectHandlers.lua`
- Patches: `ISBuildActionPatch.lua`, `ISMoveablesActionPatch.lua`
- Server: `WPServer.lua`, `WPServerCommands.lua`, `WPBuildRecipeCode.lua`
- Shared: `WPGMD.lua`, `WPIso.lua`, `WPVirtual.lua`, `WPUtils.lua`

---

## Mod Categories

### Food Preservation & Spoilage
1. **Cooler Backpack** - Battery-powered portable cooling
2. **KR FriOS** - Portable fridges/freezers with solar charging
3. **SmokinJoes Coolers** - Passive cooler functionality
4. **Eris Food Expiry** - Visual food expiration tracking

### Utilities & Quality of Life
5. **Material Weight Reducer** - Lighter construction materials
6. **Lesley's Cookable Containers** - Cook in improvised containers
7. **Salt Digger** - Alternative salt source from graves

### Building & Infrastructure
8. **WaterPipes (Plumbing)** - Complete water distribution system
9. **Vanilla Appliances Extended** - Additional appliance options

### Framework & Libraries
10. **Diederiks Tile Palooza** - Custom tile framework
11. **Example Mod** - Official modding tutorial

### Themed Content
12. **Mexiox's Light Sabers** - Star Wars weapons and clothing
13. **SS Dart** - Spaceship content

---

## Technical Notes

### Mod Structure Patterns

Most mods follow standard Project Zomboid mod structure:
- `mod.info` - Mod metadata (name, ID, description, version)
- `42/` directory - Build 42 specific files
- `common/` directory - Cross-version compatible files
- `media/lua/` - Lua script files
  - `client/` - Client-side code
  - `server/` - Server-side code
  - `shared/` - Shared code (both client and server)
- `media/scripts/` - Item definitions, recipes, etc.

### Mods Without mod.info Files
Several mods lack `mod.info` files:
- Cooler Backpack
- Eris Food Expiry
- Lesley's Cookable Containers
- Material Weight Reducer

These mods may be incomplete installations, development versions, or extracted from workshop subscriptions.

### Common Modding Techniques Observed

1. **Event Hooks:**
   - `Events.OnRefreshInventoryWindowContainers.Add()`
   - `Events.OnContainerUpdate.Add()`
   - `Events.OnTick.Add()`
   - `Events.OnGameStart.Add()`

2. **UI Patching:**
   - Overriding `ISInventoryPane.drawItemDetails`
   - Overriding `ISToolTipInv.render`
   - Custom context menu injection

3. **ModData Storage:**
   - Using `getModData()` for persistent state
   - Custom data structures (e.g., `ModData.TCM.Battery`)

4. **Temperature Control:**
   - `setCustomTemperature()`
   - `setAgeFactor()`
   - `setCookingFactor()`

5. **Container Manipulation:**
   - `instanceof()` type checking
   - Container type detection (`getType()`)
   - Nested container traversal

---

## Compatibility Notes

### Overlapping Functionality

Three mods provide cooling functionality with different approaches:
1. **Cooler Backpack** - Battery-powered active cooling
2. **KR FriOS** - Battery-powered with solar charging
3. **SmokinJoes Coolers** - Passive cooling

These mods may conflict if loaded together, depending on how they hook into container systems.

### Build Version Support

Most mods support Build 42, with some providing dual support:
- **Material Weight Reducer** - Both 42 and common versions
- **Eris Food Expiry** - Common version (cross-compatible)
- **Salt Digger** - Common version (cross-compatible)

---

## Analysis Summary

**Total Mods:** 13
**Build 42 Specific:** 8
**Cross-Version Compatible:** 3
**Framework/Library Mods:** 2
**Food System Mods:** 4
**Construction/Building Mods:** 2
**Themed/Content Mods:** 2
**Utility Mods:** 3

---

## References for Mod Development

### Best Practices Observed

1. **ModData for Persistence:** Use ModData to store state that needs to survive save/load cycles
2. **Tooltip Integration:** Update tooltips to reflect mod functionality
3. **Event-Driven Architecture:** Use event hooks rather than polling where possible
4. **Container Type Checking:** Always verify container type before applying effects
5. **Sandbox Respect:** Honor sandbox settings (FridgeFactor, FoodRotSpeed, etc.)
6. **Nested Iteration:** Implement recursive functions for nested container support
7. **Performance Consideration:** Use tick counters to limit expensive operations (e.g., every 20 ticks)

### Anti-Patterns to Avoid

1. Missing `mod.info` files
2. Hardcoded values without configuration options
3. Lack of null/nil checks on container access
4. Missing multiplayer synchronization considerations

---

**Document End**
