# badMonth Conflict Analysis for Kentucky Realistic Farming
# Critical Issues Where Legitimate Plantings Will Fail

**Created:** 2025-01-24
**Analysis Rule:** If sowMonth + timeToGrow extends into badMonth, the plant will DIE from continuous -3 to -6 health loss per hour

---

## Understanding the Problem

Based on game code analysis (`SFarmingSystem.lua:243-244`):
```lua
if seasons and luaObject.exterior and luaObject:isBadMonth() and not luaObject:isBadMonthHardy() then
    luaObject.health = luaObject.health - (3 * badMultiplier)
end
```

**Effects of badMonth:**
- **-3 health per hour** base loss
- **-6 health per hour** if plant is cursed (planted in riskMonth)
- **No health gain from sun** during badMonth
- Plants WILL DIE if still growing during badMonth

**Time conversions:**
- 24 hours = 1 game day
- ~30 days = 1 game month
- ~720 hours = 1 game month

---

## CRITICAL CONFLICTS - Fall Plantings

### Greenpeas ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {3, 4, 8, 9}
badMonth = {1, 2, 5, 6, 7, 10, 11, 12}
timeToGrow = 288 hours (12 days)
```

**Problem:**
- Plant September (9) → Harvest early October (10)
- **October is badMonth** → Plant dies before harvest
- Almanac.com says August planting is valid!

**Fix:** Remove October from badMonth, or use riskMonth instead
```lua
badMonth = {1, 2, 5, 6, 7, 11, 12}
riskMonth = {10}  // Add October as risky
```

---

### Broccoli ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {3, 4, 5, 7, 8, 9}
badMonth = {1, 2, 6, 10, 11, 12}
timeToGrow = 432 hours (18 days)
```

**Problem:**
- Plant September (9) → Harvest mid-October (10)
- **October is badMonth** → Plant dies before harvest
- September is intended fall planting month

**Fix:** Remove October from badMonth
```lua
badMonth = {1, 2, 6, 11, 12}
riskMonth = {5, 7, 9, 10}  // Add October as risky
```

---

### Cabbage ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {3, 4, 7, 8, 9}
badMonth = {1, 5, 6, 10, 11, 12}
timeToGrow = 432 hours (18 days)
```

**Problem:**
- Plant September (9) → Harvest mid-October (10)
- **October is badMonth** → Plant dies before harvest

**Fix:** Remove October from badMonth
```lua
badMonth = {1, 5, 6, 11, 12}
riskMonth = {2, 4, 7, 9, 10}  // Add October as risky
```

---

### Cauliflower ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {3, 4, 7, 8}
badMonth = {1, 2, 5, 6, 9, 10, 11, 12}
timeToGrow = 432 hours (18 days)
```

**Problem:**
- Plant August (8) → Harvest mid-September (9)
- **September is badMonth** → Plant dies before harvest

**Fix:** Remove September from badMonth
```lua
badMonth = {1, 2, 5, 6, 10, 11, 12}
riskMonth = {7, 9}  // Add September as risky
```

---

### Carrots ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {2, 3, 4, 7, 8, 9}
badMonth = {1, 5, 6, 10, 11, 12}
timeToGrow = 360 hours (15 days)
```

**Problem:**
- Plant September (9) → Harvest mid-October (10)
- **October is badMonth** → Plant dies before harvest

**Fix:** Remove October from badMonth
```lua
badMonth = {1, 5, 6, 11, 12}
riskMonth = {2, 4, 9, 10}  // Add October as risky
```

---

### Kale ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {3, 4, 8, 9}
badMonth = {1, 2, 5, 6, 7, 10, 11, 12}
timeToGrow = 336 hours (14 days)
```

**Problem:**
- Plant September (9) → Harvest mid-October (10)
- **October is badMonth** → Plant dies before harvest

**Fix:** Remove October from badMonth (kale is cold-hardy!)
```lua
badMonth = {1, 2, 5, 6, 7, 11, 12}
riskMonth = {10}  // October risky but survivable
```

---

### Lettuce ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {3, 4, 8, 9}
badMonth = {1, 2, 5, 6, 7, 10, 11, 12}
timeToGrow = 288 hours (12 days)
```

**Problem:**
- Plant September (9) → Harvest early October (10)
- **October is badMonth** → Plant dies before harvest

**Fix:** Remove October from badMonth
```lua
badMonth = {1, 2, 5, 6, 7, 11, 12}
riskMonth = {8, 10}  // October risky but survivable
```

---

### Spinach ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {3, 4, 8, 9, 10}
badMonth = {1, 2, 5, 6, 7, 11, 12}
timeToGrow = 192 hours (8 days)
```

**Problem:**
- Plant October (10) → Harvest early November (11)
- **November is badMonth** → Plant dies before harvest

**Fix:** Remove November from badMonth (spinach is very cold-tolerant)
```lua
badMonth = {1, 2, 5, 6, 7, 12}
riskMonth = {8, 11}  // November risky but spinach can handle it
```

---

### Sugar Beets ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {3, 4, 8, 9}
badMonth = {1, 2, 5, 6, 7, 10, 11, 12}
timeToGrow = 432 hours (18 days)
```

**Problem:**
- Plant September (9) → Harvest mid-October (10)
- **October is badMonth** → Plant dies before harvest

**Fix:** Remove October from badMonth
```lua
badMonth = {1, 2, 5, 6, 7, 11, 12}
riskMonth = {10}  // October risky
```

---

### Turnips ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {3, 4, 5, 6, 7, 8, 9, 10}
badMonth = {1, 2, 11, 12}
timeToGrow = 264 hours (11 days)
```

**Problem:**
- Plant October (10) → Harvest early November (11)
- **November is badMonth** → Plant dies before harvest

**Fix:** Remove November from badMonth
```lua
badMonth = {1, 2, 12}
riskMonth = {10, 11}  // Both months risky but survivable
```

---

### Radishes ✅ **OK**
**Config:**
```lua
sowMonth = {3, 4, 5, 6, 7, 8, 9, 10}
badMonth = {1, 2, 11, 12}
timeToGrow = 120 hours (5 days)
```

**Status:** FAST enough that October planting harvests within October
- Plant October 1 → Harvest October 6
- No conflict

---

## CRITICAL CONFLICTS - Spring/Summer Transitions

### Corn ⚠️ **POTENTIAL ISSUE**
**Config:**
```lua
sowMonth = {3, 4, 5}
badMonth = {1, 2, 6, 7, 8, 9, 10, 11, 12}
timeToGrow = 432 hours (18 days)
```

**Problem:**
- Plant May (5) → Harvest mid-June (6)
- **June is badMonth** → Plant dies before harvest
- Research shows June-July are valid planting months for succession!

**Fix:** Remove June, July from badMonth (they're warm summer months!)
```lua
badMonth = {1, 2, 8, 9, 10, 11, 12}
riskMonth = {3}  // Keep March risky (early/cold)
```

---

### Cucumber ⚠️ **MAJOR ISSUE**
**Config:**
```lua
sowMonth = {3, 4, 5}
badMonth = {6, 7, 8, 9, 10, 11, 12, 1, 2}
timeToGrow = 240 hours (10 days)
```

**Problem:**
- Plant May (5) → Harvest early June (6)
- **June is badMonth** → Plant dies
- June-July are PRIME cucumber months!

**Fix:** Remove June, July from badMonth
```lua
badMonth = {1, 2, 8, 9, 10, 11, 12}
riskMonth = {3}  // March risky (frost)
```

---

### Pumpkin ⚠️ **CRITICAL ISSUE**
**Config:**
```lua
sowMonth = {4, 5, 6, 7}
badMonth = {1, 2, 3, 8, 9, 10, 11, 12}
timeToGrow = 528 hours (22 days)
```

**Problem:**
- Plant July (7) → Harvest late August (8)
- **August is badMonth** → Plant dies
- Plant June (6) → Harvest late July (7) - OK
- Plant May (5) → Harvest late June (6) - OK
- But October harvest is GOAL for pumpkins!

**Fix:** Pumpkins need to grow through summer for October harvest
```lua
badMonth = {1, 2, 3, 11, 12}
riskMonth = {4}  // April early/risky
// Allow May-October growing (pumpkins need long season for October harvest)
```

---

### Strawberry ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {2, 3, 4}
badMonth = {5, 6, 7, 8, 9, 10, 11, 12, 1}
timeToGrow = 240 hours (10 days)
```

**Problem:**
- Plant April (4) → Harvest mid-May (5)
- **May is badMonth** → Plant dies
- Strawberries are perennials that grow through summer!

**Fix:** Strawberries are perennials with growBack=2, they need summer
```lua
badMonth = {1, 11, 12}
riskMonth = {2}  // February risky/cold
// Allow growing through spring/summer/fall
```

---

### Sunflower ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {3, 4, 5, 6, 7}
badMonth = {1, 2, 8, 9, 10, 11, 12}
timeToGrow = 384 hours (16 days)
```

**Problem:**
- Plant July (7) → Harvest mid-August (8)
- **August is badMonth** → Plant dies

**Fix:** Sunflowers grow in summer
```lua
badMonth = {1, 2, 9, 10, 11, 12}
riskMonth = {5, 6}  // Keep existing risk months
// Allow May-August growing
```

---

### Tobacco ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {3, 4, 5, 6}
badMonth = {7, 8, 9, 10, 11, 12, 1, 2}
timeToGrow = 576 hours (24 days)
```

**Problem:**
- Plant June (6) → Harvest late July (7)
- **July is badMonth** → Plant dies
- Tobacco is a long-season SUMMER crop!

**Fix:** Tobacco grows through summer
```lua
badMonth = {1, 2, 9, 10, 11, 12}
riskMonth = {3}  // March risky/cold
// Allow April-August growing (long summer crop)
```

---

### Sweet Potato ⚠️ **WILL FAIL**
**Config:**
```lua
sowMonth = {4, 5, 6, 7}
badMonth = {8, 9, 10, 11, 12, 1, 2, 3}
timeToGrow = 480 hours (20 days)
```

**Problem:**
- Plant July (7) → Harvest mid-August (8)
- **August is badMonth** → Plant dies
- Sweet potatoes are LONG season heat-loving crops!

**Fix:** Sweet potatoes need full summer
```lua
badMonth = {1, 2, 3, 10, 11, 12}
riskMonth = {4, 7}  // April and July risky (early/late)
// Allow May-September growing (long heat-loving crop)
```

---

## Overwintering Crops - SPECIAL CASES

### Wheat ✅ **CORRECT**
**Config:**
```lua
sowMonth = {8, 9, 10, 11}
badMonth = {1, 2, 3, 4, 5, 6, 7, 12}
timeToGrow = 576 hours (24 days)
coldHardy = true
```

**Status:** CORRECT
- Winter wheat planted fall, harvests spring
- coldHardy = true protects it through winter
- timeToGrow is just to first maturity, not full harvest
- badMonth correctly prevents spring/summer planting

---

### Rye ⚠️ **MISSING coldHardy**
**Config:**
```lua
sowMonth = {8, 9, 10, 11}
badMonth = {1, 2, 3, 4, 5, 6, 7, 12}
timeToGrow = 576 hours (24 days)
-- coldHardy = true  // COMMENTED OUT!
```

**Problem:** Should have coldHardy like wheat!

**Fix:** Add coldHardy trait
```lua
coldHardy = true
```

---

### Garlic ⚠️ **CONFLICT WITH OWN GROWTH**
**Config:**
```lua
sowMonth = {9, 10}
badMonth = {1, 2, 3, 4, 5, 6, 7, 8, 11, 12}
timeToGrow = 1008 hours (42 days = ~1.4 months)
coldHardy = true
```

**Problem:**
- Plant October (10) → Harvest late November/early December (11/12)
- **November/December are badMonth** → Plant takes damage
- However, coldHardy = true should protect it!

**Question:** Does coldHardy prevent winter damage but not badMonth damage?

**Potential Fix:** Garlic overwinters and harvests in SPRING, not after 1008 hours
- The timeToGrow might be to first maturity, then it survives winter
- badMonth might be correct if coldHardy protects through winter
- **NEEDS TESTING** to understand coldHardy interaction with badMonth

---

## Summary of Required Changes

### Fall Crop badMonth Fixes (October/November need removal):

**Remove October from badMonth:**
- Greenpeas
- Broccoli
- Cabbage
- Carrots
- Kale
- Lettuce
- Sugar Beets

**Remove November from badMonth:**
- Spinach (very cold-tolerant)
- Turnips

**Remove September from badMonth:**
- Cauliflower

---

### Summer Crop badMonth Fixes (June/July/August need removal):

**Remove June/July from badMonth:**
- Corn (summer succession crop)
- Cucumber (prime summer months)

**Remove August from badMonth:**
- Pumpkin (needs full summer for Oct harvest)
- Sunflower (summer crop)
- Sweet Potato (long season heat-lover)

**Remove July/August from badMonth:**
- Tobacco (long summer crop)

---

### Perennial Fixes:

**Remove May-October from badMonth:**
- Strawberry (perennial, grows all season)

---

### Trait Additions:

**Add coldHardy = true:**
- Rye (currently commented out)

---

## Critical Principle for badMonth

**badMonth should ONLY include months when:**
1. The plant CANNOT be growing (temperature/season kills it)
2. The plant would die from weather conditions
3. NOT just "not ideal" months

**For marginal months, use riskMonth instead!**

- **riskMonth** = Can plant, but might fail (curse chance)
- **badMonth** = Plant WILL die if growing during this month

---

## Recommended Testing After Fixes

1. Plant September crops (peas, broccoli, cabbage, etc.)
2. Watch if they survive into October
3. Plant July crops (tomatoes, corn, cucumbers)
4. Watch if they survive into August
5. Check that badMonth still kills spring crops in summer heat (lettuce in June, etc.)

---

**Document Purpose:** Identify critical bugs where badMonth prevents legitimate plantings from succeeding
