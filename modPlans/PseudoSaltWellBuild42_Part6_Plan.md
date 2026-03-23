# PseudoSaltWellB42 Part 6: Custom Tiles - Detailed Plan

**Mod Name:** PseudoSaltWellB42_Part6_CustomTiles
**Created:** 2025-10-13
**Target:** Project Zomboid Build 42.11.0
**Based On:** Mod 5 (PseudoSaltWellB42_Part5_IndependentItems)

---

## Overview

Mod 6 is functionally identical to Mod 5, but replaces the borrowed sprites with custom-created tile graphics. This provides a unique visual identity for the mod and ensures the graphics are purpose-built for saltwater wells and plain holes.

---

## Purpose

Replace temporary/borrowed sprites with custom-designed tiles:
- **Mod 5**: Uses borrowed sprites (`pseudoed_01_6` for well, `location_community_cemetary_01_33` for hole)
- **Mod 6**: Uses custom sprites (`pseudoed_saltwell_01_0` for well, `pseudoed_saltwell_01_1` for hole)

All functionality remains identical to Mod 5.

---

## Dependencies

- **None** - Completely standalone mod
- **Builds on:** Mod 5 concepts and code

---

## Key Changes from Mod 5

### Sprite Names

**ISLocationBasedHole.lua - create() method:**
```lua
// Mod 5 (borrowed sprites):
if isSaltwater then
    holeSprite = "pseudoed_01_6";  // Borrowed well sprite
    holeName = "SaltwaterWell";
else
    holeSprite = "location_community_cemetary_01_33";  // Grave hole sprite
    holeName = "Hole";
end

// Mod 6 (custom sprites):
if isSaltwater then
    holeSprite = "pseudoed_saltwell_01_0";  // CUSTOM well sprite
    holeName = "SaltwaterWell";
else
    holeSprite = "pseudoed_saltwell_01_1";  // CUSTOM hole sprite
    holeName = "Hole";
end
```

**ISLocationBasedHole.lua - render() method:**
```lua
// Update to use custom sprite in ghost tile rendering
local spriteName = self:getSprite();  // Will be one of the new custom sprites
```

### New Assets Required

1. **Texture Files:**
   - `common/media/textures/pseudoed_saltwell_01_0.png` - Saltwater well graphic
   - `common/media/textures/pseudoed_saltwell_01_1.png` - Plain hole graphic

2. **Tile Definition:**
   - `common/media/pseudoed_saltwell_01.tiles` - Defines the two tile sprites

3. **Texture Pack:**
   - `common/media/texturepacks/pseudoed_saltwell_01.pack` - Compressed textures

### Mod.info Changes

```ini
name=PseudoSaltWellB42 Part 6: Custom Tiles
id=PseudoSaltWellB42_Part6_CustomTiles
description=Independent saltwater well system with custom graphics. Create saltwater wells at specific coordinates or plain holes elsewhere. Fill pots and kettles with saltwater, cook to create salt. Fully standalone with custom well and hole graphics.
poster=poster.png
pack=pseudoed_saltwell_01
tiledef=pseudoed_saltwell_01 8724
```

---

## Custom Tile Specifications

### Saltwater Well Tile (`pseudoed_saltwell_01_0`)

**Visual Requirements:**
- Should clearly indicate it's a well containing water
- Distinguishable from plain hole
- Top-down perspective (isometric view)
- Should show water/liquid inside

**Recommended Design Elements:**
- Circular or square well opening
- Dark interior showing depth
- Blue/cyan tint to suggest water
- Stone or wood edging around opening
- Possibly show ripples or water surface

**Technical Specs:**
- Format: PNG with transparency
- Size: 64x64 pixels (1 tile) OR 64x128 pixels (2 tiles)
- Color depth: 32-bit RGBA
- File name: `pseudoed_saltwell_01_0.png`

### Plain Hole Tile (`pseudoed_saltwell_01_1`)

**Visual Requirements:**
- Should look like a freshly dug hole
- Clearly different from well (no water indication)
- Top-down perspective matching well tile
- Non-interactive appearance

**Recommended Design Elements:**
- Irregular dirt edges
- Brown/earth tones
- Darker interior showing depth
- Loose dirt around edges
- No water, no structure

**Technical Specs:**
- Format: PNG with transparency
- Size: 64x64 pixels (1 tile)
- Color depth: 32-bit RGBA
- File name: `pseudoed_saltwell_01_1.png`

---

## Tile Definition File

**File:** `common/media/pseudoed_saltwell_01.tiles`

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

---

## Implementation Steps

### Step 1: Copy Mod 5 Base

1. Copy entire `PseudoSaltWellB42_Part5_IndependentItems` directory
2. Rename to `PseudoSaltWellB42_Part6_CustomTiles`
3. This gives you all the working Lua code and item definitions

### Step 2: Create Custom Graphics

1. **Create Saltwater Well Graphic:**
   - Design 64x64 pixel PNG
   - Show well with water
   - Save as `pseudoed_saltwell_01_0.png`

2. **Create Plain Hole Graphic:**
   - Design 64x64 pixel PNG
   - Show empty dug hole
   - Save as `pseudoed_saltwell_01_1.png`

3. **Place Textures:**
   - Create directory: `common/media/textures/`
   - Place both PNG files in this directory

### Step 3: Create Tile Definition

1. Create file: `common/media/pseudoed_saltwell_01.tiles`
2. Add tile definitions (see format above)

### Step 4: Create/Generate Texture Pack

**Option A: Let game generate it**
- Game will auto-generate `.pack` file on first load
- Place textures and tiles file, mod.info will reference them

**Option B: Use TileZed (if available)**
- Use Project Zomboid TileZed tool
- Import textures and export pack file
- Place in `common/media/texturepacks/pseudoed_saltwell_01.pack`

### Step 5: Update Lua Code

**File:** `42/media/lua/server/BuildingObjects/ISLocationBasedHole.lua`

1. **In create() method (around line 43-48):**
   ```lua
   if isSaltwater then
       -- Create saltwater well
       holeSprite = "pseudoed_saltwell_01_0";  // CHANGE THIS LINE
       holeName = "SaltwaterWell";
   else
       -- Create plain hole
       holeSprite = "pseudoed_saltwell_01_1";  // CHANGE THIS LINE
       holeName = "Hole";
   end
   ```

2. **In render() method:** No changes needed - uses `self:getSprite()`

3. **In new() method:** Sprite passed as parameter, set during placement

### Step 6: Update mod.info Files

Update all three mod.info files (root, `42/`, `common/`):

```ini
name=PseudoSaltWellB42 Part 6: Custom Tiles
id=PseudoSaltWellB42_Part6_CustomTiles
description=Independent saltwater well system with custom graphics. Create saltwater wells at specific coordinates or plain holes elsewhere. Fill pots and kettles with saltwater, cook to create salt. Fully standalone with custom well and hole graphics.
poster=poster.png
pack=pseudoed_saltwell_01
tiledef=pseudoed_saltwell_01 8724
```

### Step 7: Update LocationBasedHoleMenu.lua

**File:** `42/media/lua/client/LocationBasedHoleMenu.lua`

Update sprite determination in `onDigHole()` function (around line 26-30):
```lua
local spriteName;
if isSaltwater then
    spriteName = "pseudoed_saltwell_01_0";  // CHANGE THIS LINE
else
    spriteName = "pseudoed_saltwell_01_1";  // CHANGE THIS LINE
end
```

---

## Complete Directory Structure

```
PseudoSaltWellB42_Part6_CustomTiles/
├── mod.info                              [UPDATED - add pack/tiledef]
├── poster.png
├── 42/
│   ├── mod.info                          [UPDATED - add pack/tiledef]
│   └── media/
│       ├── lua/
│       │   ├── client/
│       │   │   ├── WellFillMenu.lua      [SAME as Mod 5]
│       │   │   ├── EmptySaltwaterMenu.lua [SAME as Mod 5]
│       │   │   └── LocationBasedHoleMenu.lua [UPDATED - sprite names]
│       │   ├── server/
│       │   │   └── BuildingObjects/
│       │   │       └── ISLocationBasedHole.lua [UPDATED - sprite names]
│       │   └── shared/
│       │       ├── SaltwaterLocationDetector.lua [SAME as Mod 5]
│       │       └── TimedActions/
│       │           ├── ISFillPotFromWell.lua [SAME as Mod 5]
│       │           ├── ISFillKettleFromWell.lua [SAME as Mod 5]
│       │           └── ISEmptySaltwaterContainer.lua [SAME as Mod 5]
│       └── scripts/
│           ├── items/
│           │   └── PseudoSaltWellItems.txt [SAME as Mod 5]
│           └── recipes/
│               └── PseudoSaltWellRecipes.txt [SAME as Mod 5]
└── common/
    ├── mod.info                          [UPDATED - add pack/tiledef]
    └── media/
        ├── pseudoed_saltwell_01.tiles    [NEW]
        ├── texturepacks/
        │   └── pseudoed_saltwell_01.pack [NEW]
        └── textures/
            ├── pseudoed_saltwell_01_0.png [NEW - well graphic]
            └── pseudoed_saltwell_01_1.png [NEW - hole graphic]
```

---

## Files That Change from Mod 5

### Modified Files (sprite names only)

1. **ISLocationBasedHole.lua**
   - Line ~43: `holeSprite = "pseudoed_saltwell_01_0";`
   - Line ~47: `holeSprite = "pseudoed_saltwell_01_1";`

2. **LocationBasedHoleMenu.lua**
   - Line ~27: `spriteName = "pseudoed_saltwell_01_0";`
   - Line ~29: `spriteName = "pseudoed_saltwell_01_1";`

3. **mod.info** (all 3 locations)
   - Add: `pack=pseudoed_saltwell_01`
   - Add: `tiledef=pseudoed_saltwell_01 8724`
   - Update: name, id, description

### New Files (assets)

1. `common/media/textures/pseudoed_saltwell_01_0.png`
2. `common/media/textures/pseudoed_saltwell_01_1.png`
3. `common/media/pseudoed_saltwell_01.tiles`
4. `common/media/texturepacks/pseudoed_saltwell_01.pack`

### Unchanged Files (copy as-is)

All other Lua files, item definitions, and recipes remain identical to Mod 5.

---

## Testing Checklist

### Functionality Tests (Same as Mod 5)

- [ ] Mod loads without errors
- [ ] Can dig at saltwater coordinates (8163, any Y) and (8165, 12212)
- [ ] Saltwater wells show **custom well graphic**
- [ ] Can dig at non-saltwater coordinates
- [ ] Plain holes show **custom hole graphic**
- [ ] Right-click saltwater well shows "Fill Pot with Saltwater"
- [ ] Right-click saltwater well shows "Fill Kettle with Saltwater"
- [ ] Filling pot creates PseudoSaltWellB42.SaltwaterPot
- [ ] Filling kettle creates PseudoSaltWellB42.SaltwaterKettle
- [ ] Can empty saltwater containers via context menu
- [ ] Cooking saltwater produces salt containers
- [ ] Can extract salt from salt containers via recipe
- [ ] Extracting salt returns 2x Base.Salt + empty container

### Graphics Tests (New for Mod 6)

- [ ] Custom saltwater well graphic displays correctly
- [ ] Custom plain hole graphic displays correctly
- [ ] Graphics are clearly distinguishable from each other
- [ ] Ghost tiles show correct graphics during placement
- [ ] Well graphic clearly indicates water/saltwater
- [ ] Hole graphic clearly looks like empty dug hole
- [ ] No tile errors or missing textures
- [ ] Graphics render at correct size (not stretched/squashed)
- [ ] Transparency works correctly (no black boxes)

---

## Common Issues and Solutions

### Issue: Tiles don't appear (black squares)

**Causes:**
- Texture files not in correct directory
- Tile definition file syntax error
- Texture pack not generated

**Solutions:**
- Verify textures in `common/media/textures/`
- Check `.tiles` file syntax
- Delete `.pack` file and let game regenerate
- Check console.txt for texture loading errors

### Issue: Wrong sprite shows

**Causes:**
- Sprite name typo in Lua code
- Tile definition doesn't match sprite name

**Solutions:**
- Verify sprite names match exactly: `pseudoed_saltwell_01_0` and `pseudoed_saltwell_01_1`
- Check tiles file uses same names
- Check Lua code uses same names

### Issue: Ghost tile doesn't show custom graphic

**Causes:**
- Sprite name not passed correctly to render()
- Tile not loaded when render() called

**Solutions:**
- Verify `new()` method sets sprite correctly
- Check render() uses `self:getSprite()`
- Ensure tiles loaded before placement attempted

---

## Sprite Naming Convention

**Tileset Name:** `pseudoed_saltwell_01`

**Sprite Format:** `{tileset}_{row}_{column}` or `{tileset}_{index}`

**This Mod Uses:**
- `pseudoed_saltwell_01_0` - Saltwater well (index 0)
- `pseudoed_saltwell_01_1` - Plain hole (index 1)

**Starting Tile ID:** 8724 (defined in tiledef line of mod.info)

**Why this convention:**
- `pseudoed` - Pseudonymous Ed's mods prefix
- `saltwell` - Identifies this as saltwater well mod
- `01` - Version number (allows for future tilesets)
- `_0`, `_1` - Individual tile indices

---

## Success Criteria

### Must Have
- ✓ All Mod 5 functionality works identically
- ✓ Custom graphics display correctly
- ✓ Saltwater wells show well graphic
- ✓ Plain holes show hole graphic
- ✓ Graphics are visually distinct

### Should Have
- ✓ Graphics look polished and appropriate
- ✓ Well graphic clearly indicates water
- ✓ Hole graphic clearly indicates empty hole
- ✓ Graphics match game's art style

### Nice to Have
- Graphics show detail (ripples, dirt texture, etc.)
- Graphics have shading/depth
- Multiple tile variants (future expansion)

---

## Future Enhancements

**Potential additions to this mod:**
1. Multiple well tile variants (different styles)
2. Animated water in well (ripples)
3. Different hole depths (shallow vs deep)
4. Seasonal variants (frozen well in winter)
5. Well cover tiles (protective structures)
6. Construction stages (partially dug holes)

---

## Version History

- **v1.0** (2025-10-13): Initial Mod 6 plan created
  - Based on Mod 5 codebase
  - Define custom tile requirements
  - Document sprite changes needed
  - Create implementation steps

---

**End of Plan**
