# Project Zomboid Wall Strength - Revised Analysis

*Updated: August 20, 2025*  
*Accurate analysis based on Project Zomboid version 42.11.0 codebase*

## Wall Health Formula

**Basic Wooden Wall:**
- Base Health: **200**
- Plus: **Woodwork Level × 50**
- Plus: **100** (if player has "Handy" trait)

**Log Wall (stronger variant):**
- Base Health: **400** 
- Plus: **Woodwork Level × 50**
- Plus: **100** (if player has "Handy" trait)

## Code Implementation

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

## Health Examples

| Woodwork Level | Handy Trait | Regular Wall | Log Wall |
|----------------|-------------|--------------|----------|
| 0 | No | 200 | 400 |
| 0 | Yes | 300 | 500 |
| 5 | No | 450 | 650 |
| 5 | Yes | 550 | 750 |
| 10 | No | 700 | 900 |
| 10 | Yes | 800 | 1000 |

## Metal Fortification (Barricades)

While metal walls are not buildable, players can fortify existing structures using the **MetalWelding** skill through barricades:

### Barricade Types
- **Sheet Metal Barricades**: 5000 health
- **Metal Bar Barricades**: 3000 health
- **Applied to**: Existing walls, doors, and windows
- **Skill Required**: MetalWelding
- **Materials**: Sheet metal/metal bars + welding equipment

This represents the actual "metal wall" functionality available to players in the current game version.

## Other Wooden Structures

The same `buildUtil.getWoodHealth()` formula applies to other wooden construction with different base values:

| Structure Type | Base Health | Health Range |
|----------------|-------------|--------------|
| **Doors/Double Doors** | 300 | 300-900 |
| **Door Frames** | 300 | 300-900 |
| **Stairs** | 500 | 500-1100 |
| **Containers** | 200 | 200-800 |
| **Simple Furniture** | 100 | 100-700 |

## Metal Wall Status

**Important**: Metal walls (MetalWallLvl1, MetalWallLvl2) exist in the codebase but are **NOT buildable by players**:

- Recipe names exist in translation files
- Assigned to NPC "metalworker" profession  
- No player-accessible recipes or building objects
- Cannot be crafted by players in version 42.11.0

## Key Files

- `zombie/iso/objects/IsoThumpable.java` - Core health mechanics
- `media/lua/server/BuildingObjects/ISWoodenWall.lua` - Wall-specific health calculation
- `media/lua/server/BuildingObjects/ISBuildUtil.lua` - Shared health calculation function

## Summary

Based on direct code analysis:

1. **Simple Formula**: Wall health = Base + (Woodwork × 50) + (Handy bonus)
2. **Two Wall Types**: Regular (200 base) and Log (400 base) wooden walls only
3. **No Complex Systems**: No sandbox multipliers or bonus health systems for basic walls
4. **Metal Fortification**: Available through barricade system, not buildable walls
5. **Skill Scaling**: Linear progression with Woodwork skill level

This analysis is based solely on the actual Project Zomboid 42.11.0 implementation without speculation or theoretical systems.