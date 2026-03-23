# Louisville, KY Zone 6b Planting Calendar Analysis
# Project Zomboid PseudoAgriculture Mod Recommendations

**Created:** 2025-01-22
**Game Version:** Project Zomboid 42.11.0
**Location:** Louisville, KY (USDA Hardiness Zone 6b)
**Mod:** PseudoAgriculture (PseudoGPTFarming.lua)

---

## Executive Summary

This document provides research-based recommendations for adjusting the PseudoAgriculture mod's planting calendar to accurately reflect real-world growing seasons for Louisville, Kentucky (Zone 6b). The recommendations are based on multiple authoritative gardening sources and align with actual frost dates and optimal growing conditions.

---

## Louisville, KY Climate Data

### Key Dates
- **Last Spring Frost:** April 19-24 (average)
- **First Fall Frost:** October 20 (average)
- **Growing Season Length:** 170-205 days
- **USDA Hardiness Zone:** 6b
- **Soil Temperature Requirements:**
  - Cool-season crops: Above 55°F
  - Warm-season crops: Above 60°F

### Sources
- Web search results from Almanac.com, Garden.org, Kentucky Hort News
- Louisville Grows organization data
- UF Seeds Kentucky planting calendar
- Zone 6b general gardening guides

---

## Understanding Project Zomboid Month Indexing

**CRITICAL:** Project Zomboid uses **1-indexed months** in farming configuration:
- 1 = January
- 2 = February
- 3 = March
- 4 = April
- 5 = May
- 6 = June
- 7 = July
- 8 = August
- 9 = September
- 10 = October
- 11 = November
- 12 = December (or 0)

**Code Reference:** `media/lua/server/Farming/SPlantGlobalObject.lua:152-208`
```lua
if getGameTime():getMonth()+1 == prop.sowMonth[i] then
```
The game adds +1 to convert from 0-indexed to 1-indexed when comparing.

---

## How Month Types Work in Game

### sowMonth
**Purpose:** Defines when seeds CAN be planted
**Effect:** Seeds can only be planted during these months
**Penalty:** If you plant outside sowMonth but game allows it, plant becomes cursed

### badMonth
**Purpose:** Defines when plants will die or fail completely
**Effect:** Cannot plant at all during these months (game prevents it)

### bestMonth
**Purpose:** Defines optimal planting months
**Effect:**
- Higher starting health (57-64 + skill vs normal ~50 + skill)
- Chance for bonus yield: `ZombRand(20) < (9 + skill)`
- At skill 10: 19/20 = 95% bonus yield chance!

**Code Reference:** `SPlantGlobalObject.lua:742-743, 753-754`

### riskMonth
**Purpose:** Defines months with curse risk
**Effect:** Chance plant becomes cursed based on farming skill
- Formula: `ZombRand(20) < (11 - skill)`
- Skill 0: 55% curse chance
- Skill 4: 35% curse chance
- Skill 8: 15% curse chance
- Skill 10: 5% curse chance
- Cursed plants have lower health (37-44 + skill)

**Code Reference:** `SPlantGlobalObject.lua:741`

**IMPORTANT:** Month checks happen ONLY at planting time, not continuously!

---

## Real-World Louisville Planting Calendar

### March (Month 3) - Early Spring
**Real-world plantings:**
- **Direct Sow:** Lettuce, Spinach, Radishes, Peas, Carrots, Onions, Turnips
- **Start Indoors:** Tomatoes, Peppers, Eggplant (for May transplant)
- **Conditions:** Cool weather, soil warming up
- **Notes:** Can still have frost risk

### April (Month 4) - Spring
**Real-world plantings:**
- **Direct Sow:** Lettuce, Spinach, Radishes, Carrots, Beets, Kale
- **Transplant:** Broccoli, Cabbage, Cauliflower (started indoors Feb-March)
- **Conditions:** Last frost typically April 19-24
- **Notes:** Best month for cool-season crops

### May (Month 5) - Late Spring
**Real-world plantings:**
- **Transplant:** Tomatoes, Peppers, Eggplant (after May 5-15)
- **Direct Sow:** Beans, Corn, Cucumbers, Squash, Pumpkins
- **Conditions:** Soil above 60°F, frost danger passed
- **Notes:** Main warm-season planting month

### June (Month 6) - Early Summer
**Real-world plantings:**
- **Direct Sow:** Second planting of beans, corn
- **Start Indoors:** Broccoli, Cabbage, Cauliflower for fall (late June)
- **Conditions:** Warm, established growing season
- **Notes:** Succession planting month

### July (Month 7) - Summer
**Real-world plantings:**
- **Start Indoors:** Fall brassicas (early July)
- **Last Chance:** Final corn, beans planting (by July 1)
- **Conditions:** Hot, need consistent watering
- **Notes:** Planning for fall garden

### August (Month 8) - Late Summer
**Real-world plantings:**
- **Direct Sow:** Lettuce, Spinach, Radishes, Carrots, Turnips, Kale for fall
- **Transplant:** Broccoli, Cabbage, Cauliflower (early August)
- **Succession Plant:** Greens every 2 weeks
- **Conditions:** Still warm but cooling, dry period
- **Notes:** Major fall planting month

### September (Month 9) - Fall
**Real-world plantings:**
- **Direct Sow:** Quick crops like radishes, spinach, lettuce (early Sept)
- **Plant:** Garlic for next year's harvest
- **Conditions:** Cooling temperatures
- **Notes:** Last chance for quick-maturing fall crops

### October (Month 10) - Late Fall
**Real-world plantings:**
- **Plant:** Garlic continues
- **Harvest:** Fall crops before first frost (~Oct 20)
- **Conditions:** First frost approaching
- **Notes:** End of growing season


---

## Crop-by-Crop Recommendations

**Format:**
- **Vanilla PZ:** Original Project Zomboid settings
- **Your Mod:** Current PseudoAgriculture mod settings
- **Recommended:** Louisville, KY Zone 6b optimized settings

### Cool-Season Crops (Spring & Fall)

#### Broccoli

**Vanilla PZ Configuration:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7}
bestMonth = {3, 6}
riskMonth = {7}
badMonth = {9, 10, 11, 12, 1}
timeToGrow = 292
```

**Your Mod Configuration:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8}
bestMonth = {3, 8}
riskMonth = {2, 4, 5, 6, 7}
badMonth = {1}
timeToGrow = 432
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 8, 9}
bestMonth = {4, 8}
riskMonth = {3, 9}
badMonth = {1, 2, 5, 6, 7, 10, 11, 12}
timeToGrow = 432
```

**Reasoning:**
- Real-world: Plant April for spring harvest, August for fall harvest
- March/Sept are risky (frost concerns)
- April and August are optimal months
- Cannot survive summer heat (June-July) or winter (Nov-Feb)
- Your mod's longer growing time (432 vs 292) is more realistic

#### Cabbage
**Current Configuration:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8}
bestMonth = {3, 8}
riskMonth = {2, 4, 5, 6, 7}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 8, 9}
bestMonth = {4, 8}
riskMonth = {3, 9}
badMonth = {1, 2, 5, 6, 7, 10, 11, 12}
coldHardy = true
```

**Reasoning:**
- Same as broccoli - spring and fall crop
- Cold hardy trait should remain (can handle light frost)
- More tolerant of fall conditions than broccoli

#### Cauliflower
**Current Configuration:**
```lua
sowMonth = {6, 7, 8}
bestMonth = {8}
riskMonth = {6}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 8, 9}
bestMonth = {4, 8}
riskMonth = {3, 9}
badMonth = {1, 2, 5, 6, 7, 10, 11, 12}
```

**Reasoning:**
- Should match broccoli/cabbage pattern
- Current config is fall-only; should allow spring planting
- Most temperature-sensitive of the brassicas

#### Lettuce
**Current Configuration:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8, 9}
bestMonth = {3, 8}
riskMonth = {2, 4, 5, 6, 7}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 8, 9, 10}
bestMonth = {3, 4, 8, 9}
riskMonth = {10}
badMonth = {1, 2, 5, 6, 7, 11, 12}
```

**Reasoning:**
- Cool-season crop, bolts in summer heat
- Can plant early October for late fall harvest
- Best in spring (March-April) and fall (August-September)
- Cannot tolerate summer heat (May-July)

#### Spinach
**Current Configuration:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8, 9, 10}
bestMonth = {3, 9}
riskMonth = {2, 4, 5, 6, 7, 8}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 8, 9, 10}
bestMonth = {3, 4, 9}
riskMonth = {8, 10}
badMonth = {1, 2, 5, 6, 7, 11, 12}
```

**Reasoning:**
- Very cold-tolerant, can plant into October
- Best in cool weather (not hot August)
- Most cold-hardy of the greens
- Bolts quickly in warm weather

#### Kale
**Current Configuration:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8, 9}
bestMonth = {3, 8}
riskMonth = {2, 4, 5, 6, 7}
coldHardy = true
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 8, 9, 10}
bestMonth = {8, 9}
riskMonth = {3, 4, 10}
badMonth = {1, 2, 5, 6, 7, 11, 12}
coldHardy = true
growBack = 2
```

**Reasoning:**
- Actually BETTER in fall than spring
- Frost improves flavor (keep coldHardy)
- Can plant through October
- Grows back trait should remain

#### Carrots
**Current Configuration:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8}
bestMonth = {3, 8}
riskMonth = {2, 4, 5, 6, 7}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 5, 8, 9}
bestMonth = {4, 8}
riskMonth = {3, 5, 9}
badMonth = {1, 2, 6, 7, 10, 11, 12}
```

**Reasoning:**
- Spring (March-May) and late summer (August-September) plantings
- April and August are optimal
- Can tolerate light frost but not summer heat
- Direct sow only (game already handles this)

#### Radishes
**Current Configuration:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8, 9, 10}
bestMonth = {3, 9}
riskMonth = {2, 4, 5, 6, 7, 8}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 5, 8, 9, 10}
bestMonth = {3, 4, 9}
riskMonth = {5, 8, 10}
badMonth = {1, 2, 6, 7, 11, 12}
```

**Reasoning:**
- Very fast-growing (120 hours = 5 days)
- Can succession plant spring and fall
- Too hot in summer (June-July)
- Excellent config overall, just adjust slightly

#### Turnips
**Current Configuration:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8, 9}
bestMonth = {3, 8}
riskMonth = {2, 4, 5, 6, 7}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 8, 9}
bestMonth = {4, 8, 9}
riskMonth = {3}
badMonth = {1, 2, 5, 6, 7, 10, 11, 12}
```

**Reasoning:**
- Better in fall than spring
- August-September ideal planting
- Quick-growing fall crop
- Cool weather improves flavor

#### Greenpeas
**Current Configuration:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8, 9}
bestMonth = {3, 8}
riskMonth = {2, 4, 5, 6, 7}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 9}
bestMonth = {3, 4}
riskMonth = {9}
badMonth = {1, 2, 5, 6, 7, 8, 10, 11, 12}
```

**Reasoning:**
- Strictly early spring crop in Zone 6b
- Cannot tolerate heat at all
- March-April planting only
- Fall peas struggle in Kentucky climate
- Best planted very early spring

---

### Warm-Season Crops (Summer Only)

#### Tomatoes
**Current Configuration:**
```lua
sowMonth = {4, 5}
bestMonth = {5}
riskMonth = {4}
```

**Recommended Configuration:**
```lua
sowMonth = {5, 6}
bestMonth = {5}
riskMonth = {6}
badMonth = {1, 2, 3, 4, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Perfect timing for transplanting after last frost
- May 5-15 is ideal transplant window
- June planting is risky (late start)
- Current config is very good, just expand slightly

#### Bell Peppers
**Current Configuration:**
```lua
sowMonth = {4, 5}
bestMonth = {5}
riskMonth = {4}
```

**Recommended Configuration:**
```lua
sowMonth = {5, 6}
bestMonth = {5}
riskMonth = {6}
badMonth = {1, 2, 3, 4, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Same as tomatoes
- Need warm soil (60°F+)
- May transplanting is ideal
- Very frost-sensitive

#### Corn
**Current Configuration:**
```lua
sowMonth = {3, 4, 5}
bestMonth = {4}
riskMonth = {3}
```

**Recommended Configuration:**
```lua
sowMonth = {5, 6, 7}
bestMonth = {5, 6}
riskMonth = {7}
badMonth = {1, 2, 3, 4, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Needs warm soil, too cold in March/April
- May-June is ideal planting window
- July is last chance planting (risky)
- Can succession plant May-July

#### Cucumber
**Current Configuration:**
```lua
sowMonth = {3, 4}
bestMonth = {4}
riskMonth = {3}
```

**Recommended Configuration:**
```lua
sowMonth = {5, 6}
bestMonth = {5}
riskMonth = {6}
badMonth = {1, 2, 3, 4, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Very frost-sensitive
- Needs warm soil (65°F+)
- May-June planting only
- Current config is too early (March/April)

#### Zucchini
**Current Configuration:**
```lua
sowMonth = {3, 4}
bestMonth = {4}
riskMonth = {3}
```

**Recommended Configuration:**
```lua
sowMonth = {5, 6}
bestMonth = {5}
riskMonth = {6}
badMonth = {1, 2, 3, 4, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Same as cucumber
- Frost-sensitive
- Fast-growing, doesn't need early start
- May-June planting

#### Pumpkin
**Current Configuration:**
```lua
sowMonth = {4, 5}
bestMonth = {5}
riskMonth = {4}
```

**Recommended Configuration:**
```lua
sowMonth = {5, 6}
bestMonth = {5}
riskMonth = {6}
badMonth = {1, 2, 3, 4, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Needs 528 hours (22 days) to mature
- May planting gives October harvest (perfect!)
- June is risky but possible
- Current config is good, just shift one month later

#### Watermelon
**Current Configuration:**
```lua
sowMonth = {4, 5}
bestMonth = {5}
riskMonth = {4}
```

**Recommended Configuration:**
```lua
sowMonth = {5, 6}
bestMonth = {5}
riskMonth = {6}
badMonth = {1, 2, 3, 4, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Very heat-loving
- Needs warm soil
- May-June planting
- Same pattern as other warm-season crops

#### Soybeans
**Current Configuration:**
```lua
sowMonth = {4, 5}
bestMonth = {5}
riskMonth = {4}
```

**Recommended Configuration:**
```lua
sowMonth = {5, 6, 7}
bestMonth = {5, 6}
riskMonth = {7}
badMonth = {1, 2, 3, 4, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Can succession plant through early summer
- May-June ideal
- July is last chance planting
- More flexible than other warm crops

---

### Fall-Planted Overwintering Crops

#### Garlic
**Current Configuration:**
```lua
sowMonth = {9, 10}
bestMonth = {10}
riskMonth = {9}
```

**Recommended Configuration:**
```lua
sowMonth = {9, 10}
bestMonth = {10}
riskMonth = {9}
badMonth = {1, 2, 3, 4, 5, 6, 7, 8, 11, 12}
coldHardy = true
```

**Reasoning:**
- PERFECT current configuration!
- Plant in fall, harvest next summer
- October is ideal planting month
- September is acceptable but risky
- Should keep coldHardy trait

#### Onion
**Current Configuration:**
```lua
sowMonth = {1, 2, 3}
bestMonth = {3, 2}
riskMonth = {1}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 9, 10}
bestMonth = {3, 10}
riskMonth = {4, 9}
badMonth = {1, 2, 5, 6, 7, 8, 11, 12}
```

**Reasoning:**
- Can plant spring (March-April) OR fall (September-October)
- Spring onions: plant March-April, harvest summer
- Fall onions: plant September-October, overwinter, harvest next year
- More flexible than current config

---

### Grain Crops

#### Wheat
**Current Configuration:**
```lua
sowMonth = {8, 9, 10}
bestMonth = {9}
riskMonth = {8}
coldHardy = true
```

**Recommended Configuration:**
```lua
sowMonth = {9, 10}
bestMonth = {9}
riskMonth = {10}
badMonth = {1, 2, 3, 4, 5, 6, 7, 8, 11, 12}
coldHardy = true
```

**Reasoning:**
- EXCELLENT current configuration!
- Fall-planted winter wheat
- September ideal, October acceptable
- Overwinters, harvests in spring
- Keep coldHardy

#### Rye
**Current Configuration:**
```lua
sowMonth = {8, 9, 10}
bestMonth = {9}
riskMonth = {8}
```

**Recommended Configuration:**
```lua
sowMonth = {9, 10}
bestMonth = {9}
riskMonth = {10}
badMonth = {1, 2, 3, 4, 5, 6, 7, 8, 11, 12}
coldHardy = true
```

**Reasoning:**
- Same as wheat
- Fall-planted winter grain
- Should add coldHardy trait
- Most cold-tolerant grain

#### Barley
**Current Configuration:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8, 9, 10}
bestMonth = {3, 9}
riskMonth = {2, 5, 6, 7, 8}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 9, 10}
bestMonth = {3, 9}
riskMonth = {4, 10}
badMonth = {1, 2, 5, 6, 7, 8, 11, 12}
```

**Reasoning:**
- Can plant spring OR fall
- Spring barley: March-April
- Fall barley: September-October
- Current config too broad
- Both seasons should be available

---

### Other Crops

#### Potatoes
**Current Configuration:**
```lua
sowMonth = {2, 3}
bestMonth = {3}
riskMonth = {2}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4}
bestMonth = {3, 4}
riskMonth = {}
badMonth = {1, 2, 5, 6, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Early spring crop
- March-April planting (after ground thaws)
- No real risk in either month
- Frost-tolerant

#### Sweet Potato
**Current Configuration:**
```lua
sowMonth = {4, 5}
bestMonth = {5}
riskMonth = {4}
```

**Recommended Configuration:**
```lua
sowMonth = {5, 6}
bestMonth = {5}
riskMonth = {6}
badMonth = {1, 2, 3, 4, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Very heat-loving
- Needs warm soil (60°F+)
- May-June transplanting
- Longer growing season than regular potatoes

#### Strawberries
**Current Configuration:**
```lua
sowMonth = {2, 3, 4}
bestMonth = {3}
riskMonth = {2}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 9}
bestMonth = {3, 9}
riskMonth = {4}
badMonth = {1, 2, 5, 6, 7, 8, 10, 11, 12}
growBack = 2
```

**Reasoning:**
- Perennial - plant spring or fall
- March and September best for establishment
- April planting acceptable but less ideal
- Grows back trait should remain

#### Sugar Beets
**Current Configuration:**
```lua
sowMonth = {3, 4}
bestMonth = {4}
riskMonth = {3}
```

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 8}
bestMonth = {4, 8}
riskMonth = {3}
badMonth = {1, 2, 5, 6, 7, 9, 10, 11, 12}
```

**Reasoning:**
- Can plant spring or late summer
- Similar to regular beets
- August planting for fall harvest
- Cool-season crop

#### Sunflower
**Current Configuration:**
```lua
sowMonth = {3, 4, 5}
bestMonth = {4}
riskMonth = {3}
```

**Recommended Configuration:**
```lua
sowMonth = {5, 6}
bestMonth = {5}
riskMonth = {6}
badMonth = {1, 2, 3, 4, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Warm-season crop
- May-June planting
- Needs warm soil
- Fast-growing

#### Tobacco
**Current Configuration:**
```lua
sowMonth = {3, 4, 5}
bestMonth = {4}
riskMonth = {3}
```

**Recommended Configuration:**
```lua
sowMonth = {5, 6}
bestMonth = {5}
riskMonth = {6}
badMonth = {1, 2, 3, 4, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Heat-loving crop
- Traditional Kentucky crop
- May-June planting
- Long growing season (576 hours)

---

## Summary of Major Changes

### Crops That Were Too Early (Need Later Planting):
- Corn: 3,4,5 → 5,6,7
- Cucumber: 3,4 → 5,6
- Zucchini: 3,4 → 5,6
- Pumpkin: 4,5 → 5,6
- Watermelon: 4,5 → 5,6
- Tomatoes: 4,5 → 5,6
- Peppers: 4,5 → 5,6
- Sunflower: 3,4,5 → 5,6
- Tobacco: 3,4,5 → 5,6

### Crops That Need Fall Option Added:
- Onions: Add fall planting (9,10)
- Sugar Beets: Add August planting
- Barley: Restrict to spring/fall only

### Crops That Need Spring Option Added:
- Cauliflower: Currently fall-only, needs spring

### Crops That Are Already Good:
- Garlic: Perfect!
- Wheat: Excellent
- Rye: Very good
- Radishes: Good overall pattern

### Crops Needing More Restrictive Seasons:
- Greenpeas: Should be spring-only
- Lettuce: Remove summer months
- Spinach: Remove summer months
- All brassicas: Remove summer months

---

## Implementation Priority

### High Priority (Major Gameplay Impact):
1. **Warm-season crops** (tomatoes, peppers, cucumbers, etc.) - Currently plantable too early
2. **Cool-season brassicas** (broccoli, cabbage, cauliflower) - Need proper spring/fall split
3. **Greens** (lettuce, spinach, kale) - Need summer months removed

### Medium Priority (Balance Improvements):
4. **Grains** (barley) - Need more restrictive seasons
5. **Root crops** (carrots, turnips) - Minor timing adjustments
6. **Fall crops** (onions, sugar beets) - Need fall options added

### Low Priority (Fine-Tuning):
7. **Perennials** (strawberries) - Add fall planting option
8. **Specialty crops** (tobacco, sunflower) - Minor adjustments

---

## Testing Recommendations

After implementing changes, test the following scenarios:

### Spring Testing (March-May):
- Plant cool-season crops in March-April (lettuce, spinach, peas, broccoli)
- Verify warm-season crops CANNOT be planted before May
- Check that April plantings have good success rates

### Summer Testing (June-August):
- Verify cool-season crops CANNOT be planted June-July
- Check that August allows fall crop planting
- Test warm-season crops in May-June

### Fall Testing (September-October):
- Plant fall crops (brassicas, greens, root vegetables)
- Plant overwintering crops (garlic, wheat, rye)
- Verify proper frost tolerance

### Skill Level Testing:
- Test riskMonth mechanics at different farming skill levels
- Verify bestMonth gives bonus yields
- Check cursed plant survival rates

---

## Related Game Mechanics

### Frost Damage
The game doesn't explicitly model frost damage based on calendar dates. The month system controls:
- When you can plant
- Starting health of plants
- Bonus/curse mechanics

### Cold Hardy Trait
Crops with `coldHardy = true`:
- Cabbage
- Kale
- Wheat
- Garlic (should be added)
- Rye (should be added)

These can survive lower temperatures better.

---

## Future Considerations

### Potential Enhancements:
1. **Succession Planting:** Some crops (lettuce, radishes, beans) benefit from being planted every 2 weeks
   - Current system doesn't support this well
   - Could add more months to sowMonth with varying risk levels

2. **Regional Variations:** Kentucky has zones 6a, 6b, and 7a
   - Could create variants for different regions
   - Southern Kentucky (7a) would have longer season

3. **Climate Change:** Consider sandbox option for warmer/cooler climates
   - Shift months earlier/later based on settings

4. **Perennials:** Strawberries, asparagus (if added) need special handling
   - Grows back trait is good start
   - Multi-year crops not fully supported

---

## References

### Primary Sources:
- Almanac.com Planting Calendar for Louisville, KY
- Garden.org Zone 6b planting schedules
- Kentucky Hort News (University of Kentucky Extension)
- UF Seeds Kentucky vegetable planting calendar
- Louisville Grows planting calendar
- Fox Run Environmental Education Center Zone 6b guides

### Game Code References:
- `media/lua/server/Farming/SPlantGlobalObject.lua` - Plant mechanics
- `media/lua/server/Farming/farming_vegetableconf_vegetables.lua` - Vanilla vegetables
- `media/lua/server/Farming/farming_vegetableconf_herbs.lua` - Vanilla herbs
- `mymods/PseudoAgriculture/42/media/lua/server/PseudoGPTFarming.lua` - Current mod file

---

## Document Version History

**Version 1.0** - 2025-01-22
- Initial document creation
- Research compilation from multiple sources
- Comprehensive crop-by-crop recommendations
- Game mechanics documentation

---

## Notes for Implementation

When updating the mod file:
1. Back up the current version first
2. Update crops in order of priority (high → medium → low)
3. Test each major change before continuing
4. Document any deviations from these recommendations
5. Consider creating a changelog in the mod file header

**Reminder:** All month values use 1-indexed system (1=January, 12=December)
