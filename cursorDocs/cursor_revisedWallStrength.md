# Player-Built Wall Strength Calculation in Project Zomboid

*Last Updated: August 20, 2025*

## Overview

The strength (health) of player-built walls in Project Zomboid is calculated using a straightforward formula that takes into account base health, player skills, and character traits. Based on analysis of the actual codebase (version 42.11.0), the system is simpler than initially documented.

## Actual Wall Health Formula

**For Wooden Walls:**
```lua
totalHealth = baseHealth + (Woodwork Level × 50) + (100 if Handy trait)
```

**Where:**
- **baseHealth**: 200 for regular wooden walls, 400 for log walls
- **Woodwork Level**: Player's current Woodwork/Carpentry skill level
- **Handy trait**: +100 health if player has the "Handy" trait

## Components Breakdown

### 1. Base Health (`baseHealth`)
- **Regular Wooden Walls**: 200 health
- **Log Walls**: 400 health (2x stronger than regular walls)
- This value is hardcoded in the wall type, not configurable

### 2. Skill Bonus (`skillBonus`)
- Calculated as: `Woodwork Level × 50`
- Each level of Woodwork/Carpentry adds 50 health to walls
- This is the primary way to increase wall durability

### 3. Trait Bonus (`traitBonus`)
- **Handy trait**: +100 health to all constructed walls
- This is a permanent bonus that applies regardless of skill level

## Specific Examples

### Wooden Walls
From `ISWoodenWall.lua`:
```lua
function ISWoodenWall:getHealth()
    if self.sprite == "carpentry_02_80" then -- log walls are stronger
        return 400 + buildUtil.getWoodHealth(self);
    else
        return 200 + buildUtil.getWoodHealth(self);
    end
end
```

**Log Walls vs Regular Wooden Walls:**
- **Regular Wooden Walls**: Base health of 200
- **Log Walls** (sprite `carpentry_02_80`): Base health of 400 (2x stronger)
- Both receive the same skill bonuses and trait bonuses

### Wood Health Calculation
From `ISBuildUtil.lua`:
```lua
buildUtil.getWoodHealth = function(ISItem)
    local health = (playerObj:getPerkLevel(Perks.Woodwork) * 50);
    if playerObj:HasTrait("Handy") then
        health = health + 100;
    end
    return health;
end
```

## Final Calculation Examples

### Regular Wooden Wall
For a regular wooden wall built by a player with:
- **Woodwork Level 5**
- **Handy trait**

The calculation would be:
```
baseHealth = 200
skillBonus = 5 × 50 = 250
Handy trait bonus = 100
totalHealth = 200 + 250 + 100 = 550
```

### Log Wall
For a log wall built by the same player:
```
baseHealth = 400 (log walls are stronger)
skillBonus = 5 × 50 = 250
Handy trait bonus = 100
totalHealth = 400 + 250 + 100 = 750
```

**Result**: Log walls provide 200 additional base health compared to regular wooden walls, making them significantly more durable.

## Additional Factors

- **Material quality** affects the final health (though the exact mechanics are not fully documented in the current codebase)
- **Player traits** like "Handy" provide permanent bonuses
- **Skill progression** is the primary way to increase wall durability

## Metal Walls

**Note**: While metal walls are referenced in the codebase (MetalWallLvl1, MetalWallLvl2), they are **not currently buildable by players** in Project Zomboid. The recipes exist in the code but are not accessible through normal gameplay.

### Metal Wall References in Code
- **MetalWallLvl1** and **MetalWallLvl2** recipes exist in the codebase
- These are assigned to the "metalworker" profession NPCs
- The recipes require MetalWelding skill levels
- However, players cannot access these recipes in the current game version

### Current Buildable Wall Types
Only wooden walls are currently buildable by players:
- **Regular Wooden Walls**: Base health of 200
- **Log Walls**: Base health of 400 (2x stronger)

**Future Note**: Metal walls may be implemented in future updates, but currently only wooden walls can be constructed by players.

## Metal Barricades

**Important**: While players cannot build metal walls, they **can** create metal barricades on existing walls using the Metalwork skill. This provides an alternative way to fortify structures with metal materials.

## Code References

The wall strength calculation is primarily handled in:
- `media/lua/server/BuildingObjects/ISBuildIsoEntity.lua` - Main health calculation logic
- `media/lua/server/BuildingObjects/ISWoodenWall.lua` - Wooden wall specific health
- `media/lua/server/BuildingObjects/ISBuildUtil.lua` - Wood health utility functions

## Game Balance Implications

This system rewards players for:
- Investing in construction skills (Woodwork/Carpentry)
- Selecting beneficial character traits like "Handy"
- Making walls more durable as their character progresses

The formula is straightforward and predictable, making it easy for players to plan their fortifications based on their current skill levels.

## Summary

The wall strength system in Project Zomboid 42.11.0 is much simpler than initially documented. Players can rely on a clear, predictable formula:

**Regular Wall**: `200 + (Woodwork Level × 50) + (100 if Handy trait)`  
**Log Wall**: `400 + (Woodwork Level × 50) + (100 if Handy trait)`

This simplicity makes the system accessible and allows players to easily calculate expected wall durability based on their character build. 