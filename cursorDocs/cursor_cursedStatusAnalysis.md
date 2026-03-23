# Cursed Status Analysis in Project Zomboid Farming

*Last Updated: August 20, 2025*

## Overview

The `cursedStatus` (or simply `cursed`) is a critical plant condition in Project Zomboid's farming system that significantly impacts plant health, growth, and survival. When a plant becomes "cursed," it faces severe penalties that make it much more difficult to maintain and grow successfully.

## What is Cursed Status?

### **Definition**
Cursed status is a boolean flag (`cursed = true/false`) that indicates a plant is under severe stress or unfavorable conditions. The game comment states: *"if a plant is 'cursed' (50% is planted in a risky month) then the odds are stacked against it"*

### **Core Mechanic**
```lua
modData.cursed = false  -- Default state
```

## How Plants Become Cursed

### **1. Seasonal Planting Issues**

#### **Planting in Bad Months**
```lua
if not self:isSowMonth() then 
    self.cursed = true
end
```
- **Trigger**: Planting a crop outside its designated sowing months
- **Example**: Planting tomatoes in winter when they should only be planted in spring/summer

#### **Planting in Risk Months**
```lua
elseif self:isRiskMonth() and ZombRand(20) < (11 - skill) then 
    self.cursed = true
end
```
- **Trigger**: Planting in risk months with insufficient farming skill
- **Formula**: Random chance based on `(11 - farming skill)`
- **Example**: Planting in July (risk month) with low farming skill has high chance of cursed status

### **2. Environmental Stress**

#### **Bad Season Exposure**
```lua
if seasons and luaObject.exterior and luaObject:isBadMonth() and not luaObject:isBadMonthHardy() then
    luaObject.cursed = true
end
```
- **Trigger**: Plant is outdoors during bad months without cold hardiness
- **Effect**: Immediate cursed status application

#### **Winter Exposure**
```lua
if seasons and luaObject.exterior and getClimateManager():getSeasonName() == "Winter" and not luaObject:isColdHardy() then
    luaObject.cursed = true
end
```
- **Trigger**: Non-cold-hardy plants exposed to winter conditions
- **Effect**: Immediate cursed status application

### **3. Over-Fertilization**

#### **Excessive Fertilizer Application**
```lua
elseif self.fertilizer > 2 then -- too much fertilizer and our plant cursed !
    self.cursed = true
    self.health = self.health - 25
end
```
- **Trigger**: Applying more than 2 doses of fertilizer to a single plant
- **Effect**: Immediate cursed status + 25 health penalty
- **Note**: This is the only player-controlled way to curse a plant

## Effects of Cursed Status

### **1. Bad Multiplier System**

#### **Core Multiplier**
```lua
local badMultiplier = 1
if luaObject.cursed then 
    badMultiplier = badMultiplier * 2 
end
```
- **Effect**: Cursed plants have their `badMultiplier` doubled
- **Impact**: All negative health effects are amplified by 2x

#### **Compound Effects**
```lua
if luaObject.cursed then badMultiplier = badMultiplier * 2 end
if luaObject.hasWeeds then badMultiplier = badMultiplier * 2 end
if luaObject.naturalLight then badMultiplier = badMultiplier / luaObject.naturalLight end
```
- **Cursed + Weeds**: 4x multiplier (2 × 2)
- **Cursed + Poor Light**: Even higher multiplier
- **Cursed + Weeds + Poor Light**: Maximum penalty

### **2. Health Impact Amplification**

#### **Reduced Health Recovery**
```lua
-- Sunny weather health recovery
luaObject.health = luaObject.health + (1 / badMultiplier)  -- Cursed: +0.5 instead of +1
```

#### **Amplified Health Loss**
```lua
-- Water stress penalties
luaObject.health = luaObject.health - 0.2 * badMultiplier  -- Cursed: -0.4 instead of -0.2
luaObject.health = luaObject.health - 0.5 * badMultiplier  -- Cursed: -1.0 instead of -0.5

-- Temperature stress
luaObject.health = luaObject.health - 0.5 * badMultiplier  -- Cursed: -1.0 instead of -0.5

-- Bad season penalties
luaObject.health = luaObject.health - (3 * badMultiplier)  -- Cursed: -6 instead of -3
```

### **3. Initial Health Penalty**

#### **Lower Starting Health**
```lua
if seasons and self.cursed then
    self.health = ZombRand(37, 44) + skill  -- Cursed plants start with 37-44 health
else
    self.health = SFarmingSystem.instance:getHealth() + skill  -- Normal plants start with 50+ health
end
```
- **Cursed Plants**: 37-44 base health (plus skill bonus)
- **Normal Plants**: 50+ base health (plus skill bonus)
- **Best Month Plants**: 57-64 base health (plus skill bonus)

### **4. Growth and Yield Impact**

#### **Fertilizer Bonus Exclusion**
```lua
if self.nbOfGrow <= 3 and not self.cursed and not self.hasWeeds and ZombRand(20) < (9 + skill) then
    self.bonusYield = true
end
```
- **Effect**: Cursed plants cannot receive bonus yield from fertilizer
- **Impact**: Reduced harvest quantities

#### **Disease Vulnerability**
```lua
-- In badPlant() function
if plant.cursed then badMultiplier = badMultiplier * 2 end
plant.health = plant.health - (4 * badMultiplier);  -- Cursed: -8 health instead of -4
```
- **Effect**: Disease damage is doubled for cursed plants
- **Impact**: Faster health decline from diseases

## Prevention and Management

### **1. Seasonal Awareness**

#### **Planting Windows**
- **Check Sowing Months**: Only plant during designated sowing periods
- **Avoid Risk Months**: Plant during optimal months when possible
- **Use Cold-Hardy Varieties**: For winter/early spring planting

#### **Skill Development**
- **Higher Farming Skill**: Reduces risk month cursed chance
- **Formula**: `ZombRand(20) < (11 - skill)` means higher skill = lower cursed chance

### **2. Environmental Protection**

#### **Indoor Growing**
- **Greenhouse**: Protects from seasonal curses
- **Houseplants**: Some plants are immune to outdoor seasonal effects
- **Climate Control**: Maintains stable growing conditions

#### **Weather Monitoring**
- **Seasonal Transitions**: Be aware of changing seasons
- **Temperature Management**: Protect plants during extreme weather

### **3. Fertilizer Management**

#### **Conservative Application**
- **Maximum 2 Doses**: Never apply more than 2 fertilizer doses
- **Compost Alternative**: Use compost instead of fertilizer (no cursed risk)
- **Timing**: Apply fertilizer early in growth cycle for maximum benefit

#### **Monitoring Plant Health**
- **Health Tracking**: Monitor plant health closely
- **Early Intervention**: Address issues before they compound

## Recovery from Cursed Status

### **1. Natural Recovery**
- **Seasonal Change**: Plants may recover when seasons change
- **Environmental Improvement**: Moving plants to better conditions
- **Time**: Some plants may recover over time with proper care

### **2. Care Requirements**
- **Increased Watering**: Cursed plants need more frequent watering
- **Disease Management**: Aggressive treatment of any diseases
- **Weed Control**: Remove weeds immediately to prevent compound effects
- **Light Optimization**: Ensure adequate natural light

### **3. Limitations**
- **Permanent Effects**: Some cursed effects may persist
- **Reduced Yields**: Even recovered plants may have lower yields
- **Increased Vulnerability**: Plants remain more susceptible to future stress

## Game Balance Implications

### **1. Risk vs. Reward**
- **Early Planting**: Risk of cursed status for early harvest
- **Skill Investment**: Higher farming skill reduces cursed risk
- **Resource Management**: Cursed plants require more resources to maintain

### **2. Strategic Considerations**
- **Seasonal Planning**: Critical for successful farming
- **Crop Selection**: Choose appropriate crops for current conditions
- **Resource Allocation**: Decide whether to invest in cursed plants or start over

### **3. Learning Curve**
- **New Players**: Likely to encounter cursed status frequently
- **Experience**: Players learn optimal planting times through trial and error
- **Knowledge**: Understanding seasonal mechanics is essential

## Code References

### **Key Files**
- `media/lua/server/Farming/SPlantGlobalObject.lua`: Cursed status application and management
- `media/lua/server/Farming/SFarmingSystem.lua`: Bad multiplier system and health calculations
- `media/lua/server/Farming/farming_vegetableconf.lua`: Disease and stress calculations

### **Critical Functions**
- `SPlantGlobalObject:seed()`: Cursed status application during planting
- `SPlantGlobalObject:fertilize()`: Over-fertilization cursed trigger
- `SFarmingSystem:changeHealth()`: Bad multiplier calculations
- `badPlant()`: Disease and stress damage amplification

## Conclusion

Cursed status is a sophisticated mechanic that adds depth and challenge to Project Zomboid's farming system. It serves as a penalty for poor timing, environmental mismanagement, or over-fertilization, requiring players to:

1. **Understand seasonal mechanics** and plant requirements
2. **Develop farming skills** to reduce cursed risk
3. **Manage resources carefully** to avoid over-fertilization
4. **Provide optimal growing conditions** for plant health

The system encourages strategic planning and rewards knowledge of agricultural timing, making farming a more engaging and realistic survival activity in Project Zomboid. 