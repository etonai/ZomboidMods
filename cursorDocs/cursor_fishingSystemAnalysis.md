# Fishing System Analysis in Project Zomboid

*Last Updated: August 20, 2025*

## Overview

The fishing system in Project Zomboid is a sophisticated simulation that combines realistic fishing mechanics with survival gameplay elements. It features dynamic fish populations, weather effects, skill progression, and a comprehensive lure system.

## Core Components

### 1. **FishSchoolManager** (`zombie/iso/FishSchoolManager.java`)
The central system that manages fish populations and fishing zones across the world.

#### **Key Features:**
- **Dynamic Fish Populations**: Fish schools move and repopulate over time
- **Zone Management**: Tracks fishing zones and their depletion
- **Chum System**: Players can add chum to attract more fish
- **Noise Disruption**: Fishing activities can temporarily disable fish points

#### **Fish Point Generation:**
```java
private boolean isFishPoint(int n, int n2) {
    if (this.isNoFishZone(n, n2)) {
        return false;
    }
    return this.procedureRandomFloat(n, n2, this.seed) > 0.995f;
}
```
- Uses procedural generation to create fish points
- 0.5% chance for any water tile to be a fish point
- Excludes designated "no fish zones"

#### **Fish Abundance Calculation:**
```java
public double getFishAbundance(int n, int n2) {
    // Scans 13x13 area around fishing location
    // Considers fish point radius and distance
    // Includes chum effects
    // Returns fish count (0-40+)
}
```

### 2. **Fishing States System** (`media/lua/client/Fishing/FishingStates.lua`)

The fishing system uses a state machine to manage different fishing phases:

#### **States:**
- **None**: No fishing activity
- **Idle**: Ready to cast, aiming at water
- **Cast**: Casting the line
- **Wait**: Waiting for fish to bite
- **ReelIn**: Reeling in a caught fish
- **ReelOut**: Letting line out
- **PickupFish**: Collecting the caught fish

### 3. **Bobber System** (`media/lua/shared/Fishing/Bobber.lua`)

The bobber represents the fishing line in the water and manages fish attraction.

#### **Nibble Time Calculation:**
```lua
function Bobber:getNibbleTime()
    local fishAbundance = FishSchoolManager.getInstance():getFishAbundance(x, y)
    local numberOfFishCoeff = 1
    if fishAbundance == 0 then
        numberOfFishCoeff = 0
    elseif fishAbundance < 10 then
        numberOfFishCoeff = 0.5
    elseif fishAbundance <= 25 then
        numberOfFishCoeff = 1.0
    else
        numberOfFishCoeff = 1.5
    end
    -- Additional factors: temperature, weather, time of day
end
```

## Lure and Bait System

### **Lure Categories** (`media/lua/shared/Fishing/fishing_properties.lua`)

#### **1. Insects**
- **Items**: Cricket, Grasshopper, Caterpillars, Centipedes, etc.
- **Effectiveness**: Good for most fish types
- **Consumption**: Consumed after use

#### **2. Minnows**
- **Items**: BaitFish, Tadpole
- **Effectiveness**: Excellent for predatory fish
- **Consumption**: Consumed after use

#### **3. Leeches**
- **Items**: Leech, Snail, Slug
- **Effectiveness**: Good for bottom-feeding fish
- **Consumption**: Consumed after use

#### **4. Worms**
- **Items**: Worm, Maggots
- **Effectiveness**: Universal bait, works on most fish
- **Consumption**: Consumed after use

#### **5. Flesh**
- **Items**: Crayfish, Shrimp, Meat, Fish Fillet
- **Effectiveness**: Excellent for predatory fish
- **Consumption**: Consumed after use

#### **6. Plant-Based**
- **Items**: Cheese, Corn, Bread, Dough
- **Effectiveness**: Moderate, works on herbivorous fish
- **Consumption**: Consumed after use

#### **7. Artificial Lures**
- **Items**: JigLure, MinnowLure
- **Effectiveness**: Variable, but reusable
- **Consumption**: Rarely consumed (30% chance per successful catch)

### **Lure Attachment System**

#### **Attaching Lures:**
```lua
function AIAttachLureAction:complete()
    self.rod:getModData().fishing_Lure = self.lure:getFullType()
    -- Consumes natural lures, preserves artificial ones
end
```

#### **Lure Consumption:**
```lua
function FishingRod:consumeLure(isTrash)
    if Fishing.lure.ArtificalLure[lure] then
        -- 30% chance to consume artificial lure on successful catch
    else
        -- Natural lures consumed based on skill level
    end
end
```

## Fish Catching Mechanics

### **Fish Selection Algorithm** (`media/lua/shared/Fishing/Fish.lua`)

#### **1. Trash vs Fish Decision:**
```lua
function Fish:getFishByLure()
    local trashFactor = FishSchoolManager.getInstance():getTrashAbundance(self.x, self.y)
    
    -- Skill reduces trash chance
    if self.fishingLvl >= 5 then
        local cleanFactor = 0.8
        if self.fishingLvl >= 9 then
            cleanFactor = 0.2  -- 80% reduction
        elseif self.fishingLvl >= 7 then
            cleanFactor = 0.6  -- 40% reduction
        end
        trashFactor = trashFactor * cleanFactor
    end
    
    local fishNum = FishSchoolManager.getInstance():getFishAbundance(self.x, self.y)
    
    -- Decision logic based on fish abundance and trash factor
end
```

#### **2. Fish Type Selection:**
- **Location Matching**: River fish vs Lake fish
- **Lure Compatibility**: Each fish has preferred lure types
- **Skill Size Limits**: Higher skill allows catching larger fish
- **Predator Requirements**: Some fish require active reeling

### **Fish Size System**

#### **Size Categories:**
- **Small**: 33% of fish length range
- **Medium**: 33% of fish length range  
- **Big**: 33% of fish length range
- **Legendary**: Special trophy fish (requires Fishing Level 8+)

#### **Size Determination:**
```lua
function Fishing.Utils.getFishSizeChancesBySkillLevel(fishingLvl, isNearShore, fishNum)
    -- Skill level affects size distribution
    -- Near-shore fishing favors smaller fish
    -- Fish abundance affects size chances
end
```

#### **Legendary Fish System:**
```lua
if self.fishingLvl >= 8 and fishSizeData.size == "Big" then
    local trophyRoll = ZombRand(20)  -- 5% chance
    if trophyRoll == 0 then
        -- Creates legendary fish with extra length/weight
    end
end
```

## Environmental Factors

### **Weather Effects** (`media/lua/shared/Fishing/FishingUtils.lua`)

#### **Weather Coefficients:**
- **Fog**: 0.8x (reduces fishing effectiveness)
- **Wind**: 0.8x (reduces fishing effectiveness)
- **Rain**: 1.2x (increases fishing effectiveness)
- **Normal**: 1.0x (baseline)

### **Time of Day Effects**

#### **Peak Fishing Hours:**
- **Dawn (4-6 AM)**: 1.2x effectiveness
- **Dusk (6-8 PM)**: 1.2x effectiveness
- **Other Times**: 1.0x effectiveness

### **Temperature Effects**

#### **Temperature Ranges:**
- **Optimal**: 10-20°C (1.0x effectiveness)
- **Cold**: <10°C (reduced effectiveness)
- **Hot**: >20°C (reduced effectiveness)

### **Location Effects**

#### **Shore vs Deep Water:**
- **Near Shore**: Favors smaller fish
- **Deep Water**: Better chance for larger fish
- **River vs Lake**: Different fish species available

## Skill System

### **Fishing Skill Progression**

#### **Experience Gain:**
```lua
if fishSize == nil then
    addXp(self.character, Perks.Fishing, 1)  -- Trash
else
    addXp(self.character, Perks.Fishing, 2 * fishSize)  -- Fish
end
```

#### **Skill Benefits:**
- **Level 1-4**: Basic fishing ability
- **Level 5+**: Reduced trash chance (20% reduction)
- **Level 7+**: Further trash reduction (40% reduction)
- **Level 8+**: Can catch legendary fish
- **Level 9+**: Maximum trash reduction (80% reduction)

### **Skill Size Limits:**
```lua
Fishing.Utils.skillSizeLimit = {
    [0] = 0.5,   -- Level 0: 0.5kg max
    [1] = 1.0,   -- Level 1: 1.0kg max
    [2] = 2.0,   -- Level 2: 2.0kg max
    -- ... continues with higher limits
}
```

## Equipment System

### **Fishing Rods**

#### **Rod Types:**
- **CraftedFishingRod**: 0.8x effectiveness
- **FishingRod**: 1.0x effectiveness (standard)

#### **Rod Breaking:**
```lua
Fishing.breakRodReplacement = {
    ["Base.CraftedFishingRod"] = "Base.WoodenStick",
    ["Base.FishingRod"] = "Base.FishingRodBreak"
}
```

### **Fishing Line**

#### **Line Types:**
- **Twine**: 0.3/15.0 effectiveness
- **FishingLine**: 0.2/15.0 effectiveness
- **PremiumFishingLine**: 0.1/15.0 effectiveness

### **Hooks**

#### **Hook Types:**
- **Paperclip**: 0.8x effectiveness
- **Nails**: 1.0x effectiveness
- **FishingHook**: 1.2x effectiveness
- **Forged/Bone Hooks**: 1.2x effectiveness

## Advanced Features

### **Chum System**

#### **Chum Effects:**
- **Duration**: 100+ minutes
- **Range**: 3-4.5 tiles
- **Effect**: +15 fish within 3 tiles, +7 fish within 4.5 tiles
- **Decay**: Effectiveness decreases over time

### **Fish School Management**

#### **Population Dynamics:**
- **Daily Updates**: Fish schools move and repopulate
- **Zone Depletion**: Catching fish reduces local population
- **Recovery**: Zones gradually recover over time
- **Migration**: Fish move between zones

### **Multiplayer Synchronization**

#### **Data Sharing:**
- **Fish School Data**: Synchronized between server and clients
- **Chum Points**: Shared across all players
- **Zone Depletion**: Affects all players in the area

## Code Architecture

### **Key Files:**

#### **Java Core:**
- `zombie/iso/FishSchoolManager.java` - Fish population management
- `zombie/ai/states/FishingState.java` - AI fishing behavior
- `zombie/core/FishingAction.java` - Fishing action handling

#### **Lua Systems:**
- `media/lua/shared/Fishing/` - Core fishing mechanics
- `media/lua/client/Fishing/` - Client-side fishing UI and states
- `media/lua/shared/TimedActions/Fishing/` - Fishing timed actions

### **Data Flow:**
1. **FishSchoolManager** generates fish points and manages populations
2. **FishingManager** handles player fishing states and UI
3. **Bobber** manages fish attraction and nibble timing
4. **Fish** objects handle individual fish behavior and catching
5. **TimedActions** handle lure attachment and fish pickup

## Summary

The fishing system in Project Zomboid is a complex, realistic simulation that balances gameplay mechanics with survival elements. It features:

- **Dynamic fish populations** that respond to player activity
- **Comprehensive lure system** with realistic bait preferences
- **Environmental factors** that affect fishing success
- **Skill progression** that rewards experience and knowledge
- **Equipment variety** with different effectiveness levels
- **Advanced features** like chum and legendary fish

The system creates an engaging fishing experience that requires strategy, patience, and knowledge of the game's mechanics while maintaining realism and immersion. 