# PseudoSaltRecipes Mod - Analysis and Documentation

**Mod Name:** PseudoSaltRecipes
**Module:** Pseudonymous
**Version Analyzed:** Modified version (2025-10-13)
**Created by:** Claude
**Date:** 2025-10-13

---

## Overview

PseudoSaltRecipes is a food preservation mod that adds salt-curing mechanics to Project Zomboid. The mod allows players to preserve meat and fish using salt, significantly extending their shelf life from 7-14 days fresh to 90-180 days.

---

## Key Changes from Original

**Removed Features:**
- ~~Get Salt From Pot recipe~~ (removed - no longer in mod)
- ~~Get Salt From Kettle recipe~~ (removed - no longer in mod)
- ~~SaltwaterPot item~~ (removed - functionality moved to PseudoSaltWellB42 mods)
- ~~SaltwaterKettle item~~ (removed - functionality moved to PseudoSaltWellB42 mods)
- ~~SaltPot item~~ (removed - functionality moved to PseudoSaltWellB42 mods)
- ~~SaltKettle item~~ (removed - functionality moved to PseudoSaltWellB42 mods)

**Current Focus:**
- Salt-curing of meats and fish
- Food preservation mechanics
- Evolved recipe integration

---

## Item Definitions

### Salted Food Items (Fresh - Stage 1)

All salted items start with a 7-day fresh period and will auto-convert to cured versions when they rot.

#### 1. SaltedFishFillet
```
DisplayName: Salted Fish Fillet
Weight: 0.2
DaysFresh: 7
DaysTotallyRotten: 14
HungerChange: -25
Calories: 205
ReplaceOnRotten: Pseudonymous.SaltCuredFishFillet
DangerousUncooked: TRUE
IsCookable: TRUE
MinutesToCook: 20
```

**Key Properties:**
- Must be cooked before eating (dangerous when raw)
- 7-day fresh period during which it acts like normal salted fish
- After 7 days, automatically converts to SaltCuredFishFillet
- Can be used in evolved recipes when cooked

#### 2. SaltedVenison
```
DisplayName: Salted Venison
Weight: 0.51
DaysFresh: 7
DaysTotallyRotten: 14
HungerChange: -80
Calories: 440
ReplaceOnRotten: Pseudonymous.SaltCuredVenison
DangerousUncooked: TRUE
```

#### 3. SaltedBeef
```
DisplayName: Salted Beef
Weight: 0.51
DaysFresh: 7
DaysTotallyRotten: 14
HungerChange: -80
Calories: 440
ReplaceOnRotten: Pseudonymous.SaltCuredBeef
DangerousUncooked: TRUE
FishingLure: true
```

#### 4. SaltedSteak
```
DisplayName: Steak (salted)
Weight: 0.31
DaysFresh: 7
DaysTotallyRotten: 14
HungerChange: -40
Calories: 220
ReplaceOnRotten: Pseudonymous.SaltCuredSteak
DangerousUncooked: TRUE
FishingLure: true
```

#### 5. SaltedRabbitmeat
```
DisplayName: Salted Rabbit Meat
Weight: 0.31
DaysFresh: 7
DaysTotallyRotten: 14
HungerChange: -30
Calories: 969
ReplaceOnRotten: Pseudonymous.SaltCuredRabbitmeat
DangerousUncooked: TRUE
```

---

### Salt-Cured Food Items (Preserved - Stage 2)

These are the long-term preservation versions that automatically replace salted items after rotting.

#### 1. SaltCuredFishFillet
```
DisplayName: Salted Cured Fish Fillet
Weight: 0.16 (20% lighter than salted version)
DaysFresh: 90
DaysTotallyRotten: 180
HungerChange: -25
DangerousUncooked: FALSE (safe to eat raw!)
```

**Key Differences from Salted:**
- 90 days fresh (vs 7 days)
- Safe to eat without cooking
- Lighter weight (moisture loss from curing)
- Cannot be used in evolved recipes that require "|Cooked" flag

#### 2. SaltCuredVenison
```
DisplayName: Salt Cured Venison
Weight: 0.4 (22% lighter)
DaysFresh: 90
DaysTotallyRotten: 180
HungerChange: -80
DangerousUncooked: FALSE
```

#### 3. SaltCuredBeef
```
DisplayName: Salt Cured Beef
Weight: 0.4 (22% lighter)
DaysFresh: 90
DaysTotallyRotten: 180
HungerChange: -80
DangerousUncooked: FALSE
FishingLure: true
```

#### 4. SaltCuredSteak
```
DisplayName: Steak (cured)
Weight: 0.24 (23% lighter)
DaysFresh: 90
DaysTotallyRotten: 180
HungerChange: -40
DangerousUncooked: FALSE
FishingLure: true
```

#### 5. SaltCuredRabbitmeat
```
DisplayName: Salt Cured Rabbit Meat
Weight: 0.24 (23% lighter)
DaysFresh: 90
DaysTotallyRotten: 180
HungerChange: -30
DangerousUncooked: FALSE
```

---

### Special Items: Brined Pork in Clay Jars

These items use the PseudoClay mod's fired jars for brining pork.

#### BrinedPorkCrock
```
DisplayName: Stoneware Jar of Brined Pork
Weight: 1.0
DaysFresh: 7
DaysTotallyRotten: 14
HungerChange: -18
ThirstChange: 4 (salty liquid)
DangerousUncooked: TRUE
ReplaceOnRotten: Pseudonymous.BrinedSaltPorkCrock
ReplaceOnUse: ClayJar_Fired (returns empty jar)
Icon: ClayJar_Fired
```

#### BrinedSaltPorkCrock
```
DisplayName: Stoneware Jar of Brined Salt Pork
Weight: 1.0
DaysFresh: 180 (6 months!)
DaysTotallyRotten: 360 (1 year!)
HungerChange: -18
ThirstChange: 4
DangerousUncooked: TRUE
ReplaceOnUse: ClayJar_Fired
```

**Special Properties:**
- Uses clay jar from PseudoClay mod
- Extremely long preservation (up to 1 year)
- Still dangerous when uncooked (must cook before eating)
- Returns empty clay jar when consumed

---

## Recipes

### 1. Make Salted Fillet
```
Inputs:
  - 1x Sharp Knife or Meat Cleaver (kept)
  - 1x Base.FishFillet
  - 2x Base.Salt

Output:
  - 1x Pseudonymous.SaltedFishFillet

Time: 150
Tags: AnySurfaceCraft;Cooking
Category: Cooking
XP Award: Cooking:5
OnCreate: Recipe.OnCreate.CutFillet
```

**Mechanics:**
- Requires sharp knife (checks for dullness)
- Uses 2 salt per fillet
- Inherits food age from original fillet
- Uses SliceMeat_Surface timed action (cutting board animation)
- Grants cooking XP

### 2. Salt Meat ChickenStyle
```
Inputs:
  - 1x Sharp Knife or Meat Cleaver (kept)
  - 2x Base.Salt
  - 1x Base.Rabbitmeat OR Base.Beef OR Base.Steak

Output (mapped):
  - Base.Rabbitmeat → Pseudonymous.SaltedRabbitmeat
  - Base.Beef → Pseudonymous.SaltedBeef
  - Base.Steak → Pseudonymous.SaltedSteak

Time: 150
Tags: AnySurfaceCraft;Cooking
Category: Cooking
XP Award: Cooking:5
OnCreate: Recipe.OnCreate.CutChicken
```

**Item Mapper:**
- Automatically determines output based on input meat type
- Single recipe handles multiple meat types
- Inherits food age from input meat

### 3. Salt Meat AnimalStyle
```
Inputs:
  - 1x Sharp Knife or Meat Cleaver (kept)
  - 2x Base.Salt
  - 1x Base.Rabbitmeat

Output:
  - 1x Pseudonymous.SaltedRabbitmeat

Time: 150
Tags: AnySurfaceCraft;Cooking
Category: Cooking
XP Award: Cooking:5
OnCreate: Recipe.OnCreate.CutAnimal
```

**Notes:**
- This appears to be a duplicate/alternate recipe for rabbit meat
- Uses different OnCreate callback (CutAnimal vs CutChicken)
- Functionally identical to ChickenStyle for rabbit

---

## Preservation Mechanics

### Two-Stage Curing System

**Stage 1: Fresh Salted (Days 0-7)**
- Food is salted but still relatively fresh
- Must be cooked before eating (DangerousUncooked: TRUE)
- Can be used in evolved recipes when cooked
- Normal gameplay mechanics apply

**Stage 2: Salt-Cured (Days 7+)**
- Automatically converts when stage 1 rots
- Safe to eat raw (DangerousUncooked: FALSE)
- 90-day fresh period
- 20-23% lighter weight (moisture loss)
- Cannot be used in some evolved recipes that require cooked meat

### Preservation Duration

| Food Type | Fresh | Salted Fresh | Salt-Cured Fresh | Total Preserved |
|-----------|-------|--------------|------------------|-----------------|
| Fish      | 2-3 days | 7 days | 90 days | 97 days |
| Rabbit    | 2-3 days | 7 days | 90 days | 97 days |
| Beef/Venison | 3-4 days | 7 days | 90 days | 97 days |
| Steak     | 3-4 days | 7 days | 90 days | 97 days |
| Brined Pork | N/A | 7 days | 180 days | 187 days |

### Weight Loss During Curing

All meats lose approximately 20-23% weight when converting from salted to cured:

- Fish: 0.2 → 0.16 (20%)
- Venison: 0.51 → 0.4 (22%)
- Beef: 0.51 → 0.4 (22%)
- Steak: 0.31 → 0.24 (23%)
- Rabbit: 0.31 → 0.24 (23%)

This represents realistic moisture loss during the curing process.

---

## Evolved Recipe Integration

### Salted Items (Can Use When Cooked)
```
EvolvedRecipe = Pizza:15;Soup:15;Stew:15;...|Cooked
```
The `|Cooked` flag means salted items can only be added to evolved recipes after cooking.

### Salt-Cured Items (Can Use Any Time)
```
EvolvedRecipe = Pizza:15;Soup:15;Stew:15;...
```
No cooking requirement - can be added directly to recipes since they're safe to eat raw.

**Evolved Recipes That Accept Salt-Cured Meats:**
- Pizza (15-20 units)
- Soup (15 units)
- Stew (15-20 units)
- Pie (15 units)
- Stir fry (15-20 units)
- Sandwich (5 units)
- Burger (10 units)
- Salad (10 units)
- Rice (15-20 units)
- Pasta (15-20 units)
- Taco (5-10 units)
- Burrito (10-15 units)

---

## Salt Consumption Analysis

### Per-Item Salt Cost

| Recipe | Salt Required | Output |
|--------|--------------|---------|
| Make Salted Fillet | 2 | 1 fillet |
| Salt Meat (any) | 2 | 1 meat piece |

### Salt Efficiency

**For 1 stack of salt (typically 10 units):**
- Can preserve 5 pieces of meat/fish
- Each preserved item lasts 97+ days
- Total food preservation: ~485 days worth

**Comparison to vanilla:**
- Vanilla meat: 2-4 days fresh
- Salted meat: 97+ days preserved
- **Preservation multiplier: ~24-48x**

---

## Gameplay Balance

### Advantages
1. **Long-term food storage** - 90-180 day preservation
2. **Safe to eat raw** - Salt-cured items don't require cooking
3. **Lightweight** - Cured items are 20-23% lighter
4. **Fishing lures** - Beef and steak can be used as bait
5. **Evolved recipes** - Integrates with vanilla cooking system

### Disadvantages
1. **Salt cost** - Requires 2 salt per item (significant resource investment)
2. **Two-stage process** - Must wait 7 days for full curing
3. **Dangerous when fresh** - Salted items still require cooking for first 7 days
4. **Knife required** - Must have sharp knife or cleaver
5. **Evolved recipe limitations** - Some recipes won't accept cured meat

### Risk-Reward Balance

**Low Risk:**
- No skill requirements
- No failure chance
- Guaranteed preservation

**Medium Cost:**
- 2 salt per item (must find or produce salt)
- Sharp knife required (durability cost)
- 150 time units per craft (2.5 minutes)

**High Reward:**
- 24-48x shelf life increase
- Safe raw consumption after curing
- Weight reduction for easier carrying

---

## Integration with Other Mods

### PseudoSaltWellB42 Series
- Provides saltwater wells for sustainable salt production
- Independent salt extraction system
- Complements but doesn't require PseudoSaltRecipes

### PseudoClay
- Required for BrinedPorkCrock items
- Provides ClayJar_Fired containers
- Adds ceramic jar crafting system

---

## Technical Implementation Notes

### Item Definitions Location
- `42/media/scripts/items/PseudoSaltItems.txt`
- `common/media/scripts/items/PseudoSaltItems.txt`

### Recipe Definitions Location
- `42/media/scripts/recipes/PseudoSaltRecipes.txt`
- `common/media/scripts/recipes/PseudoSaltRecipes.txt`

### Module Name
- `Pseudonymous` (all items prefixed with `Pseudonymous.`)

### ReplaceOnRotten Mechanic
Uses vanilla PZ mechanic to auto-convert items:
```
ReplaceOnRotten = Pseudonymous.SaltCuredFishFillet
```
When DaysFresh expires, item automatically becomes the specified replacement.

### Recipe Mappers
Uses itemMapper to handle multiple input types:
```lua
itemMapper meatType {
    Pseudonymous.SaltedRabbitmeat = Base.Rabbitmeat,
    Pseudonymous.SaltedBeef = Base.Beef,
    Pseudonymous.SaltedSteak = Base.Steak,
}
```

---

## Changes from Original Mod

**Removed Salt Extraction:**
The original mod likely included saltwater container items and salt extraction recipes. These have been removed, likely because:

1. **Moved to dedicated mod** - Salt well functionality split into PseudoSaltWellB42 series
2. **Separation of concerns** - Salt production vs salt usage
3. **Optional dependency** - Players can use this mod with any salt source

**Missing from Current Version:**
- SaltwaterPot / SaltwaterKettle items
- SaltPot / SaltKettle items
- "Get Salt From Pot" recipe
- "Get Salt From Kettle" recipe

These features now exist in PseudoSaltWellB42_Part5/Part6 mods.

---

## Recommended Usage

### Early Game
- Focus on small game (rabbit, fish)
- Use 2 salt sparingly on high-value catches
- Build up salt reserves before mass preservation

### Mid Game
- Start preserving large game (venison, beef)
- Create stockpile of salt-cured meats for winter
- Use evolved recipes to create variety

### Late Game
- Maintain rotating stock of preserved meats
- Use brined pork jars for ultra-long storage
- Combine with farming for complete food security

---

## Version History

- **Current Version** (2025-10-13): Modified version without saltwater container items
- **Original Version**: Included complete saltwater-to-salt production chain

---

## Recommended Changes and Improvements

### Quality of Life Improvements

#### 1. Add More Meat Types
**Current Limitation:** Only 5 meat types supported (fish, rabbit, beef, venison, steak)

**Missing Meat Types:**
- Chicken (Base.Chicken)
- Mutton (Base.MuttonChop)
- Pork Chop (Base.PorkChop)
- Bird Meat (Base.BirdMeat, Base.WildEggs)
- Small Bird (Base.SmallBirdMeat)
- Small Animal Meat (Base.SmallAnimalMeat)

**Recommendation:**
Add these to the "Salt Meat ChickenStyle" itemMapper:
```
itemMapper meatType {
    Pseudonymous.SaltedRabbitmeat = Base.Rabbitmeat,
    Pseudonymous.SaltedBeef = Base.Beef,
    Pseudonymous.SaltedSteak = Base.Steak,
    Pseudonymous.SaltedChicken = Base.Chicken,
    Pseudonymous.SaltedMutton = Base.MuttonChop,
    Pseudonymous.SaltedPork = Base.PorkChop,
}
```

**Benefits:**
- Complete coverage of vanilla meat types
- More variety in preserved foods
- Better compatibility with farming/hunting gameplay

---

#### 2. Reduce Salt Cost for Small Items
**Current Issue:** 2 salt per item regardless of size

**Problem:**
- Small fish fillet (0.2 weight) costs same as large beef (0.51 weight)
- Inefficient for preserving small catches
- Discourages preservation of abundant small game

**Recommendation:**
Create tiered salt costs:
- Small items (fish, small birds): 1 salt
- Medium items (rabbit, chicken, steak): 2 salt
- Large items (beef, venison, mutton): 3 salt

**Example Recipe:**
```
craftRecipe Make Salted Small Fillet {
    inputs {
        item 1 tags[SharpKnife;MeatCleaver] mode:keep,
        item 1 [Base.FishFillet],
        item 1 [Base.Salt],  // Reduced from 2
    }
    outputs {
        item 1 Pseudonymous.SaltedFishFillet,
    }
}
```

**Benefits:**
- More realistic salt-to-meat ratio
- Encourages preservation of small catches
- Better resource management for players

---

#### 3. Add Skill-Based Bonuses
**Current Limitation:** No skill progression or bonuses

**Missing Opportunities:**
- Cooking skill doesn't affect salt usage
- No chance for bonus preservation time
- No quality improvements at higher levels

**Recommendations:**

**A. Salt Efficiency (Cooking Skill 3+)**
- Cooking 3-4: 10% chance to save 1 salt
- Cooking 5-6: 20% chance to save 1 salt
- Cooking 7+: 30% chance to save 1 salt

**B. Extended Preservation (Cooking Skill 5+)**
- Cooking 5-7: +10 days to cured shelf life (90→100 days)
- Cooking 8-9: +20 days to cured shelf life (90→110 days)
- Cooking 10: +30 days to cured shelf life (90→120 days)

**C. Faster Processing (Cooking Skill 4+)**
- Cooking 4-6: Time reduced by 20% (150→120)
- Cooking 7-9: Time reduced by 30% (150→105)
- Cooking 10: Time reduced by 40% (150→90)

**Implementation:**
Would require Lua scripting in addition to recipe changes. Could use OnCreate callbacks to check skill levels and apply bonuses.

**Benefits:**
- Rewards skill investment
- Provides progression incentive
- Makes high-level cooking more valuable

---

#### 4. Add Venison Recipe Support
**Current Issue:** Venison can only be salted via ChickenStyle/AnimalStyle recipes

**Problem:**
- No dedicated venison salting recipe
- Venison is a major game meat but treated generically
- Missing from some recipe variations

**Recommendation:**
Add venison to all applicable recipes or create dedicated venison recipe:
```
craftRecipe Salt Venison {
    inputs {
        item 1 tags[SharpKnife;MeatCleaver] mode:keep,
        item 2 [Base.Salt],
        item 1 [Base.Deer],
    }
    outputs {
        item 1 Pseudonymous.SaltedVenison,
    }
    Time = 200,  // Larger cut takes longer
}
```

**Benefits:**
- Better support for hunting gameplay
- Clearer recipe organization
- Proper handling of large game

---

### Balance Improvements

#### 5. Adjust Cured Meat Nutrition
**Current Issue:** Salt-cured items have same nutrition as fresh salted

**Problem:**
- No nutrition penalty for 90-day preservation
- Unrealistic - preserved meats lose nutrients over time
- No tradeoff for extreme convenience

**Recommendations:**

**A. Reduce Caloric Value**
- Fresh salted: 100% calories
- Salt-cured: 85-90% calories
- Example: SaltCuredBeef 440→385 calories

**B. Add Vitamin Deficiency**
- Salt-cured meats provide less vitamins/minerals
- Could cause negative moodlets if eaten exclusively
- Encourages dietary variety

**C. Increase Thirst Penalty**
- Cured meats are saltier
- Add ThirstChange: +5 to +10
- Requires more water when consuming

**Benefits:**
- More realistic preservation mechanics
- Creates interesting gameplay tradeoffs
- Encourages balanced diet planning

---

#### 6. Shorten First Curing Stage
**Current Issue:** 7-day wait before safe raw consumption

**Problem:**
- Very long wait for salt-curing to complete
- Dangerous period is unnecessarily extended
- Historical salt-curing is faster for small cuts

**Recommendation:**
Reduce Stage 1 duration based on item size:
- Small items (fish): 3 days
- Medium items (rabbit, chicken): 5 days
- Large items (beef, venison): 7 days

**Implementation:**
```
item SaltedFishFillet {
    DaysFresh = 3,  // Reduced from 7
    DaysTotallyRotten = 6,  // Reduced from 14
    ReplaceOnRotten = Pseudonymous.SaltCuredFishFillet,
}
```

**Benefits:**
- Faster access to safe preserved food
- More realistic small-item curing times
- Better early-game viability

---

### New Features

> **Note on Smoking Preservation:** Smoking as an alternative preservation method has been deliberately excluded from these recommendations. Smoking would require fundamentally different mechanics (heat sources, extended time-based processing, equipment infrastructure) that fall outside the focused scope of **salt-based preservation**. If smoking mechanics are desired, they should be implemented as a separate, standalone mod that could work alongside PseudoSaltRecipes rather than being integrated into it. This maintains the mod's clear identity and purpose.

#### 7. Add Jerky/Biltong Items
**Missing Product:** No dried meat strips

**Proposal:**
Add jerky-making recipes:
- Requires salt + time + heat source
- Creates lightweight portable snacks
- Better weight efficiency than full cuts
- Ideal for long expeditions

**Example Recipe:**
```
craftRecipe Make Beef Jerky {
    inputs {
        item 1 tags[SharpKnife],
        item 1 [Base.Beef],
        item 1 [Base.Salt],
        requires heat source nearby,
    }
    outputs {
        item 3 Pseudonymous.BeefJerky,  // 3 strips from 1 beef
    }
    Time = 600,  // 10 minutes drying time
}

item BeefJerky {
    Weight = 0.05,  // Very light
    DaysFresh = 120,
    HungerChange = -15,
    Packaged = TRUE,
}
```

**Benefits:**
- Lightweight travel food option
- Better weight-to-hunger ratio
- Historical accuracy
- Encourages exploration gameplay

---

#### 8. Create Salt Rub Item
**Efficiency Improvement:** Pre-mix salt with spices

**Proposal:**
Add craftable salt rub that's more efficient:
- Combines 2 salt + 1 herbs = 3 salt rubs
- Salt rub preserves just as well as 2 salt
- Encourages foraging for herbs
- Adds flavor/happiness bonus

**Example:**
```
craftRecipe Make Salt Rub {
    inputs {
        item 2 [Base.Salt],
        item 1 tags[Herb;Spice],
    }
    outputs {
        item 3 Pseudonymous.SaltRub,
    }
}

// Use salt rub in preservation recipes
craftRecipe Salt Meat with Rub {
    inputs {
        item 1 [Pseudonymous.SaltRub],  // Instead of 2 salt
        item 1 [Base.Beef],
    }
    outputs {
        item 1 Pseudonymous.SaltedBeef,
        UnhappyChange = -2,  // Tastes better
    }
}
```

**Benefits:**
- Resource efficiency through foraging
- Encourages herb collection
- Adds depth to preservation system
- Mood bonus for better-tasting food

---

#### 9. Add Brining Recipes for More Meats
**Current Limitation:** Only pork can be brined in jars

**Proposal:**
Extend jar brining to other meats:
- BrinedBeefCrock
- BrinedChickenCrock
- BrinedFishCrock
- BrinedVenisonCrock

**Requirements:**
- Clay jar (PseudoClay mod)
- Meat
- Salt
- Water

**Benefits:**
- Better use of clay jar system
- Ultimate long-term preservation option
- Variety in preserved foods
- Integration with water collection

---

### Technical Improvements

#### 10. Remove Duplicate Recipe
**Issue:** "Salt Meat AnimalStyle" duplicates ChickenStyle for rabbit

**Problem:**
- Recipe #3 only handles rabbit meat
- Recipe #2 already handles rabbit meat
- No functional difference
- Clutters recipe list

**Recommendation:**
Remove "Salt Meat AnimalStyle" entirely or repurpose it for:
- Alternative preservation method (dry rub vs wet cure)
- Skill-gated version with bonuses
- Different output (jerky instead of salted meat)

**Benefits:**
- Cleaner code
- Less confusion for players
- Opens slot for new recipe

---

#### 11. Add Recipe Unlock Progression
**Missing Feature:** All recipes available from start

**Proposal:**
Gate recipes behind conditions:
- Basic salting (fish, rabbit): No requirements
- Advanced salting (beef, venison): Cooking 3
- Brining recipes: Cooking 5
- Jerky recipes: Cooking 7

**Implementation:**
Could use recipe skill requirements or knowledge system (if available in Build 42).

**Benefits:**
- Provides progression goals
- Makes skill leveling meaningful
- Natural tutorial progression
- Rewards cooking investment

---

#### 12. Add Visual/Texture Differences
**Current Limitation:** Salted and cured items may look identical

**Proposal:**
- Create custom icons for salt-cured items
- Darker, drier appearance
- Visual distinction from fresh salted
- Maybe show salt crystals on texture

**Benefits:**
- Easier inventory management
- Clear visual feedback
- More polished mod presentation
- Better UX

---

### Documentation Improvements

#### 13. Add In-Game Information
**Missing Feature:** No tooltips or descriptions

**Proposal:**
Add detailed item descriptions:
```
item SaltedFishFillet {
    DisplayName = Salted Fish Fillet,
    Description = "Fish fillet preserved with salt. Must be cooked before eating. Will become salt-cured after 7 days.",
}

item SaltCuredFishFillet {
    DisplayName = Salted Cured Fish Fillet,
    Description = "Salt-cured fish that's safe to eat raw. Will last 90 days when fresh.",
}
```

**Benefits:**
- Players understand mechanics without wiki
- Clear expectations for preservation duration
- Better new player experience

---

### Compatibility Improvements

#### 14. Add Integration with Other Food Mods
**Potential Conflicts:** Other mods may add meats/preservation

**Recommendations:**

**A. Support Hydrocraft meats** (if present)
**B. Support expanded hunting mods**
**C. Support fish mods** (more fish types)
**D. Check for conflicting preservation systems**

**Implementation:**
Use conditional recipe loading or item mappers that check for mod presence.

**Benefits:**
- Better mod ecosystem integration
- Fewer compatibility issues
- Broader appeal

---

## Priority Ranking

### High Priority (Immediate Value)
1. **Add more meat types** - Quick win, big impact
2. **Remove duplicate recipe** - Easy cleanup
3. **Add recipe for missing venison** - Fills obvious gap
4. **Reduce salt cost for small items** - Better balance

### Medium Priority (Significant Improvement)
5. **Shorten first curing stage** - Better pacing
6. **Adjust cured meat nutrition** - More realistic
7. **Add skill-based bonuses** - Progression depth
8. **Create salt rub item** - Interesting mechanic

### Low Priority (Nice to Have)
9. **Add jerky items** - Significant new content (stays within salt-preservation scope)
10. **Expand brining recipes** - Content expansion
11. **Add visual differences** - Polish

### Optional (Enhancement)
12. **Recipe unlock progression** - If skill system supports it
13. **Better documentation** - Always good
14. **Mod compatibility** - As needed

---

**End of Analysis**
