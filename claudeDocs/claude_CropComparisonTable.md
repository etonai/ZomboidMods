# Crop Planting Comparison Table
# Vanilla PZ vs PseudoAgriculture Mod vs Louisville KY Recommendations

**Created:** 2025-01-22
**Game Version:** Project Zomboid 42.11.0
**Companion Document:** claude_LouisvilleKYPlantingCalendar.md

---

## How to Read This Table

**Month Key (1-indexed):**
- 1=Jan, 2=Feb, 3=Mar, 4=Apr, 5=May, 6=Jun
- 7=Jul, 8=Aug, 9=Sep, 10=Oct, 11=Nov, 12=Dec

**Configuration Types:**
- **Vanilla PZ:** Base game settings
- **Your Mod:** Current PseudoAgriculture settings
- **Recommended:** Louisville, KY Zone 6b optimized

---

## Cool-Season Crops (Spring & Fall)

### Broccoli

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4,5,6,7 | 2,3,4,5,6,7,8 | 3,4,8,9 |
| **bestMonth** | 3,6 | 3,8 | 4,8 |
| **riskMonth** | 7 | 2,4,5,6,7 | 3,9 |
| **badMonth** | 9,10,11,12,1 | 1 | 1,2,5,6,7,10,11,12 |
| **timeToGrow** | 292 | 432 | 432 |
| **Notes** | June best strange | Aug best good | Spring+Fall only |

### Cabbage

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4,5,6,7 | 2,3,4,5,6,7,8 | 3,4,8,9 |
| **bestMonth** | 3,5 | 3,8 | 4,8 |
| **riskMonth** | 7 | 2,4,5,6,7 | 3,9 |
| **badMonth** | 10,11,12,1 | 1 | 1,2,5,6,7,10,11,12 |
| **coldHardy** | true | true | true |
| **timeToGrow** | 292 | 432 | 432 |
| **Notes** | May best odd | Aug best good | Spring+Fall, cold hardy |

### Cauliflower

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4 | 6,7,8 | 3,4,8,9 |
| **bestMonth** | 3 | 8 | 4,8 |
| **riskMonth** | 4 | 6 | 3,9 |
| **badMonth** | 9,10,11,12,1 | 1,2,3,4,5 | 1,2,5,6,7,10,11,12 |
| **timeToGrow** | 292 | 432 | 432 |
| **Notes** | Spring only | Fall only | Need both seasons |

### Carrots

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4,5,6,7 | 2,3,4,5,6,7,8 | 3,4,5,8,9 |
| **bestMonth** | 2,6 | 3,8 | 4,8 |
| **riskMonth** | 7 | 2,4,5,6,7 | 3,5,9 |
| **badMonth** | 1,10,11,12 | 12,1 | 1,2,6,7,10,11,12 |
| **timeToGrow** | 432 | 360 | 360 |
| **Notes** | Feb best too early | Good pattern | Spring+Late summer |

### Kale

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4,5,6,7,8 | 2,3,4,5,6,7,8,9 | 3,4,8,9,10 |
| **bestMonth** | 3,7 | 3,8 | 8,9 |
| **riskMonth** | 8 | 2,4,5,6,7 | 3,4,10 |
| **badMonth** | 11,12,1 | 1 | 1,2,5,6,7,11,12 |
| **coldHardy** | true | true | true |
| **growBack** | 2 | 2 | 2 |
| **timeToGrow** | - | 336 | 336 |
| **Notes** | Jul best ok | Aug best better | BEST in fall |

### Lettuce

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4,7,8,9 | 2,3,4,5,6,7,8,9 | 3,4,8,9,10 |
| **bestMonth** | 3,7 | 3,8 | 3,4,8,9 |
| **riskMonth** | 9 | 2,4,5,6,7 | 10 |
| **badMonth** | 10,11,12,1 | 1 | 1,2,5,6,7,11,12 |
| **timeToGrow** | - | 288 | 288 |
| **Notes** | Good pattern | Too broad | Remove summer |

### Spinach

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4,5,6,7 | 2,3,4,5,6,7,8,9,10 | 3,4,8,9,10 |
| **bestMonth** | 3,6 | 3,9 | 3,4,9 |
| **riskMonth** | 7 | 2,4,5,6,7,8 | 8,10 |
| **badMonth** | 9,10,11,12,1 | 1 | 1,2,5,6,7,11,12 |
| **timeToGrow** | - | 192 | 192 |
| **Notes** | June best wrong | Too broad | Cold-hardy, not Aug |

### Greenpeas

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4 | 2,3,4,5,6,7,8,9 | 3,4,9 |
| **bestMonth** | 3 | 3,8 | 3,4 |
| **riskMonth** | 4 | 2,4,5,6,7 | 9 |
| **badMonth** | 10,11,12,1 | 1 | 1,2,5,6,7,8,10,11,12 |
| **timeToGrow** | - | 288 | 288 |
| **Notes** | Good | WAY too broad | Spring ONLY crop |

### Radishes

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4,5,6,7,8 | 2,3,4,5,6,7,8,9,10 | 3,4,5,8,9,10 |
| **bestMonth** | 3,7 | 3,9 | 3,4,9 |
| **riskMonth** | 8 | 2,4,5,6,7,8 | 5,8,10 |
| **badMonth** | 9,10,11,12,1 | 12,1 | 1,2,6,7,11,12 |
| **timeToGrow** | - | 120 | 120 |
| **Notes** | Good | Good overall | Fast crop |

### Turnips

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4,5,6,7 | 2,3,4,5,6,7,8,9 | 3,4,8,9 |
| **bestMonth** | 3,6 | 3,8 | 4,8,9 |
| **riskMonth** | 7 | 2,4,5,6,7 | 3 |
| **badMonth** | 9,10,11,12,1 | 1 | 1,2,5,6,7,10,11,12 |
| **timeToGrow** | - | 264 | 264 |
| **Notes** | June best wrong | Good change | Better in fall |

---

## Warm-Season Crops (Summer Only)

### Tomatoes

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 4,5,6 | 4,5 | 5,6 |
| **bestMonth** | 5 | 5 | 5 |
| **riskMonth** | 6 | 4 | 6 |
| **badMonth** | 10,11,12,1,2,3 | 9,10,11,12,1,2,3 | 1,2,3,4,7,8,9,10,11,12 |
| **timeToGrow** | - | 288 | 288 |
| **Notes** | Good | April too early | May transplant best |

### Bell Peppers

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 4,5,6 | 4,5 | 5,6 |
| **bestMonth** | 5 | 5 | 5 |
| **riskMonth** | 6 | 4 | 6 |
| **badMonth** | 10,11,12,1,2,3 | 9,10,11,12,1,2,3 | 1,2,3,4,7,8,9,10,11,12 |
| **timeToGrow** | 292 | 336 | 336 |
| **Notes** | Good | April too early | Same as tomatoes |

### Corn

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 3,4,5 | 3,4,5 | 5,6,7 |
| **bestMonth** | 4 | 4 | 5,6 |
| **riskMonth** | 5 | 3 | 7 |
| **badMonth** | 8,9,10,11,12,1,2 | 10,11,12,1,2 | 1,2,3,4,8,9,10,11,12 |
| **timeToGrow** | 432 | 432 | 432 |
| **Notes** | Too early | Way too early | Needs warm soil |

### Cucumber

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 3,4,5 | 3,4 | 5,6 |
| **bestMonth** | 4 | 4 | 5 |
| **riskMonth** | 5 | 3 | 6 |
| **badMonth** | 8,9,10,11,12,1,2 | 7,8,9,10,11,12,1,2 | 1,2,3,4,7,8,9,10,11,12 |
| **timeToGrow** | - | 240 | 240 |
| **Notes** | Too early | Too early | Frost-sensitive |

### Zucchini

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 3,4,5 | 3,4 | 5,6 |
| **bestMonth** | 4 | 4 | 5 |
| **riskMonth** | 5 | 3 | 6 |
| **badMonth** | 8,9,10,11,12,1,2 | 7,8,9,10,11,12,1,2 | 1,2,3,4,7,8,9,10,11,12 |
| **timeToGrow** | - | 240 | 240 |
| **Notes** | Too early | Too early | Same as cucumber |

### Pumpkin

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 3,4,5 | 4,5 | 5,6 |
| **bestMonth** | 4 | 5 | 5 |
| **riskMonth** | 5 | 4 | 6 |
| **badMonth** | 8,9,10,11,12,1,2 | 11,12,1,2,3 | 1,2,3,4,7,8,9,10,11,12 |
| **timeToGrow** | - | 528 | 528 |
| **Notes** | Too early | Good | May for Oct harvest |

### Watermelon

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 3,4,5 | 4,5 | 5,6 |
| **bestMonth** | 4 | 5 | 5 |
| **riskMonth** | 5 | 4 | 6 |
| **badMonth** | 8,9,10,11,12,1,2 | 10,11,12,1,2,3 | 1,2,3,4,7,8,9,10,11,12 |
| **timeToGrow** | - | 432 | 432 |
| **Notes** | Too early | Good | Needs warm soil |

### Soybeans

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 3,4,5 | 4,5 | 5,6,7 |
| **bestMonth** | 4 | 5 | 5,6 |
| **riskMonth** | 5 | 4 | 7 |
| **badMonth** | 8,9,10,11,12,1,2 | 10,11,12,1,2,3 | 1,2,3,4,8,9,10,11,12 |
| **timeToGrow** | - | 384 | 384 |
| **Notes** | Too early | Good | Can succession plant |

---

## Root Crops

### Potatoes

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3 | 2,3 | 3,4 |
| **bestMonth** | 2 | 3 | 3,4 |
| **riskMonth** | 3 | 2 | - |
| **badMonth** | 7,8,9,10,11,12,1 | 8,9,10,11,12,1 | 1,2,5,6,7,8,9,10,11,12 |
| **timeToGrow** | - | 384 | 384 |
| **Notes** | Feb too early | Better | Mar-Apr planting |

### Sweet Potato

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 3,4,5 | 4,5 | 5,6 |
| **bestMonth** | 4 | 5 | 5 |
| **riskMonth** | 5 | 4 | 6 |
| **badMonth** | 8,9,10,11,12,1,2 | 10,11,12,1,2,3 | 1,2,3,4,7,8,9,10,11,12 |
| **timeToGrow** | - | 480 | 480 |
| **Notes** | Too early | Good | Heat-loving |

### Sugar Beets

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | - | 3,4 | 3,4,8 |
| **bestMonth** | - | 4 | 4,8 |
| **riskMonth** | - | 3 | 3 |
| **badMonth** | - | 9,10,11,12,1,2 | 1,2,5,6,7,9,10,11,12 |
| **timeToGrow** | - | 432 | 432 |
| **Notes** | Mod addition | Need fall option | Spring+Fall crop |

### Onion

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4 | 1,2,3 | 3,4,9,10 |
| **bestMonth** | 3 | 3,2 | 3,10 |
| **riskMonth** | 4 | 1 | 4,9 |
| **badMonth** | 10,11,12,1 | 8,9,10,11,12 | 1,2,5,6,7,8,11,12 |
| **timeToGrow** | - | 432 | 432 |
| **Notes** | Spring only | Jan too cold | Spring OR fall |

---

## Fall-Planted Overwintering Crops

### Garlic

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 7,8,9 | 9,10 | 9,10 |
| **bestMonth** | 8 | 10 | 10 |
| **riskMonth** | 9 | 9 | 9 |
| **badMonth** | 6 | 8 | 1,2,3,4,5,6,7,8,11,12 |
| **coldHardy** | - | true | true |
| **timeToGrow** | - | 1008 | 1008 |
| **Notes** | Jul/Aug wrong | PERFECT! | Keep as-is |

---

## Grain Crops

### Wheat

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 8,9,10 | 8,9,10 | 9,10 |
| **bestMonth** | 9 | 9 | 9 |
| **riskMonth** | 10 | 8 | 10 |
| **badMonth** | 6,7 | 4,5,6,7 | 1,2,3,4,5,6,7,8,11,12 |
| **coldHardy** | - | true | true |
| **timeToGrow** | - | 576 | 576 |
| **Notes** | Good | Very good | Remove Aug |

### Rye

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 8,9,10 | 8,9,10 | 9,10 |
| **bestMonth** | 9 | 9 | 9 |
| **riskMonth** | 10 | 8 | 10 |
| **badMonth** | 6,7 | 4,5,6,7 | 1,2,3,4,5,6,7,8,11,12 |
| **coldHardy** | - | - | true |
| **timeToGrow** | - | 576 | 576 |
| **Notes** | Good | Very good | Add coldHardy |

### Barley

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 8,9,10 | 2,3,4,5,6,7,8,9,10 | 3,4,9,10 |
| **bestMonth** | 9 | 3,9 | 3,9 |
| **riskMonth** | 10 | 2,5,6,7,8 | 4,10 |
| **badMonth** | 6,7 | - | 1,2,5,6,7,8,11,12 |
| **coldHardy** | true | - | - |
| **timeToGrow** | 432 | 288 | 288 |
| **Notes** | Fall only | Too broad | Spring OR fall |

---

## Other Crops

### Flax

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 8,9,10 | 3,4 | 3,4 |
| **bestMonth** | 9 | 4 | 4 |
| **riskMonth** | 10 | 3 | 3 |
| **badMonth** | 6,7 | 9,10,11,12,1,2 | 9,10,11,12,1,2 |
| **timeToGrow** | - | 480 | 480 |
| **Notes** | Fall planting? | Spring correct | Spring crop |

### Hemp

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 8,9,10 | 3,4 | 3,4 |
| **bestMonth** | 9 | 4 | 4 |
| **riskMonth** | 10 | 3 | 3 |
| **badMonth** | 6,7 | 9,10,11,12,1,2 | 9,10,11,12,1,2 |
| **timeToGrow** | - | 432 | 432 |
| **Notes** | Fall planting? | Spring correct | Spring crop |

### Hops

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 8,9,10 | 2,3 | 2,3 |
| **bestMonth** | 9 | 3 | 3 |
| **riskMonth** | 10 | 2 | 2 |
| **badMonth** | 6,7 | 9,10,11,12,1 | 9,10,11,12,1 |
| **timeToGrow** | - | 576 | 576 |
| **Notes** | Fall planting? | Early spring | Keep as-is |

### Strawberries

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 2,3,4 | 2,3,4 | 3,4,9 |
| **bestMonth** | 3 | 3 | 3,9 |
| **riskMonth** | - | 2 | 4 |
| **badMonth** | 7,8,9,10,11,12,1 | 7,8,9,10,11,12,1 | 1,2,5,6,7,8,10,11,12 |
| **growBack** | - | 2 | 2 |
| **timeToGrow** | - | 240 | 240 |
| **Notes** | Spring only | Good | Add fall planting |

### Sunflower

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 3,4,5 | 3,4,5 | 5,6 |
| **bestMonth** | 4 | 4 | 5 |
| **riskMonth** | 5 | 3 | 6 |
| **badMonth** | 10,11,12,1,2 | 10,11,12,1,2 | 1,2,3,4,7,8,9,10,11,12 |
| **timeToGrow** | - | 384 | 384 |
| **Notes** | Too early | Too early | Warm season |

### Tobacco

| Setting | Vanilla PZ | Your Mod | Recommended |
|---------|------------|----------|-------------|
| **sowMonth** | 3,4,5,6,7 | 3,4,5 | 5,6 |
| **bestMonth** | 3 | 4 | 5 |
| **riskMonth** | 7 | 3 | 6 |
| **badMonth** | 10,11,12,1,2 | 11,12,1,2 | 1,2,3,4,7,8,9,10,11,12 |
| **timeToGrow** | - | 576 | 576 |
| **Notes** | Mar best wrong | Too early | May-June best |

---

## Summary Statistics

### Crops Where Vanilla PZ is Reasonable:
- Barley (fall grain)
- Garlic (fall planting)
- Wheat (fall grain)
- Rye (fall grain)
- Strawberries (spring)

### Crops Where Your Mod Improved on Vanilla:
- Broccoli (added Aug for fall)
- Cabbage (added Aug for fall)
- Cauliflower (changed from spring to fall focus)
- Kale (added Aug for fall)
- Lettuce (added Aug for fall)
- Garlic (shifted to Sept-Oct)
- Pumpkin (shifted later)
- Watermelon (shifted later)

### Crops Needing Major Louisville KY Adjustments:
- **All warm-season crops** (tomatoes, peppers, corn, cucumbers, squash) - Too early in both vanilla and mod
- **Greenpeas** - Should be spring-only, not spring+fall
- **Cool-season greens** (lettuce, spinach, kale) - Need summer months removed
- **Cauliflower** - Needs spring option restored
- **Corn** - Needs complete season shift (May-June-July instead of Mar-Apr-May)

### Crops That Are Good in Your Mod:
- Garlic (perfect!)
- Wheat (excellent)
- Rye (very good)
- Radishes (good overall)
- Barley (but too broad, needs restriction)

---

## Quick Reference: What to Plant When (Louisville KY)

### March (3): Early Spring
**Plant:** Lettuce, Spinach, Peas, Potatoes, Onions, Strawberries
**Risky:** Carrots, Radishes, Broccoli, Cabbage, Cauliflower, Turnips

### April (4): Spring
**Best:** Broccoli, Cabbage, Cauliflower, Lettuce, Spinach, Carrots, Potatoes, Radishes
**Risky:** Onions, Strawberries, Turnips

### May (5): Late Spring
**Best:** Tomatoes, Peppers, Corn, Soybeans, Pumpkin, Watermelon, Sunflower, Tobacco
**Risky:** Radishes, Carrots

### June (6): Early Summer
**Best:** Soybeans, Corn
**Risky:** Tomatoes, Peppers, Pumpkin, Watermelon, Sunflower, Tobacco

### July (7): Summer
**Risky:** Corn, Soybeans
*Most crops don't plant well in July heat*

### August (8): Late Summer (Fall Garden Starts)
**Best:** Broccoli, Cabbage, Cauliflower, Kale, Lettuce, Carrots, Turnips, Sugar Beets
**Risky:** Radishes, Spinach

### September (9): Fall
**Best:** Kale, Lettuce, Spinach, Garlic, Radishes, Strawberries, Wheat, Rye, Barley
**Risky:** Broccoli, Cabbage, Cauliflower, Carrots, Turnips, Peas, Onions

### October (10): Late Fall
**Best:** Garlic, Wheat, Rye, Barley
**Risky:** Lettuce, Spinach, Radishes

---

## Implementation Notes

### High Priority Changes (Biggest Impact):
1. Shift all warm-season crops 1-2 months later (corn, tomatoes, peppers, cucumbers, squash)
2. Remove summer months from cool-season greens (lettuce, spinach)
3. Add fall option to cauliflower
4. Restrict greenpeas to spring only

### Medium Priority:
5. Fine-tune brassica seasons (broccoli, cabbage, cauliflower, kale)
6. Adjust root crop timing (carrots, turnips)
7. Restrict barley to spring/fall only

### Low Priority:
8. Add fall option to strawberries and onions
9. Adjust specialty crops (tobacco, sunflower)
10. Fine-tune risk months

---

**End of Comparison Table**

**Related Document:** claude_LouisvilleKYPlantingCalendar.md
