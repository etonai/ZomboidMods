# PseudoAgriculture Mod Analysis - Data Comparison
# Based on Almanac.com and Extension Sources

**Created:** 2025-01-24
**Game Version:** Project Zomboid 42.11.0
**Location:** Louisville, KY (Zone 6b/7a)
**Mod File:** `mymods/PseudoAgriculture/42/media/lua/server/PseudoAlmanacFarming.lua`

---

## Purpose

This document provides an objective comparison between the PseudoAgriculture mod's planting windows and available research data. **No prescriptive recommendations are made.** The data is presented for evaluation.

---

## Climate Data - Louisville, KY

### Frost Dates (Almanac.com)
- **Last Spring Frost:** April 15-24
- **First Fall Frost:** October 20 - November 2
- **Growing Season:** ~170-205 days
- **Hardiness Zone:** 7a (updated 2023, formerly 6b)

---

## Month Index Reference

Project Zomboid uses 1-indexed months:
- 1=Jan, 2=Feb, 3=Mar, 4=Apr, 5=May, 6=Jun
- 7=Jul, 8=Aug, 9=Sep, 10=Oct, 11=Nov, 12=Dec

---

## Crop-by-Crop Data Comparison

### Format:
- **Mod Config:** What PseudoAgriculture currently has
- **Research Findings:** What sources indicate
- **Notes:** Relevant observations only

---

## WARM-SEASON CROPS

### Tomato

**Mod Config:**
```lua
sowMonth = {4, 5, 6, 7, 8}
bestMonth = {4}
riskMonth = {8}
```

**Research Findings:**
- Plant after last frost (mid-April+)
- Succession planting recommended: April 30, May 30, June 30
- Last safe planting: June 15 - July 1
- Aggressive planting possible to July 30 with fast varieties
- Fall harvest transplants: July 17-22

**Notes:** Mod's April-August window aligns with succession planting practices documented in UK Extension sources.

---

### Bell Pepper

**Mod Config:**
```lua
sowMonth = {4, 5}
bestMonth = {5}
riskMonth = {4}
```

**Research Findings:**
- Warm soil required (60°F+)
- Plant after last frost
- Similar timing to tomatoes
- Can succession plant through early summer

**Notes:** Mod is conservative; tomato-equivalent window would be April-July.

---

### Corn

**Mod Config:**
```lua
sowMonth = {3, 4, 5}
bestMonth = {4}
riskMonth = {3}
```

**Research Findings:**
- Sweet corn: June-July according to Burpee Kentucky calendar
- May-July documented as "summer gardening season"
- Succession planting every 2-3 weeks through early July
- Direct sow when soil is warm

**Notes:** Mod's March-May window does not include documented June-July summer planting period.

---

### Cucumber

**Mod Config:**
```lua
sowMonth = {3, 4, 5}
bestMonth = {4}
riskMonth = {3}
```

**Research Findings:**
- Very frost-sensitive (65°F soil requirement)
- May-July documented as "summer gardening season"
- Succession plantable

**Notes:** Mod's March planting is earlier than "May-July" summer season documentation.

---

### Zucchini

**Mod Config:**
```lua
sowMonth = {4, 5, 6, 7, 8, 9}
bestMonth = {5}
riskMonth = {9}
```

**Research Findings:**
- Frost-sensitive
- Warm-season crop
- Fast-growing, succession plantable

**Notes:** Mod has extended window (April-September).

---

### Pumpkin

**Mod Config:**
```lua
sowMonth = {4, 5, 6, 7}
bestMonth = {4}
riskMonth = {}
```

**Research Findings:**
- Plant for October harvest
- Needs 528 hours (22 game days)
- May-June typical planting

**Notes:** Mod includes April and July in addition to May-June main season.

---

### Watermelon

**Mod Config:**
```lua
sowMonth = {4, 5, 6, 7, 8}
bestMonth = {5}
riskMonth = {8}
```

**Research Findings:**
- Very heat-loving
- Long growing season
- May-June primary planting

**Notes:** Mod has extended window through August.

---

### Soybeans

**Mod Config:**
```lua
sowMonth = {4, 5, 6, 7}
bestMonth = {5}
riskMonth = {7}
```

**Research Findings:**
- Warm-season legume
- May-July planting documented
- Succession plantable

**Notes:** Mod configuration matches documented planting window.

---

### Sweet Potato

**Mod Config:**
```lua
sowMonth = {4, 5, 6, 7}
bestMonth = {5}
riskMonth = {7}
```

**Research Findings:**
- Very heat-loving
- Long season (480 hours = 20 days)
- Warm soil required (60°F+)

**Notes:** Mod has April-July window.

---

### Sunflower

**Mod Config:**
```lua
sowMonth = {3, 4, 5, 6, 7}
bestMonth = {4}
riskMonth = {5, 6}
```

**Research Findings:**
- Warm-season crop
- Direct sow after frost
- Fast-growing

**Notes:** Mod has March-July window.

---

### Tobacco

**Mod Config:**
```lua
sowMonth = {3, 4, 5, 6}
bestMonth = {4}
riskMonth = {3}
```

**Research Findings:**
- Traditional Kentucky crop
- Heat-loving
- Long season (576 hours = 24 days)

**Notes:** Mod has March-June window.

---

## COOL-SEASON CROPS

### Lettuce

**Mod Config:**
```lua
sowMonth = {3, 4, 9, 10}
bestMonth = {3, 9}
riskMonth = {10}
```

**Research Findings:**
- Spring: March-April (earliest March 25 in central KY)
- Fall: Direct seed August 21 OR start indoors July 2, transplant August 11
- Cool-season crop, bolts in heat

**Notes:** Mod has spring (March-April) and fall (September-October) windows but does not include August planting documented for fall crops.

---

### Broccoli

**Mod Config:**
```lua
sowMonth = {3, 4, 5, 7, 8, 9}
bestMonth = {3, 4, 8}
riskMonth = {5, 7, 9}
```

**Research Findings:**
- Spring: Start indoors January 29, transplant March 19; OR direct seed February 26; earliest planting April 5 (central KY)
- Fall: Start indoors July 2, transplant August 11; OR direct seed August 21
- Cool-season brassica

**Notes:** Mod includes both spring (March-May) and fall (July-September) planting windows with June excluded (too hot).

---

### Cabbage

**Mod Config:**
```lua
sowMonth = {3, 4, 7, 8, 9}
bestMonth = {3, 8}
riskMonth = {2, 4, 7, 9}
coldHardy = true
```

**Research Findings:**
- Spring: Start indoors January 29, transplant March 19; OR direct seed February 26; earliest March 25 (central KY)
- Fall: Plant by July 1-15 (central/western KY); Start indoors July 2, transplant August 11; OR direct seed August 21
- Very cold-hardy

**Notes:** Mod includes spring and fall windows, with July marked as risky (consistent with "by July 1-15" deadline).

---

### Cauliflower

**Mod Config:**
```lua
sowMonth = {3, 4, 7, 8}
bestMonth = {4, 8}
riskMonth = {7}
```

**Research Findings:**
- Similar to broccoli/cabbage
- Most temperature-sensitive brassica
- Spring and fall crop

**Notes:** Mod similar to broccoli but without May/September (more conservative).

---

### Kale

**Mod Config:**
```lua
sowMonth = {3, 4, 8, 9}
bestMonth = {3, 8}
riskMonth = {}
coldHardy = true
growBack = 2
```

**Research Findings:**
- Cool-season green
- Late July/August planting for fall
- Very cold-hardy
- Frost improves flavor

**Notes:** Mod has spring and fall windows with no risk months.

---

### Spinach

**Mod Config:**
```lua
sowMonth = {3, 4, 8, 9, 10}
bestMonth = {3, 9}
riskMonth = {8}
```

**Research Findings:**
- Very cold-tolerant
- Spring: March-April (earliest March 25 in central KY)
- Fall: Start indoors July 2, transplant August 11; OR direct seed August 21
- Can plant later than most greens

**Notes:** Mod has spring and fall windows extending into October (reflects cold tolerance).

---

### Carrots

**Mod Config:**
```lua
sowMonth = {2, 3, 4, 8, 9}
bestMonth = {3, 8}
riskMonth = {2, 4, 9}
```

**Research Findings:**
- Cool-season root crop
- Spring: March-May
- Fall: July-August plantings
- Direct sow (doesn't transplant well)

**Notes:** Mod has spring (February-April) and fall (August-September) windows but excludes July.

---

### Radishes

**Mod Config:**
```lua
sowMonth = {3, 4, 5, 6, 7, 8, 9, 10}
bestMonth = {4, 9}
riskMonth = {10}
```

**Research Findings:**
- Very fast-growing (5 game days)
- Succession plant every 2-3 weeks
- Spring through fall
- Cool-season but tolerates heat better than most

**Notes:** Mod has wide planting window (March-October) reflecting succession planting capability.

---

### Turnips

**Mod Config:**
```lua
sowMonth = {3, 4, 5, 6, 7, 8, 9, 10}
bestMonth = {3, 9}
riskMonth = {10}
```

**Research Findings:**
- Cool-season root crop
- Spring and fall crop
- Late July/August best for fall
- Quick-growing

**Notes:** Mod has very wide window (March-October).

---

### Greenpeas

**Mod Config:**
```lua
sowMonth = {3, 4, 8, 9}
bestMonth = {3, 9}
riskMonth = {}
```

**Research Findings:**
- Spring: Mid-March (6-8 weeks before last frost)
- Fall: Zone 6b fall peas planted July 15-30
- Plant 6-8 weeks before first fall frost
- For October 20 frost: August 25-September 1 planting
- Maturity: 60-70 days (9-11 weeks)

**Notes:** Mod has spring (March-April) and fall (August-September) windows. Research indicates July 15-30 for fall planting, which is 6-8 weeks before October 20 frost, supporting August/September plantings.

---

## PERENNIALS & SPECIAL CROPS

### Potatoes

**Mod Config:**
```lua
sowMonth = {3, 4, 5, 6, 7, 8}
bestMonth = {3, 4}
riskMonth = {}
```

**Research Findings:**
- Early spring crop
- March-April main planting (after ground thaws)
- Can plant through May for succession

**Notes:** Mod has extended window through August.

---

### Onion

**Mod Config:**
```lua
sowMonth = {3, 4, 5, 6, 7, 8}
bestMonth = {3}
riskMonth = {8}
badMonth = {1, 2, 8, 9, 10, 11, 12}  // NOTE: 8 appears in both sowMonth and badMonth
```

**Research Findings:**
- Spring onions: March-April
- Fall onions: September-October (overwinter)
- Flexible crop with dual seasons

**Notes:** Mod configuration appears to have inconsistency (month 8 in both sowMonth and badMonth). Research supports spring AND fall planting.

---

### Strawberries

**Mod Config:**
```lua
sowMonth = {2, 3, 4}
bestMonth = {3}
riskMonth = {2}
growBack = 2
```

**Research Findings:**
- Perennial
- Plant spring or fall for establishment
- March and September typical

**Notes:** Mod has spring-only window.

---

### Sugar Beets

**Mod Config:**
```lua
sowMonth = {3, 4, 8, 9}
bestMonth = {4}
riskMonth = {}
```

**Research Findings:**
- Cool-season root crop
- Similar to beets
- Spring and late summer planting

**Notes:** Mod has spring (March-April) and fall (August-September) windows.

---

## GRAINS

### Wheat

**Mod Config:**
```lua
sowMonth = {8, 9, 10, 11}
bestMonth = {10}
riskMonth = {8, 11}
coldHardy = true
```

**Research Findings:**
- Winter wheat: Fall planted, overwinters
- September-October planting
- Harvests in spring

**Notes:** Mod configuration appropriate for winter wheat.

---

### Rye

**Mod Config:**
```lua
sowMonth = {8, 9, 10, 11}
bestMonth = {10}
riskMonth = {8, 11}
```

**Research Findings:**
- Winter rye: Fall planted
- Most cold-tolerant grain
- September-October planting

**Notes:** Mod matches wheat pattern. Missing coldHardy trait that wheat has.

---

### Barley

**Mod Config:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8, 9, 10}
bestMonth = {3, 9}
riskMonth = {2, 5, 6, 7, 8}
```

**Research Findings:**
- Can be spring OR winter barley
- Spring barley: March-April
- Winter barley: September-October

**Notes:** Mod has very wide window (February-October) with many risk months.

---

### Garlic

**Mod Config:**
```lua
sowMonth = {9, 10}
bestMonth = {10}
riskMonth = {9}
coldHardy = true
```

**Research Findings:**
- Fall planted, overwinters
- September-October planting
- Harvest next summer

**Notes:** Mod configuration matches documented practice.

---

## Summary Observations

### Crops Where Mod Matches Research:
- Soybeans
- Garlic
- Wheat
- Broccoli/Cabbage/Cauliflower (dual season modeling)
- Kale
- Spinach
- Radishes (succession planting)
- Greenpeas (spring + fall)

### Crops Where Mod Has Wider Windows Than Basic Research:
- Tomatoes (April-August vs typical April-June)
- Watermelon (April-August)
- Potatoes (March-August vs March-May)
- Turnips (March-October)
- Barley (February-October)

### Crops Where Mod Has Narrower Windows:
- Bell Peppers (April-May vs could include June-July)
- Corn (March-May vs documented May-July)

### Crops With Potential Issues:
- Onion: Month 8 appears in both sowMonth and badMonth
- Lettuce: Missing August for fall plantings (documented August 21 direct seed or July 2 start/August 11 transplant)
- Carrots: Missing July for fall plantings

### Notes on Succession Planting:
The mod's extended planting windows for many crops (tomatoes, radishes, potatoes, turnips) may reflect succession planting practices where crops are planted multiple times throughout the season rather than once at "ideal" time. UK Extension documentation recommends 2-4 plantings per season for many crops.

---

## Mod Name Suggestions

Current name "PseudoAgriculture" does not indicate regional focus.

**Current Preference: "Kentucky Realistic Farming"**

### Alternative Options:

**Clear & Descriptive:**
- Kentucky Gardens
- Louisville Seasons
- Kentucky Growing Seasons
- Almanac Farming KY

**Rejected Options:**
- Bluegrass Gardens (requires knowing Kentucky is the Bluegrass State)
- Zone 7a Farming (requires understanding hardiness zones)
- Derby City Gardens (requires knowing Louisville is Derby City)

---

## References

### Data Sources Used:
- **Almanac.com:** Louisville, KY planting calendar
- **University of Kentucky Cooperative Extension Service:**
  - ID-128: Home Vegetable Gardening in Kentucky
  - Kentucky Hort News succession planting guides
- **Garden.org:** Louisville planting schedules
- **Zone-specific sources:** Zone 6b/7a planting information
- **Burpee:** Kentucky planting calendar
- **Fox Run Environmental Education Center:** Zone 6b planting schedule

### Game Code References:
- `media/lua/server/Farming/SPlantGlobalObject.lua` - Plant mechanics
- `mymods/PseudoAgriculture/42/media/lua/server/PseudoAlmanacFarming.lua` - Mod configuration

---

## Document Purpose

This document provides data comparison only. No recommendations for changes are made. The mod creator can evaluate whether the mod's configurations align with their design goals and research sources.

**Created:** 2025-01-24
**Analysis Method:** Objective data comparison
**Approach:** Descriptive, not prescriptive
