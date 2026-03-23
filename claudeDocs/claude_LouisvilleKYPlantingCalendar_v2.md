# Louisville, KY Zone 7a Planting Calendar Analysis (REVISED)
# Project Zomboid PseudoAgriculture Mod Evaluation

**Created:** 2025-01-22
**Revised:** 2025-01-24
**Game Version:** Project Zomboid 42.11.0
**Location:** Louisville, KY (USDA Hardiness Zone 7a, formerly 6b)
**Mod:** PseudoAgriculture (PseudoAlmanacFarming.lua)

---

## Executive Summary

**PREVIOUS ANALYSIS WAS TOO RESTRICTIVE**

After deeper research into University of Kentucky Extension recommendations and Louisville gardening practices, the PseudoAgriculture mod is **significantly more accurate** than initially assessed. The mod correctly accounts for:

1. **Succession planting** - Multiple planting windows throughout the growing season
2. **Summer plantings for fall harvest** - July/August plantings of cool-season crops
3. **Extended warm-season windows** - Tomatoes, peppers, and other warm crops through July
4. **Louisville's long growing season** - 170-205 days allows later plantings

The mod's extended planting windows and "risky" month designations align well with real-world Kentucky Extension guidance for succession planting and season extension.

---

## Louisville, KY Climate Data (UPDATED)

### Key Dates
- **Last Spring Frost:** April 19-24 (average)
- **First Fall Frost:** October 20-30 (average)
- **Growing Season Length:** 170-205 days
- **USDA Hardiness Zone:** **7a** (updated 2023, was 6b)
  - Jefferson County nearly surrounded by Zone 6b
  - Zone 7a allows for extended season and later plantings
- **Soil Temperature Requirements:**
  - Cool-season crops: Above 55°F
  - Warm-season crops: Above 60°F

### Sources
- University of Kentucky Cooperative Extension Service
- Kentucky Hort News succession planting guides
- USDA 2023 Hardiness Zone update
- Almanac.com, Garden.org data
- Louisville Grows planting calendars

---

## Understanding Succession Planting in Kentucky

**Succession planting** is a standard Kentucky gardening practice involving multiple plantings throughout the season for continuous harvest. This is CRITICAL to understanding the mod's design.

### Succession Planting Strategy

**Tomatoes & Peppers:**
- UK Extension recommends 2-4 plantings per season
- Example schedule: April 30 (with protection), May 30, June 30
- **Last safe planting: June 15 - July 1**
- **Aggressive planting: Up to July 30** with 50-55 day varieties
- For fall harvest: Transplant July 17-22 (100 days before frost)

**Beans, Corn, Squash, Cucumbers:**
- Easily succession planted every 2-3 weeks
- Plantings can continue through early-mid July

**Cool-Season Crops:**
- Spring planting: March-April
- **Summer planting for fall: July-August**
- Cabbage: July 1-15
- Lettuce, kale, turnips: Late July/August
- Carrots, beets: July-August

This explains why the mod has LONGER planting windows than expected - it's designed for season extension!

---

## Understanding Project Zomboid Month Indexing

**CRITICAL:** Project Zomboid uses **1-indexed months** in farming configuration:
- 1 = January, 2 = February, 3 = March, 4 = April
- 5 = May, 6 = June, 7 = July, 8 = August
- 9 = September, 10 = October, 11 = November, 12 = December

**Code Reference:** `media/lua/server/Farming/SPlantGlobalObject.lua:152-208`
```lua
if getGameTime():getMonth()+1 == prop.sowMonth[i] then
```

---

## How Month Types Work in Game

### sowMonth
**Purpose:** Defines when seeds CAN be planted
**Effect:** Seeds can only be planted during these months
**Penalty:** If you plant outside sowMonth, plant becomes cursed

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

## Revised Crop Analysis: Warm-Season Crops

### Tomatoes ✅ **MOD IS ACCURATE**

**Mod Configuration:**
```lua
sowMonth = {4, 5, 6, 7, 8}
bestMonth = {4}
riskMonth = {8}
badMonth = {9, 10, 11, 12, 1, 2, 3}
```

**Real-World Practice (UK Extension):**
- Succession planting: April 30, May 30, June 30
- Last safe planting: June 15 - July 1
- Aggressive: Up to July 30 with fast varieties (50-55 days)
- Fall harvest transplants: July 17-22

**VERDICT:** ✅ **Mod configuration is EXCELLENT!**
- April-July normal planting window matches Extension guidance
- August marked as risky (very late planting) is appropriate
- bestMonth=4 correctly identifies optimal spring planting
- **Previous recommendation to restrict to May-June was WRONG**

**Recommended Action:** **NO CHANGE NEEDED** - Mod is accurate as-is

---

### Bell Peppers ✅ **MOD IS ACCURATE**

**Mod Configuration:**
```lua
sowMonth = {4, 5}
bestMonth = {5}
riskMonth = {4}
badMonth = {9, 10, 11, 12, 1, 2, 3}
```

**Real-World Practice:**
- Same as tomatoes: Can plant through June-July
- 100-day varieties can be transplanted July 17-22

**VERDICT:** 🟨 **Mod is slightly conservative but acceptable**
- Current April-May window works for transplanting
- Could add June (maybe July as risky) for succession planting
- But current config is safe and playable

**Recommended Action:** **OPTIONAL:** Add `sowMonth = {4, 5, 6}` with `riskMonth = {4, 6}`

---

### Corn ⚠️ **MOD NEEDS EXPANSION**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 5}
bestMonth = {4}
riskMonth = {3}
badMonth = {1, 2, 6, 7, 8, 9, 10, 11, 12}
```

**Real-World Practice:**
- Direct sow May-July
- Succession planting every 2-3 weeks through early July
- Hot weather plantable crop

**VERDICT:** ⚠️ **Too restrictive - missing June-July**

**Recommended Configuration:**
```lua
sowMonth = {4, 5, 6, 7}
bestMonth = {5, 6}
riskMonth = {4, 7}
badMonth = {1, 2, 3, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Add June-July for succession planting (standard practice)
- April risky (early, soil may be cool)
- July risky (late planting, heat stress possible)
- May-June optimal planting window

---

### Cucumber ⚠️ **MOD SLIGHTLY EARLY**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 5}
bestMonth = {4}
riskMonth = {3}
badMonth = {6, 7, 8, 9, 10, 11, 12, 1, 2}
```

**Real-World Practice:**
- Very frost-sensitive (needs 65°F soil)
- May-June planting ideal
- Can succession plant

**VERDICT:** ⚠️ **March is too early, missing June**

**Recommended Configuration:**
```lua
sowMonth = {4, 5, 6}
bestMonth = {5}
riskMonth = {4, 6}
badMonth = {1, 2, 3, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- March too cold for cucumbers (65°F soil requirement)
- Add June for succession planting
- May optimal

---

### Pumpkin ⚠️ **MOD NEEDS ADJUSTMENT**

**Mod Configuration:**
```lua
sowMonth = {4, 5, 6, 7}
bestMonth = {4}
riskMonth = {}
badMonth = {1, 2, 3, 8, 9, 10, 11, 12}
```

**Real-World Practice:**
- Plant May-June for October harvest
- Needs 528 hours (22 days) to mature
- July planting possible but very late

**VERDICT:** 🟨 **April is early, but July inclusion is correct**

**Recommended Configuration:**
```lua
sowMonth = {5, 6, 7}
bestMonth = {5, 6}
riskMonth = {7}
badMonth = {1, 2, 3, 4, 8, 9, 10, 11, 12}
```

**Reasoning:**
- May-June optimal for October harvest
- July acceptable but risky (late start)
- April too early (frost risk)

---

### Watermelon ⚠️ **MOD NEEDS EXPANSION**

**Mod Configuration:**
```lua
sowMonth = {4, 5, 6, 7, 8}
bestMonth = {5}
riskMonth = {8}
badMonth = {9, 10, 11, 12, 1, 2, 3}
```

**Real-World Practice:**
- Very heat-loving
- May-June primary planting
- Can plant into early summer

**VERDICT:** ✅ **Actually quite good!**
- Wide window reflects heat tolerance
- August risky is appropriate

**Recommended Action:** **NO CHANGE NEEDED** - Current config is accurate

---

### Zucchini ⚠️ **MOD NEEDS ADJUSTMENT**

**Mod Configuration:**
```lua
sowMonth = {4, 5, 6, 7, 8, 9}
bestMonth = {5}
riskMonth = {9}
badMonth = {10, 11, 12, 1, 2, 3}
```

**Real-World Practice:**
- Frost-sensitive, needs warm soil
- May-June primary planting
- Fast-growing, succession plantable

**VERDICT:** ⚠️ **April too early, summer window too long**

**Recommended Configuration:**
```lua
sowMonth = {5, 6, 7}
bestMonth = {5, 6}
riskMonth = {7}
badMonth = {1, 2, 3, 4, 8, 9, 10, 11, 12}
```

**Reasoning:**
- May-June optimal planting
- July succession planting possible but late
- April too early (frost risk)
- August-September too late

---

### Soybeans ✅ **MOD IS ACCURATE**

**Mod Configuration:**
```lua
sowMonth = {4, 5, 6, 7}
bestMonth = {5}
riskMonth = {7}
badMonth = {10, 11, 12, 1, 2, 3, 8, 9}
```

**Real-World Practice:**
- May-July planting
- Succession plantable
- Flexible warm-season crop

**VERDICT:** ✅ **Excellent configuration!**
- Matches UK Extension guidance
- July as risky is appropriate

**Recommended Action:** **NO CHANGE NEEDED**

---

### Sweet Potato ✅ **MOD IS ACCURATE**

**Mod Configuration:**
```lua
sowMonth = {4, 5, 6, 7}
bestMonth = {5}
riskMonth = {7}
badMonth = {8, 9, 10, 11, 12, 1, 2, 3}
```

**Real-World Practice:**
- Very heat-loving, long season
- May-June transplanting
- July possible but late

**VERDICT:** ✅ **Good configuration!**
- April might be slightly early but acceptable for southern KY
- July risky is appropriate

**Recommended Action:** **OPTIONAL:** Make April risky too: `riskMonth = {4, 7}`

---

## Revised Crop Analysis: Cool-Season Crops

### Lettuce ✅ **MOD IS ACCURATE**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 9, 10}
bestMonth = {3, 9}
riskMonth = {10}
badMonth = {1, 2, 5, 6, 7, 8, 11, 12}
```

**Real-World Practice:**
- Spring: March-April
- **Summer planting for fall: Late July-August**
- Can plant into October

**VERDICT:** ⚠️ **Missing summer fall-planting window!**

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 8, 9, 10}
bestMonth = {3, 4, 9}
riskMonth = {8, 10}
badMonth = {1, 2, 5, 6, 7, 11, 12}
```

**Reasoning:**
- Add August for fall planting (standard KY practice)
- August risky (hot weather, bolting risk)
- Spring and fall windows maintained
- **Previous recommendation to remove summer was based on misunderstanding - it's for FALL HARVEST plantings!**

---

### Broccoli 🟨 **MOD IS VERY GOOD**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 5, 7, 8, 9}
bestMonth = {3, 4, 8}
riskMonth = {5, 7, 9}
badMonth = {1, 2, 6, 10, 11, 12}
```

**Real-World Practice:**
- Spring: April transplants (started indoors Feb-March)
- **Fall: July transplants (started indoors June), August transplants**
- Mid-summer (June-July) is bad for mature plants

**VERDICT:** ✅ **Excellent! Reflects succession planting!**
- Spring window: 3-5 (March-May)
- Summer gap: 6 (June) correctly excluded
- Fall planting: 7-9 (July-September)
- Risk months (5, 7, 9) correctly identify season edges

**Recommended Action:** **NO CHANGE NEEDED** - Mod understands the dual-season nature!

---

### Cabbage ✅ **MOD IS EXCELLENT**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 7, 8, 9}
bestMonth = {3, 8}
riskMonth = {2, 4, 7, 9}
badMonth = {1, 5, 6, 10, 11, 12}
```

**Real-World Practice:**
- Spring: March-April transplants
- **Fall: Plant by July 1-15 (central KY)**
- Summer (May-June) too hot for mature plants

**VERDICT:** ✅ **Perfect configuration!**
- Matches UK Extension "plant by July 1-15" guidance
- Correctly excludes summer
- July risky is appropriate (late for fall planting)

**Recommended Action:** **NO CHANGE NEEDED**

---

### Cauliflower ✅ **MOD IS EXCELLENT**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 7, 8}
bestMonth = {4, 8}
riskMonth = {7}
badMonth = {1, 2, 5, 6, 9, 10, 11, 12}
```

**Real-World Practice:**
- Same as broccoli/cabbage
- Spring and fall crop
- Most temperature-sensitive brassica

**VERDICT:** ✅ **Excellent! More conservative than broccoli (no Sept) - appropriate for most sensitive brassica**

**Recommended Action:** **NO CHANGE NEEDED**

---

### Kale ✅ **MOD IS EXCELLENT**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 8, 9}
bestMonth = {3, 8}
riskMonth = {}
coldHardy = true
growBack = 2
```

**Real-World Practice:**
- Spring: March-April
- **Fall: August (best month)**
- Most cold-hardy green
- Frost improves flavor

**VERDICT:** ✅ **Perfect! Recognizes fall superiority!**

**Recommended Action:** **NO CHANGE NEEDED**

---

### Spinach ✅ **MOD IS EXCELLENT**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 8, 9, 10}
bestMonth = {3, 9}
riskMonth = {8}
badMonth = {1, 2, 5, 6, 7, 11, 12}
```

**Real-World Practice:**
- Very cold-tolerant
- Spring: March-April
- **Fall: August-October**
- Can plant latest of all greens

**VERDICT:** ✅ **Excellent! Reflects spinach's cold tolerance!**

**Recommended Action:** **NO CHANGE NEEDED**

---

### Carrots ⚠️ **MOD MISSING JULY**

**Mod Configuration:**
```lua
sowMonth = {2, 3, 4, 8, 9}
bestMonth = {3, 8}
riskMonth = {2, 4, 9}
badMonth = {1, 5, 6, 7, 10, 11, 12}
```

**Real-World Practice:**
- Spring: March-May
- **Fall: July-August plantings**
- Cool-season root crop

**VERDICT:** ⚠️ **Missing July for fall plantings**

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 5, 7, 8, 9}
bestMonth = {4, 8}
riskMonth = {3, 5, 7, 9}
badMonth = {1, 2, 6, 10, 11, 12}
```

**Reasoning:**
- Add May (spring planting extension)
- Add July (fall planting start)
- Both months risky (season edges)

---

### Radishes ✅ **MOD IS EXCELLENT**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 5, 6, 7, 8, 9, 10}
bestMonth = {4, 9}
riskMonth = {10}
badMonth = {1, 2, 11, 12}
```

**Real-World Practice:**
- Fast-growing (5 days in game!)
- Succession plant every 2-3 weeks
- Spring through fall

**VERDICT:** ✅ **Perfect! Wide window reflects succession planting potential!**

**Recommended Action:** **NO CHANGE NEEDED**

---

### Turnips ⚠️ **MOD TOO WIDE**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 5, 6, 7, 8, 9, 10}
bestMonth = {3, 9}
riskMonth = {10}
badMonth = {1, 2, 11, 12}
```

**Real-World Practice:**
- Spring: March-April
- **Fall: August-September (better than spring)**
- Quick-growing fall crop

**VERDICT:** ⚠️ **May-July window questionable**

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 8, 9, 10}
bestMonth = {8, 9}
riskMonth = {3, 10}
badMonth = {1, 2, 5, 6, 7, 11, 12}
```

**Reasoning:**
- Remove May-July (too hot)
- Focus on fall (better season for turnips)
- Keep spring as option but less optimal

---

### Greenpeas ⚠️ **MOD NEEDS ADJUSTMENT**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 8, 9}
bestMonth = {3, 9}
riskMonth = {}
badMonth = {1, 2, 5, 6, 7, 10, 11, 12}
```

**Real-World Practice:**
- Strictly early spring crop in Kentucky
- Cannot tolerate heat at all
- March-April planting only
- Fall peas struggle in KY climate

**VERDICT:** ⚠️ **August-September questionable for Kentucky**

**Recommended Configuration:**
```lua
sowMonth = {3, 4}
bestMonth = {3, 4}
riskMonth = {}
badMonth = {1, 2, 5, 6, 7, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Peas are spring-only in Kentucky
- Fall peas rarely successful in Zone 7a
- Best planted very early spring

---

## Revised Crop Analysis: Other Crops

### Potatoes 🟨 **MOD WIDE BUT PLAYABLE**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 5, 6, 7, 8}
bestMonth = {3, 4}
riskMonth = {}
badMonth = {1, 2, 9, 10, 11, 12}
```

**Real-World Practice:**
- Early spring crop
- March-April planting (after ground thaws)
- Can plant through May for different harvest times

**VERDICT:** 🟨 **Wide window but reflects staggered planting**
- June-August questionable but doesn't break gameplay
- bestMonth correctly identifies March-April

**Recommended Action:** **OPTIONAL:** Restrict to `sowMonth = {3, 4, 5}` with `riskMonth = {5}`

---

### Onion ⚠️ **MOD MISSING FALL PLANTING**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 5, 6, 7, 8}
bestMonth = {3}
riskMonth = {8}
badMonth = {1, 2, 8, 9, 10, 11, 12}  // NOTE: 8 in BOTH sowMonth and badMonth - BUG?
```

**Real-World Practice:**
- Spring onions: March-April
- **Fall onions: September-October (overwinter)**
- Flexible crop with two seasons

**VERDICT:** ⚠️ **Missing fall planting, possible bug with month 8**

**Recommended Configuration:**
```lua
sowMonth = {3, 4, 9, 10}
bestMonth = {3, 10}
riskMonth = {4, 9}
badMonth = {1, 2, 5, 6, 7, 8, 11, 12}
```

**Reasoning:**
- Add fall planting window
- Remove confusing May-August window
- Fix month 8 appearing in both sowMonth and badMonth

---

### Sunflower ⚠️ **MOD NEEDS ADJUSTMENT**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 5, 6, 7}
bestMonth = {4}
riskMonth = {5, 6}
badMonth = {1, 2, 8, 9, 10, 11, 12}
```

**Real-World Practice:**
- Warm-season crop
- May-June planting
- Needs warm soil
- Fast-growing

**VERDICT:** ⚠️ **March too early, July missing**

**Recommended Configuration:**
```lua
sowMonth = {4, 5, 6, 7}
bestMonth = {5, 6}
riskMonth = {4, 7}
badMonth = {1, 2, 3, 8, 9, 10, 11, 12}
```

**Reasoning:**
- Remove March (too cold)
- May-June optimal
- July acceptable for succession

---

### Tobacco ⚠️ **MOD NEEDS ADJUSTMENT**

**Mod Configuration:**
```lua
sowMonth = {3, 4, 5, 6}
bestMonth = {4}
riskMonth = {3}
badMonth = {7, 8, 9, 10, 11, 12, 1, 2}
```

**Real-World Practice:**
- Traditional Kentucky crop
- Heat-loving, long season (576 hours)
- May-June planting

**VERDICT:** ⚠️ **March too early, missing July**

**Recommended Configuration:**
```lua
sowMonth = {4, 5, 6, 7}
bestMonth = {5}
riskMonth = {4, 7}
badMonth = {1, 2, 3, 8, 9, 10, 11, 12}
```

---

### Grains (Wheat, Rye, Barley)

**Wheat ✅ EXCELLENT:**
```lua
sowMonth = {8, 9, 10, 11}
bestMonth = {10}
riskMonth = {8, 11}
coldHardy = true
```
**VERDICT:** Perfect for winter wheat! **NO CHANGE**

**Rye ✅ EXCELLENT:**
```lua
sowMonth = {8, 9, 10, 11}
bestMonth = {10}
riskMonth = {8, 11}
```
**VERDICT:** Perfect! Consider adding `coldHardy = true`

**Barley ⚠️ TOO WIDE:**
```lua
sowMonth = {2, 3, 4, 5, 6, 7, 8, 9, 10}
bestMonth = {3, 9}
riskMonth = {2, 5, 6, 7, 8}
```
**RECOMMENDED:** Restrict to spring/fall only: `sowMonth = {3, 4, 9, 10}`

---

### Garlic ✅ **PERFECT**

**Mod Configuration:**
```lua
sowMonth = {9, 10}
bestMonth = {10}
riskMonth = {9}
coldHardy = true
```

**Real-World:** Plant September-October, overwinter, harvest next summer

**VERDICT:** ✅ **Absolutely perfect!**

---

## Summary: How Good Is This Mod?

### Overall Assessment: **MUCH BETTER THAN INITIALLY THOUGHT**

The PseudoAgriculture mod demonstrates a **sophisticated understanding** of Kentucky gardening that includes:

1. ✅ **Succession planting** - Extended windows for tomatoes, corn, beans
2. ✅ **Fall harvest plantings** - July-August plantings of brassicas and greens
3. ✅ **Dual-season crops** - Broccoli, cabbage, cauliflower correctly split
4. ✅ **Risk-based gameplay** - riskMonth creates interesting skill-based decisions
5. ✅ **Cold-hardy traits** - Properly assigned to winter crops

### Crops That Are Already Excellent:
- **Tomato** - Perfect succession planting window
- **Soybeans** - Correct extended warm-season window
- **Watermelon** - Good heat-tolerant window
- **Broccoli/Cabbage/Cauliflower** - Excellent dual-season modeling
- **Kale** - Perfect fall-focused config
- **Spinach** - Excellent cold-tolerance window
- **Radishes** - Perfect succession planting model
- **Garlic** - Absolutely perfect fall planting
- **Wheat/Rye** - Excellent winter grain configs

### Crops Needing Minor Adjustments (High Priority):
1. **Corn** - Add June-July for succession (sowMonth: 4-7)
2. **Carrots** - Add July for fall planting (sowMonth: 3-5, 7-9)
3. **Lettuce** - Add August for fall planting (sowMonth: 3, 4, 8-10)
4. **Onion** - Add fall planting window (sowMonth: 3, 4, 9, 10)
5. **Cucumber** - Remove March, add June (sowMonth: 4-6)
6. **Greenpeas** - Restrict to spring only (sowMonth: 3, 4)

### Crops Needing Minor Adjustments (Medium Priority):
7. **Turnips** - Remove May-July (sowMonth: 3, 4, 8-10)
8. **Zucchini** - Remove April and late months (sowMonth: 5-7)
9. **Pumpkin** - Remove April (sowMonth: 5-7)
10. **Sunflower** - Remove March, add July (sowMonth: 4-7)
11. **Tobacco** - Remove March, add July (sowMonth: 4-7)
12. **Barley** - Restrict to spring/fall (sowMonth: 3, 4, 9, 10)

### Crops That Need No Changes:
- Tomato, Soybeans, Watermelon, Sweet Potato
- Broccoli, Cabbage, Cauliflower, Kale, Spinach
- Radishes, Garlic, Wheat, Rye
- Bell Pepper (acceptable as-is)

---

## Mod Name Suggestions

The current name "PseudoAgriculture" doesn't reflect its accuracy. Here are better alternatives:

### Top Recommendations (Short & Clear):

1. **"Kentucky Gardens"** - Simple, direct, indicates regional focus
2. **"Louisville Seasons"** - Clear geographic and temporal focus
3. **"KY Realistic Farming"** - Indicates accuracy and region
4. **"Bluegrass Gardens"** - Kentucky nickname, evocative
5. **"Zone 7a Farming"** - Technical, indicates hardiness zone accuracy

### Alternative Options:

6. **"Derby City Gardens"** - Louisville nickname
7. **"KY Extended Season"** - Highlights succession planting feature
8. **"Almanac Farming KY"** - Suggests research-based accuracy
9. **"True Kentucky Seasons"** - Emphasizes accuracy
10. **"Realistic KY Gardens"** - Clear intent

### My Top Pick:

**"Kentucky Gardens"** or **"Bluegrass Gardens"**
- Short (2 words)
- Clearly indicates geographic focus
- Accessible to players (non-technical)
- Professional sounding
- Reflects actual Louisville gardening practices

---

## Implementation Recommendations

### Priority Order:

**Phase 1: Critical Fixes (Improve Gameplay)**
1. Corn - Add summer succession planting
2. Lettuce - Add fall planting window
3. Carrots - Add summer/fall planting
4. Onion - Add fall planting, fix month 8 bug

**Phase 2: Balance Improvements**
5. Cucumber, Pumpkin, Zucchini - Adjust early/late bounds
6. Greenpeas - Restrict to spring
7. Turnips - Remove summer months
8. Barley - Restrict to spring/fall

**Phase 3: Fine-Tuning**
9. Sunflower, Tobacco - Minor adjustments
10. Bell Peppers - Optional expansion
11. Potatoes - Optional restriction

---

## Key Insights from This Revision

### What I Got Wrong Initially:

1. **Underestimated succession planting** - Didn't account for multiple plantings per season
2. **Missed fall-harvest summer plantings** - July/August plantings of cool-season crops for fall
3. **Too focused on "ideal" windows** - Real gardeners plant across wider ranges
4. **Ignored Louisville's long season** - 170-205 days allows later plantings
5. **Didn't research UK Extension** - Authoritative source shows wider practices

### What the Mod Gets Right:

1. **Extended planting windows** - Reflects real succession planting
2. **Risk-based system** - Matches real-world "possible but not ideal" planting dates
3. **Dual-season crops** - Brassicas correctly modeled for spring AND fall
4. **Cold-hardy mechanics** - Properly identifies winter-tolerant crops
5. **Gameplay balance** - Wide windows create interesting strategic decisions

---

## References

### Primary Sources (Updated):
- **University of Kentucky Cooperative Extension Service**
  - ID-128: Home Vegetable Gardening in Kentucky (the "Bible")
  - Kentucky Hort News: Succession Planting articles
  - UK Extension succession planting guides
- Almanac.com Planting Calendar for Louisville, KY
- Garden.org Zone 6b/7a planting schedules
- Louisville Grows planting calendar
- USDA 2023 Hardiness Zone update

### Game Code References:
- `media/lua/server/Farming/SPlantGlobalObject.lua` - Plant mechanics
- `media/lua/server/Farming/farming_vegetableconf_vegetables.lua` - Vanilla vegetables
- `mymods/PseudoAgriculture/42/media/lua/server/PseudoAlmanacFarming.lua` - Mod file

---

## Document Version History

**Version 1.0** - 2025-01-22
- Initial document creation
- Research compilation from multiple sources
- Comprehensive crop-by-crop recommendations
- **ISSUE:** Too restrictive, didn't account for succession planting

**Version 2.0** - 2025-01-24
- **MAJOR REVISION** based on UK Extension research
- Added succession planting understanding
- Recognized summer plantings for fall harvest
- Corrected Louisville hardiness zone to 7a
- Revised crop recommendations (many crops now "no change needed")
- Overall assessment: Mod is MUCH more accurate than initially thought
- Added mod naming suggestions

---

## Conclusion

The PseudoAgriculture mod is a **well-researched, sophisticated farming mod** that accurately represents Louisville, Kentucky gardening practices including succession planting and season extension techniques.

With minor adjustments (primarily adding missing July plantings for corn, carrots, and lettuce), this mod will be an **excellent realistic farming experience** for Project Zomboid.

The mod deserves a name that reflects its accuracy - **"Kentucky Gardens"** or **"Bluegrass Gardens"** would be appropriate replacements for "PseudoAgriculture."
