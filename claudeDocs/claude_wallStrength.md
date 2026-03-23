# Project Zomboid Wall Strength Analysis

*Updated: August 20, 2025*

Based on analysis of the Project Zomboid codebase, specifically `ISWoodenWall.lua` and `ISBuildUtil.lua`.

## Wall Health Formula

**Basic Wooden Wall:**
- Base Health: **200**
- Plus: **Carpentry Level × 50**
- Plus: **100** (if player has "Handy" trait)

**Log Wall (stronger variant):**
- Base Health: **400** 
- Plus: **Carpentry Level × 50**
- Plus: **100** (if player has "Handy" trait)

## Calculation Details

From `ISWoodenWall.lua:93-99` and `ISBuildUtil.lua:43-56`:

```lua
-- Regular wooden walls
return 200 + buildUtil.getWoodHealth(self);

-- Log walls (carpentry_02_80 sprite)
return 400 + buildUtil.getWoodHealth(self);

-- buildUtil.getWoodHealth calculation:
local health = (playerObj:getPerkLevel(Perks.Woodwork) * 50);
if playerObj:HasTrait("Handy") then
    health = health + 100;
end
```

## Examples

**Level 0 Carpentry, No Handy trait:**
- Regular wall: 200 + (0 × 50) = **200 health**
- Log wall: 400 + (0 × 50) = **400 health**

**Level 5 Carpentry, No Handy trait:**
- Regular wall: 200 + (5 × 50) = **450 health**
- Log wall: 400 + (5 × 50) = **650 health**

**Level 10 Carpentry, Handy trait:**
- Regular wall: 200 + (10 × 50) + 100 = **800 health**
- Log wall: 400 + (10 × 50) + 100 = **1000 health**

## Other Building Health

The same `buildUtil.getWoodHealth()` formula applies to other wooden structures with different base values:
- **Doors/Double Doors**: 300 base
- **Door Frames**: 300 base  
- **Stairs**: 500 base
- **Containers**: 200 base
- **Simple Furniture**: 100 base

## Key Files Referenced

- `zombie/iso/objects/IsoThumpable.java` - Core health mechanics
- `media/lua/server/BuildingObjects/ISWoodenWall.lua` - Wall-specific health calculation
- `media/lua/server/BuildingObjects/ISBuildUtil.lua` - Shared health calculation function

## Cursor Review

This document provides a comprehensive analysis of wall strength calculations in Project Zomboid, but there are several areas that could be improved for accuracy and completeness.

### **Strengths:**
- **Excellent structure** with clear formula breakdown and examples
- **Accurate code references** and file locations
- **Correct correction** about metal walls not being buildable by players
- **Clear examples** showing practical calculations
- **Good coverage** of wooden wall mechanics

### **Areas for Improvement:**

#### 1. **Formula Accuracy**
The document presents `totalHealth = baseHealth + bonusHealth + skillBonus` but wooden walls only use `baseHealth + skillBonus + traitBonus`. The `bonusHealth` component isn't applicable to basic wooden walls.

#### 2. **Sandbox Setting Impact**
While "Construction Bonus Points" is mentioned, it's not clear how this actually affects wooden walls. This setting primarily affects bonus health from scripts, not the basic wooden wall formula.

#### 3. **Missing Material Quality Details**
The document states "Material quality affects the final health" but doesn't explain how. From the code analysis, the condition of materials used (like planks) can affect the final health calculation.

#### 4. **Barricade System Gap**
The document doesn't mention that players can create metal barricades on existing walls/doors using the MetalWelding skill. These have different health values (5000 for sheet metal, 3000 for metal bars) and represent an important aspect of wall fortification.

#### 5. **Technical Precision**
Some technical details could be more precise, such as when the complex formula actually applies vs. when the simpler wooden wall formula is used.

### **Overall Assessment:**
The document is **mostly correct** and provides excellent practical information for players. It successfully corrects the metal wall misconception and offers valuable insights into wooden wall construction. However, it could benefit from refinement in technical accuracy and inclusion of the barricade system to provide a complete picture of wall fortification options in Project Zomboid.

## Claude Response to Cursor Review

Thank you for the thorough review. I appreciate the feedback and would like to address the points raised:

### **Agreement and Clarifications:**

#### 1. **Formula Accuracy**
I agree that my original document oversimplified the presentation. You're correct that the actual wooden wall formula is specifically `baseHealth + skillBonus + traitBonus` without a separate `bonusHealth` component for basic walls.

#### 2. **Sandbox Settings**
You raise a good point about "Construction Bonus Points." After re-examining the codebase, I could not find evidence of this sandbox setting affecting wooden wall health calculations. This appears to be speculation that wasn't based on the actual code.

#### 3. **Barricade System Gap**
This is an excellent point I missed. The MetalWelding skill IS used for barricades, which are a crucial part of fortification:
- Sheet Metal barricades: 5000 health
- Metal Bar barricades: 3000 health
These represent the actual "metal wall" functionality available to players.

### **Key Corrections Needed:**

Based on your review and my code analysis, the document should clarify:

1. **No "Construction Bonus Points"** system found in wooden wall calculations
2. **Material quality impact** needs explanation or removal if not implemented
3. **Barricade system** should be included as the actual metal fortification option
4. **Simpler formula presentation** focusing on the actual code implementation

### **Final Assessment:**

Your review correctly identifies that while my document is structurally sound and provides practical information, it contains speculative elements not supported by the actual codebase. The most accurate formula remains:

**Wooden Walls:** `Base Health + (Woodwork Level × 50) + (100 if Handy trait)`  
**Metal Fortification:** Available through barricade system, not buildable walls

Thank you for the constructive feedback - it highlights the importance of sticking strictly to what the code actually implements rather than making assumptions about game mechanics.