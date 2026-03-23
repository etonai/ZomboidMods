# Farming System Analysis in Project Zomboid

*Last Updated: August 20, 2025*

## Overview

The farming system in Project Zomboid is a sophisticated agricultural simulation that combines realistic plant growth mechanics with survival gameplay elements. It features dynamic plant states, disease management, environmental factors, and a comprehensive skill progression system.

## Core Architecture

### 1. **Global Object System**
The farming system uses a global object system to manage all plants across the world:

#### **Client-Side** (`media/lua/client/Farming/CFarmingSystem.lua`)
- Manages UI and player interactions
- Handles farming skill progression
- Provides visual feedback for plant states

#### **Server-Side** (`media/lua/server/Farming/SFarmingSystem.lua`)
- Controls plant growth and health calculations
- Manages disease spread and environmental effects
- Handles water levels and weather interactions

### 2. **Plant Object System** (`media/lua/server/Farming/SPlantGlobalObject.lua`)
Each plant is represented by a `SPlantGlobalObject` with comprehensive state tracking:

```lua
-- Core plant properties
modData.state = "plow"           -- Current plant state
modData.nbOfGrow = -1            -- Growth stage counter
modData.typeOfSeed = "none"      -- Plant type
modData.health = 50              -- Plant health (0-100)
modData.waterLvl = 0             -- Water level (0-100)
modData.fertilizer = 0           -- Fertilizer level
modData.mildewLvl = 0            -- Mildew disease level
modData.aphidLvl = 0             -- Aphid infestation level
modData.fliesLvl = 0             -- Pest fly level
modData.slugsLvl = 0             -- Slug infestation level
modData.hasWeeds = false         -- Weed presence
modData.exterior = true          -- Indoor/outdoor status
```

## Plant Growth Stages

### **Growth State Machine**
Plants progress through distinct growth phases:

#### **1. Plowed Land** (`state = "plow"`)
- Initial state after tilling soil
- Requires seed planting to progress
- Can be destroyed by walking or vehicles

#### **2. Seeded** (`state = "seeded"`)
- Plant has been seeded but not yet sprouted
- `nbOfGrow = 0`
- Critical 48-hour window for initial watering

#### **3. Growing** (`state = "seeded"`, `nbOfGrow > 0`)
- Plant is actively growing
- Multiple growth stages with visual progression
- Health and disease management critical

#### **4. Mature** (`state = "seeded"`, `nbOfGrow == prop.mature`)
- Plant is ready for harvest
- `hasVegetable = true`
- Can be harvested for food

#### **5. Seed-Bearing** (`state = "seeded"`, `nbOfGrow == prop.fullGrown`)
- Plant has produced seeds
- `hasSeed = true`
- Can be harvested for seeds

#### **6. Dead/Rotten** (`state = "dead"` or `"rotten"`)
- Plant has died from disease, neglect, or age
- Can be destroyed to clear the plot

## Plant Growth Mechanics

### **Growth Timing System**
```lua
function SFarmingSystem:growPlant(luaObject, nextGrowing, updateNbOfGrow)
    local water = farming_vegetableconf.calcWater(planting.waterNeeded, planting.waterLvl)
    local waterMax = farming_vegetableconf.calcWater(planting.waterLvl, planting.waterNeededMax)
    local diseaseLvl = farming_vegetableconf.calcDisease(planting.mildewLvl)
    
    -- Growth time calculation
    local growthTime = prop.timeToGrow + water + waterMax + diseaseLvl
    planting.nextGrowing = calcNextGrowing(nextGrowing, growthTime)
end
```

### **Water Requirements**
Each plant has specific water requirements:

#### **Water Calculation:**
```lua
farming_vegetableconf.calcWater = function(waterMin, waterLvl)
    if waterLvl >= waterMin then
        return 0  -- Well watered, normal growth
    elseif waterLvl >= math.floor(waterMin / 1.10) then
        return waterMin - waterLvl  -- Slightly dry, delayed growth
    elseif waterLvl >= math.floor(waterMin / 1.30) then
        return -1  -- Too dry, no growth
    else
        return -2  -- Severely dry, plant damage
    end
end
```

#### **Water Sources:**
- **Rain**: Natural watering for outdoor plants
- **Manual Watering**: Using watering cans or containers
- **Irrigation Systems**: Advanced farming setups

### **Environmental Factors**

#### **Weather Effects:**
```lua
function SFarmingSystem:checkWater(luaObject)
    if RainManager.isRaining() and luaObject.exterior then
        luaObject.waterLvl = luaObject.waterLvl + (30 * getClimateManager():getPrecipitationIntensity())
    elseif season.weather == "sunny" then
        luaObject.waterLvl = luaObject.waterLvl - 0.1  -- Evaporation
    end
end
```

#### **Seasonal Effects:**
- **Plant Growing Seasons**: Sandbox option affects planting success
- **Temperature**: Affects disease spread and plant health
- **Moon Cycle**: Influences initial plant health

## Disease System

### **Disease Types**

#### **1. Mildew** (`mildewLvl`)
- **Base Risk**: 2% chance per growth cycle
- **Spread**: Can spread to adjacent plants
- **Treatment**: GardeningSprayMilk
- **Effects**: Slows growth, reduces health

#### **2. Aphids** (`aphidLvl`)
- **Base Risk**: 2% chance per growth cycle
- **Seasonal**: More common in warm weather
- **Treatment**: GardeningSprayAphids
- **Effects**: Damages plant health

#### **3. Pest Flies** (`fliesLvl`)
- **Base Risk**: 2% chance per growth cycle
- **Visual**: Creates visible fly swarms
- **Treatment**: GardeningSprayCigarettes
- **Effects**: Increases water consumption

#### **4. Slugs** (`slugsLvl`)
- **Base Risk**: 2% chance per growth cycle
- **Seasonal**: Reduced in winter
- **Treatment**: SlugRepellent
- **Effects**: Damages plant health

### **Disease Progression**
```lua
function SPlantGlobalObject:upDisease()
    local water = farming_vegetableconf.calcWater(self.waterNeeded, self.waterLvl)
    
    -- Disease increases faster when plant is stressed
    if water >= 0 then
        self.mildewLvl = self.mildewLvl + 0.5  -- Well watered
    else
        self.mildewLvl = self.mildewLvl + 1    -- Stressed plant
    end
end
```

### **Companion Planting**
Some plants provide natural disease resistance:
- **AphidsBane**: Plants that repel aphids
- **FliesBane**: Plants that repel pest flies
- **SlugsBane**: Plants that repel slugs

## Plant Health System

### **Health Calculation**
```lua
function SFarmingSystem:getHealth()
    if season.moonCycle >= 4 and season.moonCycle < 18 then
        return ZombRand(47, 54)  -- Ascending moon
    elseif season.moonCycle >= 18 and season.moonCycle <= 21 then
        return ZombRand(57, 64)  -- Full moon (best)
    else
        return ZombRand(37, 44)  -- Descending moon (worst)
    end
end
```

### **Health Factors**
- **Initial Health**: Based on moon cycle and farming skill
- **Water Stress**: Poor watering reduces health
- **Disease**: All diseases reduce plant health
- **Fertilizer**: Can improve health and growth
- **Weeds**: Compete for resources

### **Health States**
- **Flourishing** (80-100): Optimal health
- **Verdant** (60-79): Good health
- **Healthy** (40-59): Normal health
- **Sickly** (20-39): Poor health
- **Stunted** (0-19): Dying plant

## Farming Tools and Equipment

### **Essential Tools**
- **Shovel/Trowel**: For plowing land
- **Watering Can**: For manual watering
- **Fertilizer**: For plant nutrition
- **Disease Treatments**: Various sprays for pest control

### **Advanced Equipment**
- **Scythe**: For clearing weeds and grass
- **Compost**: Natural fertilizer alternative
- **Irrigation Systems**: Automated watering

## Skill System

### **Farming Skill Progression**
```lua
function SFarmingSystem:gainXp(player, luaObject)
    local xp = luaObject.health / 2
    if luaObject.badCare == true then
        xp = xp - 15
    else
        xp = xp + 25
    end
    addXp(player, Perks.Farming, xp)
end
```

### **Skill Benefits**
- **Level 1-3**: Basic farming operations
- **Level 4+**: Can identify plant diseases
- **Level 6+**: Can see detailed plant information
- **Higher Levels**: Better plant health and yield

## Harvesting System

### **Harvest Mechanics**
```lua
function SFarmingSystem:harvest(luaObject, player)
    local skill = player:getPerkLevel(Perks.Farming)
    local props = farming_vegetableconf.props[luaObject.typeOfSeed]
    local numberOfVeg = getVegetablesNumber(props.minVeg, props.maxVeg, props.minVegAutorized, props.maxVegAutorized, luaObject, skill)
    
    if props.vegetableName and player then
        local items = player:getInventory():AddItems(props.vegetableName, numberOfVeg)
        sendAddItemsToContainer(player:getInventory(), items)
    end
end
```

### **Yield Factors**
- **Plant Health**: Healthier plants produce more
- **Farming Skill**: Higher skill increases yield
- **Fertilizer**: Improves yield potential
- **Disease**: Reduces yield significantly
- **Water**: Proper watering maximizes yield

## Sandbox Options

### **Plant Resilience**
- **Very High**: Plants require less water and are disease-resistant
- **High**: Reduced water needs and disease risk
- **Normal**: Standard farming mechanics
- **Low**: Increased water needs and disease risk
- **Very Low**: Plants are very fragile

### **Plant Growing Seasons**
- **Enabled**: Plants only grow in appropriate seasons
- **Disabled**: Plants grow year-round

## Code Architecture

### **Key Files:**

#### **Core Systems:**
- `media/lua/server/Farming/SFarmingSystem.lua` - Main farming logic
- `media/lua/client/Farming/CFarmingSystem.lua` - Client-side management
- `media/lua/server/Farming/SPlantGlobalObject.lua` - Individual plant logic

#### **Configuration:**
- `media/lua/server/Farming/farming_vegetableconf.lua` - Plant definitions
- `media/lua/shared/Translate/EN/Farming_EN.txt` - Localization

#### **UI Components:**
- `media/lua/client/Farming/ISUI/ISFarmingMenu.lua` - Farming interface
- `media/lua/client/Farming/ISUI/ISFarmingInfo.lua` - Plant information display

### **Data Flow:**
1. **SFarmingSystem** manages global plant updates every 10 minutes
2. **SPlantGlobalObject** handles individual plant growth and health
3. **CFarmingSystem** provides UI and player interaction
4. **farming_vegetableconf** defines plant properties and growth stages

## Summary

The farming system in Project Zomboid is a complex, realistic simulation that requires:

- **Strategic Planning**: Choosing appropriate crops and timing
- **Active Management**: Regular watering and disease control
- **Environmental Awareness**: Understanding weather and seasonal effects
- **Skill Development**: Learning through experience and practice

The system creates an engaging farming experience that balances realism with gameplay, requiring players to invest time and effort to master agricultural techniques while providing meaningful rewards for successful farming operations. 