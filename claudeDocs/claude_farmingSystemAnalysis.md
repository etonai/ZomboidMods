# Project Zomboid Farming System Analysis

*Updated: August 21, 2025*

## Overview

Project Zomboid features a sophisticated farming system that simulates realistic agricultural mechanics including plant growth cycles, disease management, environmental factors, seasonal growing, and skill-based progression. The system balances complexity with accessibility, offering both casual food production and advanced agricultural optimization.

## Core Architecture

### Java-Lua Integration

**Java Components:**
- Core timing and persistence systems
- World object management and synchronization
- Server-client communication for multiplayer farming

**Lua Components:**
- `SFarmingSystem.lua` - Server-side farming logic and plant management
- `SPlantGlobalObject.lua` - Individual plant behavior and state management
- `farming_vegetableconf.lua` - Plant species configuration and growth mechanics
- `CFarmingSystem.lua` - Client-side UI and interaction handling

### Global Object System

Farming utilizes Project Zomboid's Global Object System (GOS) for:
- **Persistent Storage**: Plant data saved in `gos_farming.bin` files
- **Cross-Session Continuity**: Plants continue growing when players are offline
- **Multiplayer Synchronization**: Server authoritative with client UI updates
- **Performance Optimization**: Only active farming areas are processed

## Plant Growth Mechanics

### Growth Stages

**Stage 0 (Seeded):**
- Initial planting stage
- Requires first watering within 48 hours
- Health determined by planting conditions and skill

**Stages 1-4 (Growing):**
- Progressive visual changes and size increases
- Water requirements increase with growth stage
- Disease vulnerability develops after Stage 1

**Stage 5 (Mature/Harvest Level):**
- Ready for harvest with full yield
- Optimal nutritional and seed values
- Can continue growing to seed stage if left unharvested

**Stage 6 (Full Grown/Seed Bearing):**
- Produces seeds for replanting
- Reduced food yield but maximum seed production
- Some plants (herbs) reset to earlier stages after harvest

**Stage 7+ (Overripe/Rotten):**
- Yield deteriorates over time
- Eventually becomes completely rotten and unusable

### Growth Timing

**Base Growth Time Formula:**
```
actualGrowTime = baseTime × timeFactor × diseaseModifier × waterModifier
```

**Time Factors:**
- **Sandbox Speed**: FarmingSpeedNew setting (0.5x to 3x multiplier)
- **Fertilization**: Reduces growth time by 40 hours per application
- **Disease**: Adds 30-50 hours depending on severity
- **Water Stress**: Adds hours based on water deficit
- **Random Variation**: ±12 hour randomization per growth stage

**Typical Growth Times:**
- **Fast Herbs**: 484 hours (20 days) - Basil, Chives, Cilantro
- **Medium Vegetables**: 292 hours (12 days) - Broccoli, Cabbage, Tomatoes
- **Slow Crops**: 432 hours (18 days) - Corn, Carrots, Potatoes

## Plant Species System

### Vegetables (28+ Species)

**Brassicas (Cool Season):**
- Broccoli, Cabbage, Cauliflower - High water needs (70-80), cold hardy
- Growing Season: February-July, optimal in March-May
- Disease: Susceptible to moth infestations

**Root Vegetables:**
- Carrots, Radishes, Potatoes - Moderate water (30-70)
- Extended growing seasons, some cold hardy to 4+ stages
- High yield potential (3-15 vegetables per plant)

**Nightshades (Warm Season):**
- Tomatoes, Bell Peppers, Eggplant - High water (70-80)
- Heat loving, killed by early/late season cold
- Growing Season: April-September, optimal April-June

**Legumes:**
- Green Beans, Peas - Nitrogen fixing properties
- Companion planting benefits for nearby crops
- Moderate water requirements

**Grains:**
- Corn, Barley, Oats - Tall crops with high positions
- Scythe harvestable, produce grain and straw
- Barley is cold hardy, corn requires warm season

### Herbs (15+ Species)

**Culinary Herbs:**
- Basil, Cilantro, Chives, Oregano, Parsley - Enhanced food preparation
- "GrowBack" property: Reset to Stage 2 after harvest for continuous yield
- Pest-resistant properties (aphids, flies, slugs bane/proof)

**Medicinal Herbs:**
- Comfrey, Plantain, Black Sage - Medical application benefits
- Specialized growing requirements and seasonal restrictions
- Higher skill requirements for optimal cultivation

**Flowers:**
- Chamomile, Marigold - Happiness and boredom reduction on harvest
- Ornamental and companion planting benefits
- Some provide pest control for neighboring plants

### Companion Planting System

**Pest Control Benefits:**
- **Aphids Bane**: Chives, Garlic repel aphids from adjacent plants
- **Flies Bane**: Basil, Marigold reduce fly infestations
- **Slugs Proof**: Cilantro, Chives naturally resistant to slugs
- **Effect Range**: Adjacent 8 squares around beneficial plants
- **Maturity Requirement**: Companion plants must reach Stage 3+ for benefits

## Environmental Factors

### Seasonal System

**Seasonal Settings (Sandbox Option):**
- **Disabled**: All plants grow year-round regardless of season
- **Enabled**: Realistic seasonal restrictions and bonuses

**Monthly Growing Cycles:**
- **Sow Months**: Optimal planting periods for each species
- **Best Months**: +10-15% health bonus, increased bonus yield chance
- **Risk Months**: 50% chance of "cursed" status reducing health
- **Bad Months**: Automatic "cursed" status, continuous health loss

**Winter Effects:**
- Cold kills non-hardy plants below 10°C
- Indoor/greenhouse cultivation possible for some species
- Pest activity (flies, aphids, slugs) greatly reduced
- Some plants (herbs) go dormant but survive

### Weather Impact

**Sunny Weather:**
- +1.0 health per update cycle for outdoor plants
- +0.25 health for indoor plants (reduced sunlight)
- Increases water evaporation rate

**Temperature Effects:**
- **Above 10°C**: Normal growth and pest activity
- **Below 10°C**: -0.5 health per cycle for non-cold-hardy plants
- **Extreme Cold**: Automatic plant death regardless of care

**Rainfall Benefits:**
- Automatic watering for outdoor plants
- Water gain: `30 × precipitation intensity`
- Saves manual watering time and effort

### Light and Location

**Indoor vs Outdoor:**
- **Outdoor**: Full environmental effects, weather benefits/penalties
- **Indoor**: Reduced health gain, protection from weather
- **Greenhouse Detection**: Special room type provides outdoor benefits indoors
- **Natural Light**: Indoor plants suffer multiplied penalties without adequate light

**Weed Competition:**
- Nearby vegetation competes for resources
- Doubles water consumption rate
- Doubles disease susceptibility
- Increases all negative health modifiers
- Removed automatically when plowing, requires maintenance afterward

## Water Management

### Water Requirements

**Water Level Mechanics:**
- **Current Water**: 0-100 scale representing soil moisture
- **Required Water**: Species-specific minimum for healthy growth
- **Maximum Water**: Upper threshold before overwatering penalties

**Water Calculation:**
```lua
if waterLevel >= requiredWater then
    return 0  -- Optimal conditions
elseif waterLevel >= requiredWater / 1.10 then
    return (requiredWater - waterLevel)  -- Slight stress, growth delay
elseif waterLevel >= requiredWater / 1.30 then
    return -1  -- Growth stopped, 5-hour delay
else
    return -2  -- Plant dying, major health loss
end
```

**Watering Sources:**
- **Watering Can**: +10 water per use, most efficient
- **Garden Hose**: Connected to plumbing, unlimited supply
- **Natural Rain**: Automatic outdoor watering during precipitation
- **Sprinkler Systems**: Automated watering coverage (with mods)

**Water Depletion:**
- Base rate: 1 point every 2-12 hours (sandbox dependent)
- Weed multiplier: 2x consumption with competing vegetation
- Fly infestation: Additional 1 point per 10 fly levels
- Sunny weather: Accelerated evaporation

## Disease Management

### Disease Types

**Mildew:**
- Fungal infection affecting all plant types
- Spreads to adjacent plants in wet conditions
- Treatment: Mildew spray, farming skill reduces severity

**Aphids:**
- Insect infestation preferring warm weather
- Ironically reduced by drought conditions (water level -1/-2)
- Treatment: Insecticide, companion planting with chives/garlic

**Flies:**
- Visible swarms when fly level exceeds 30
- Affects entire tile with visual fly effects
- Treatment: Insecticide, companion planting with basil/marigold

**Slugs:**
- Moisture-loving pests preferring wet conditions
- Naturally resistant plants: cilantro, chives
- Treatment: Pesticide application, drought conditions

### Disease Progression

**Initial Infection Chance:**
```
baseChance = waterDeficit + environmentalFactors
if cursed: chance × 2
if hasWeeds: chance × 2
if bonusYield: chance × 0.5

infectionRoll = random(200) <= modifiedChance
```

**Disease Spread:**
- Infected plants spread to adjacent tiles (8-directional)
- Weedy conditions double transmission chance
- Companion plants provide immunity to specific diseases
- Disease severity increases 0.5-1.0 points per update cycle

**Health Impact:**
- Each disease type reduces plant health
- Combined diseases can quickly kill plants
- Severe infections (>30 level) prevent growth entirely
- Winter naturally reduces outdoor pest pressure

### Treatment System

**Chemical Treatments:**
- **Mildew Spray**: 10 + farming skill reduction per application
- **Insecticide**: 10 + farming skill reduction for flies/aphids
- **Pesticide**: 10 + farming skill reduction for slugs
- **Application Efficiency**: Higher farming skill = more effective treatments

**Organic Management:**
- **Companion Planting**: Adjacent beneficial plants provide immunity
- **Environmental Control**: Drought conditions reduce certain pests
- **Crop Rotation**: Prevents disease buildup in soil (implied mechanic)

## Soil and Fertilization

### Soil Preparation

**Plowing Mechanics:**
- Creates tilled soil suitable for planting
- Removes competing vegetation and weeds
- Sets tile to optimal planting state
- Furrows fade after 30 days if unused (1/20000 chance per check)

**Fertilization System:**

**First Application Benefits:**
- Growth time reduced by 40 hours
- Health increase by 10 points
- Bonus yield chance if applied early (stages 0-3)
- No negative effects from single application

**Over-fertilization Penalties:**
- **Second Application**: -25 health penalty
- **Third+ Applications**: "Cursed" status, -25 health per application
- **Plant Death**: Health reaches 0 from over-fertilization

**Composting Alternative:**
- Single application without toxicity risk
- Same benefits as regular fertilizer
- Cannot be over-applied (safe option)

### Moon Cycle Influence

**Planting Health Bonus:**
- **Ascending Moon** (cycles 4-17): 47-53 base health
- **Full Moon** (cycles 18-21): 57-64 base health (optimal)
- **Descending Moon** (cycles 22-3): 37-44 base health
- **Farming Skill Bonus**: Added to base health during planting

## Skill System

### Farming Skill Progression

**Level Benefits:**
- **0-2**: Basic plant information, limited tooltip details
- **3-4**: Water level visibility, disease identification
- **5-7**: Advanced plant statistics, treatment efficiency bonuses
- **8-10**: Expert-level information, maximum treatment effectiveness

**Experience Gain Formula:**
```
baseXP = plantHealth / 2
if goodCare: baseXP + 25
if badCare: baseXP - 15
finalXP = clamp(baseXP, 1, 100)
```

**Skill Applications:**
- **Planting**: Higher skill increases initial plant health
- **Treatment**: Skill level added to disease cure effectiveness
- **Yield Calculation**: 10% chance per skill level for bonus vegetable
- **Seasonal Bonuses**: Affects cursed/bonus yield chances in risk/best months

### Harvest Mechanics

**Yield Calculation:**
```
baseYield = random(minVeg, maxVeg)
healthModifier = (plantHealth - 50) / 10
pestReduction = (aphidLevel + slugLevel) / 10
skillBonus = random(10) < farmingSkill ? farmingSkill : 0
bonusYieldMultiplier = bonusYield ? max(baseYield, secondRoll) : baseYield

finalYield = (baseYield + healthModifier - pestReduction + skillBonus) × sandboxMultiplier
```

**Seed Production:**
- Only available from fully grown plants (stage 6+)
- Seeds per vegetable: Usually 0.5-1.0 ratio
- Essential for sustainable farming operations

**Special Harvest Types:**
- **Scythe Harvest**: Grains (corn, barley) require scythe tool
- **High Position**: Some plants harvested from elevated growth
- **Continuous Harvest**: Herbs regrow after harvesting (strawberries, herbs)

## Sandbox Configuration

### Growth Speed Settings
- **FarmingSpeedNew**: 0.5x to 3x growth speed multiplier
- **FarmingAmountNew**: 0.5x to 2x yield multiplier

### Plant Resilience Settings
- **Very High**: -8 disease chance modifier, 12-hour water cycles
- **High**: -4 disease chance modifier, 8-hour water cycles  
- **Normal**: Standard disease and water mechanics
- **Low**: +4 disease chance modifier, 3-hour water cycles
- **Very Low**: +8 disease chance modifier, 2-hour water cycles

### Seasonal Options
- **PlantGrowingSeasons**: Enable/disable seasonal growing restrictions
- **KillInsideCrops**: Indoor plants die without greenhouse conditions

## Advanced Mechanics

### Greenhouse System

**Greenhouse Detection:**
- Rooms with "greenhouse" in name provide optimal conditions
- Combines outdoor benefits with indoor protection
- Allows year-round cultivation of outdoor crops
- Protects from weather while providing full sun benefits

### Automation and Efficiency

**NPC Integration (Planned):**
- Automated watering by NPC helpers
- Reduced micromanagement for large farms
- Currently disabled in code but framework exists

**Crop Rotation Benefits:**
- Implied through companion planting system
- Disease resistance through diversity
- Soil improvement via nitrogen fixers (beans, peas)

### Performance Optimization

**Processing Efficiency:**
- Only loaded chunks process farming updates
- Batch updates every 10 minutes for plant health changes
- Global state persistence allows offline growth continuation

**Memory Management:**
- Old plant data automatically cleaned up
- Harvested/destroyed plants fade after time periods
- Efficient storage in binary format files

## Economic and Survival Impact

### Food Security

**Nutritional Benefits:**
- Fresh vegetables provide vitamins and happiness bonuses
- Superior nutrition compared to canned/processed foods
- Essential for long-term character health maintenance

**Crop Diversity Advantages:**
- Different vegetables provide varying nutritional profiles
- Staggered planting ensures continuous food supply
- Seasonal optimization maximizes yield efficiency

### Resource Management

**Time Investment vs. Return:**
- Initial setup and learning curve substantial
- Long-term benefits exceed canned food dependency
- Skill development creates exponential returns

**Material Requirements:**
- Seeds: Renewable through proper harvesting
- Water: Major ongoing resource requirement
- Tools: Hand tools sufficient, specialized equipment beneficial
- Fertilizer: Optional but significantly beneficial

## Technical Implementation Details

### File Structure

**Core System Files:**
- `SFarmingSystem.lua` - Server-side plant management and timing
- `SPlantGlobalObject.lua` - Individual plant state and behavior
- `farming_vegetableconf.lua` - Plant species configuration database
- `CFarmingSystem.lua` - Client UI and interaction handling

**Configuration Files:**
- `farming_vegetableconf_vegetables.lua` - Vegetable species definitions
- `farming_vegetableconf_herbs.lua` - Herb and medicinal plant definitions
- UI components for farming information and management

### Data Persistence

**Save System:**
- Plant states saved in `gos_farming.bin` files
- Cross-session continuity maintained
- Server authoritative for multiplayer consistency
- Automatic migration from legacy GameTime storage

### Network Architecture

**Client-Server Communication:**
- Server processes all farming logic
- Clients handle UI and player input
- State synchronization ensures multiplayer consistency
- Command-based interaction system for security

## Conclusion

Project Zomboid's farming system represents one of the most sophisticated agricultural simulations in survival gaming. The system successfully balances realistic complexity with accessible gameplay, offering both casual food production and deep agricultural optimization. 

Key strengths include:
- **Depth**: Complex interactions between weather, disease, seasons, and plant biology
- **Balance**: Risk/reward systems that encourage skill development
- **Persistence**: Continuous growth and state management across game sessions
- **Scalability**: Supports both small gardens and large agricultural operations

The system's integration of environmental factors, seasonal growing, disease management, and skill progression creates an engaging long-term gameplay loop that complements Project Zomboid's survival mechanics while providing sustainable food security for dedicated players.