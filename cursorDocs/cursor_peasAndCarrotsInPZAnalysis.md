# Growing Peas and Carrots in Project Zomboid - Game Analysis

*Last Updated: August 20, 2025*

## Overview

Peas and carrots are two distinct crops in Project Zomboid's farming system with different growth characteristics, water requirements, and seasonal considerations. This analysis focuses solely on the game mechanics and data from the Project Zomboid codebase.

## Carrots (Daucus carota)

### **Game Data**
- **Texture**: `vegetation_farming_01_38`
- **Icon**: `Item_Carrots`
- **Seed Item**: `Base.CarrotSeed`
- **Harvest Item**: `Base.Carrots`

### **Growth Mechanics**

#### **Growth Timeline**
```lua
timeToGrow = 432,        -- 18 days (432 hours)
mature = 5,              -- Ready to harvest at stage 5
fullGrown = 6,           -- Full maturity at stage 6
```

#### **Yield System**
```lua
minVeg = 3,              -- Minimum 3 carrots per plant
maxVeg = 6,              -- Maximum 6 carrots per plant
minVegAutorized = 10,    -- 10+ carrots with high farming skill
maxVegAutorized = 15,    -- Up to 15 carrots with max skill
```

#### **Water Requirements**
```lua
waterLvl = 30,           -- Initial water level
waterNeeded = 70,        -- Requires 70% water for optimal growth
```

### **Seasonal Game Mechanics**

#### **Planting Windows**
- **Sow Months**: February, March, April, May, June, July
- **Best Months**: February, June (optimal growing conditions)
- **Risk Month**: July (increased disease risk)
- **Bad Months**: January, October, November, December

#### **Cold Hardiness**
```lua
badMonthHardyLevel = 4,  -- Can survive cold down to growth stage 4
```
Carrots can be planted in cold months and survive down to growth stage 4.

### **Game Strategy**

#### **Early Spring Planting**
- **Advantage**: Long growing season allows multiple harvests
- **Timing**: Plant in February-March for June harvest
- **Water Management**: Monitor water levels during dry spring conditions

#### **Late Summer Planting**
- **Advantage**: Cooler temperatures may reduce disease risk
- **Timing**: Plant in June-July for fall harvest
- **Consideration**: Risk of early frost damage

### **Disease and Pest Status**
- **No specific resistances** listed in game configuration
- **Standard disease management** required
- **Monitor for**: Mildew, aphids, flies (standard game diseases)

---

## Green Peas (Pisum sativum)

### **Game Data**
- **Texture**: `vegetation_farming_01_110`
- **Icon**: `Item_Greenpeas`
- **Seed Item**: `Base.GreenpeasSeed`
- **Harvest Item**: `Base.Greenpeas`

### **Growth Mechanics**

#### **Growth Timeline**
```lua
timeToGrow = 292,        -- 12 days (292 hours) - Faster than carrots
mature = 5,              -- Ready to harvest at stage 5
fullGrown = 6,           -- Full maturity at stage 6
```

#### **Yield System**
```lua
minVeg = 2,              -- Minimum 2 pea pods per plant
maxVeg = 4,              -- Maximum 4 pea pods per plant
minVegAutorized = 6,     -- 6+ pods with high farming skill
maxVegAutorized = 8,     -- Up to 8 pods with max skill
```

#### **Water Requirements**
```lua
waterLvl = 70,           -- Higher initial water level
waterNeeded = 80,        -- Requires 80% water (higher than carrots)
```

### **Seasonal Game Mechanics**

#### **Planting Windows**
- **Sow Months**: February, March, April
- **Best Month**: March (optimal growing conditions)
- **Risk Month**: April (increased disease risk)
- **Bad Months**: October, November, December, January

#### **Growing Window**
Peas have a **narrower growing window** compared to carrots, making timing more critical.

### **Game Strategy**

#### **Early Spring Focus**
- **Advantage**: Cool temperatures, natural pest resistance
- **Timing**: Plant in February-March for April harvest
- **Water Management**: Higher water requirements need careful monitoring

#### **Succession Planting**
- **Strategy**: Plant multiple batches 2-3 weeks apart
- **Benefit**: Extended harvest period
- **Consideration**: Limited by short growing season

### **Disease and Pest Resistance**
```lua
slugsProof = true,       -- Resistant to slug damage
mothFood = true,         -- Attracts moths (potential issue)
```
Peas have **built-in slug resistance** but may attract moths.

---

## Game Comparison Analysis

### **Growth Speed**
| Crop | Growth Time | Relative Speed |
|------|-------------|----------------|
| **Carrots** | 432 hours (18 days) | Slow |
| **Peas** | 292 hours (12 days) | Fast |

### **Water Requirements**
| Crop | Water Needed | Water Level | Difficulty |
|------|--------------|-------------|------------|
| **Carrots** | 70% | 30% | Moderate |
| **Peas** | 80% | 70% | High |

### **Yield Potential**
| Crop | Min Yield | Max Yield | Skill Bonus |
|------|-----------|-----------|-------------|
| **Carrots** | 3-6 | 10-15 | +7-9 carrots |
| **Peas** | 2-4 | 6-8 | +4 pods |

### **Seasonal Flexibility**
| Crop | Growing Window | Cold Hardy | Planting Flexibility |
|------|----------------|------------|-------------------|
| **Carrots** | 6 months | Yes | High |
| **Peas** | 3 months | No | Low |

---

## Game Mechanics and Tips

### **For Carrots**

#### **Water Management**
- **Frequency**: Water regularly to maintain 70% level
- **Deep Watering**: Encourage deep root development
- **Drought Tolerance**: Carrots can handle brief dry periods

#### **Harvest Timing**
- **Early Harvest**: Can harvest at stage 5 for immediate use
- **Full Maturity**: Wait for stage 6 for maximum yield and seeds
- **Storage**: Carrots store well and can be left in ground

### **For Peas**

#### **Support Requirements**
- **Climbing**: Peas are climbing plants (harvestPosition = "Mid")
- **Trellising**: Consider providing support for better yields
- **Spacing**: Plant closer together for natural support

#### **Water Management**
- **High Requirements**: Monitor water levels closely (80% needed)
- **Consistent Moisture**: Avoid letting soil dry out

#### **Harvest Strategy**
- **Regular Picking**: Harvest pods as they mature
- **Succession**: Plant multiple batches for extended harvest
- **Seed Saving**: Allow some pods to fully mature for seeds

---

## Game Uses and Applications

### **Crafting and Cooking**
- **Carrots**: Used in cooking, canning, and as bait for traps
- **Peas**: Used in cooking and canning
- **Seeds**: Both provide seeds for replanting

### **Trap Bait Effectiveness**
- **Carrots**: 45% effectiveness for rabbit and raccoon traps
- **Peas**: No specific trap bait data available

### **Foraging Integration**
Both crops can be found in the foraging system:
- **Carrots**: Available in Forest, Vegetation, and FarmLand zones
- **Peas**: Available in Forest, DeepForest, Vegetation, and FarmLand zones

---

## Game Strategy Recommendations

### **Skill Development**
- **Farming XP**: Both crops provide good farming experience
- **Yield Improvement**: Higher farming skill significantly increases yields
- **Disease Management**: Practice proper crop rotation and care

### **Seasonal Planning**
- **Early Spring**: Focus on peas for quick harvest
- **Spring/Summer**: Plant carrots for fall harvest
- **Succession**: Use peas for multiple quick crops
- **Storage**: Rely on carrots for winter food security

### **Water Management Strategy**
- **Carrots**: Moderate water needs, can handle some drought
- **Peas**: High water needs, require consistent monitoring
- **Rain Integration**: Both benefit from natural rainfall

---

## Game Balance Considerations

### **Advantages of Carrots**
- **Reliability**: Long growing season and cold hardiness
- **High Yields**: Excellent yield potential with skill bonuses
- **Storage**: Long-term storage capability
- **Flexibility**: Multiple planting windows throughout the year

### **Advantages of Peas**
- **Speed**: Fast growth for quick harvests
- **Pest Resistance**: Built-in slug resistance
- **Early Season**: Excellent early spring crop

### **Optimal Game Strategy**
**Plant both crops** in a diversified farming approach:
- **Early Spring**: Focus on peas for quick harvest
- **Spring/Summer**: Plant carrots for fall harvest
- **Succession**: Use peas for multiple quick crops
- **Storage**: Rely on carrots for winter food security

This combination provides both immediate food needs and long-term storage options, making them essential crops for any serious farming operation in Project Zomboid. 