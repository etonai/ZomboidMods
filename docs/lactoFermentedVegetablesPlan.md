# Lacto-Fermented Vegetables Plan for PseudoSaltRecipes Mod

**Created:** 2025-10-30
**Last Updated:** 2025-10-30 (Fixed ReplaceOnUse - must use Base. module prefix for jars to return correctly)
**Mod:** PseudoSaltRecipes
**Status:** Planning Phase

## Overview

This document outlines the plan for expanding the PseudoSaltRecipes mod to include a comprehensive system of lacto-fermented vegetables. The initial implementation includes sauerkraut (fermented cabbage) with three jar type variants. This plan describes how to systematically add other vegetables with historical precedence for lacto-fermentation.

## Completed Implementations

### Sauerkraut (Cabbage)
- **Status:** ✅ Complete
- **Display Name:** "Sauerkraut" (traditional name, exception to "Fermented [Vegetable]" pattern)
- **Items Created:** 6 total
  - LactoFermentedCabbage (glass jar)
  - JarOfCabbageStew (cooked, glass jar)
  - LactoFermentedCabbageClayJar
  - ClayJarOfCabbageStew (cooked, clay jar)
  - LactoFermentedCabbageGlazedJar
  - GlazedJarOfCabbageStew (cooked, glazed jar)
- **Recipes Created:** 3 (one per jar type)
- **Properties:**
  - Fermentation time: 200 game units
  - Shelf life: 120 days fresh / 240 days totally rotten (vs 2/4 for fresh cabbage)
  - Total lifespan: 240 days (8 months)
  - ThirstChange: +5 (realistic for salty fermented food)
  - Requires: 1 Cabbage, 3 Salt, 1 liter Water, 1 Jar, 1 Knife

## Immediate Next Step

### Lacto-Fermented Cucumbers
- **Priority:** High ✅ **COMPLETE**
- **Historical Precedence:** Extremely common worldwide, especially Eastern European and American traditions
- **Game Item:** Base.Cucumber
- **Recipe Requirements:** 3 cucumbers per jar (hunger-based scaling)
- **Display Names:** "Fermented Cucumbers" (not "Pickles" - avoiding confusion with vinegar pickles)
- **Implementation:**
  - ✅ 6 items created (3 jar types × 2 variations: raw fermented + cooked)
  - ✅ 3 recipes created (one per jar type)
- **Naming Convention:**
  - LactoFermentedCucumber → "Jar of Fermented Cucumbers"
  - JarOfPickledCucumberStew → "Jar of Fermented Cucumber Stew"
  - LactoFermentedCucumberClayJar → "Clay Jar of Fermented Cucumbers"
  - (+ 3 more jar variants)
- **Nutrition:**
  - Base cucumber: -10 hunger each
  - 3 cucumbers = -30 hunger input → jar output -30 hunger
  - ThirstChange: +5 (due to brine)
  - Shelf life: 120/240 days (8 months total)
  - Nutrition: 18.3 carbs, 7.11 proteins, 1.89 lipids, 99 calories

### Lacto-Fermented Carrots
- **Priority:** Medium ✅ **COMPLETE**
- **Historical Precedence:** Common in Korean, Middle Eastern, and European fermentation traditions
- **Game Item:** Base.Carrots
- **Recipe Requirements:** 3 carrots per jar (hunger-based scaling)
- **Display Names:** "Fermented Carrots"
- **Implementation:**
  - ✅ 6 items created (3 jar types × 2 variations: raw fermented + cooked)
  - ✅ 3 recipes created (one per jar type)
- **Naming Convention:**
  - LactoFermentedCarrot → "Jar of Fermented Carrots"
  - JarOfCarrotStew → "Jar of Fermented Carrot Stew"
  - LactoFermentedCarrotClayJar → "Clay Jar of Fermented Carrots"
  - (+ 3 more jar variants)
- **Nutrition:**
  - Base carrot: -8 hunger each
  - 3 carrots = -24 hunger input → jar output -24 hunger
  - ThirstChange: +5 (due to brine)
  - Shelf life: 120/240 days (8 months total)
  - Nutrition: 18.0 carbs, 1.8 proteins, 0.45 lipids, 75 calories

## Project Zomboid Vegetables Analysis

### Vegetables Available in Game

| Vegetable | Item Name | Historical Fermentation | Priority | Notes |
|-----------|-----------|------------------------|----------|-------|
| Cabbage | Base.Cabbage | ✅ Strong (Sauerkraut, Kimchi) | ✅ Done | Universal fermentation tradition |
| Cucumber | Base.Cucumber | ✅ Strong (Pickles, Dill pickles) | ✅ Done | Fermented cucumbers, 3 per jar |
| Carrots | Base.Carrots | ✅ Strong (Korean, Middle Eastern) | ✅ Done | Commonly fermented, 3 per jar |
| Radish | Base.RedRadish | ✅ Strong (Kimchi, Korean pickles) | 🟡 Medium | Key ingredient in authentic kimchi |
| Turnip | Base.Turnip | ✅ Moderate (Japanese, European) | 🟡 Medium | Traditional in many cultures |
| Beets | Base.SugarBeet | ✅ Moderate (Beet kvass, pickled) | 🟢 Low | More common as kvass (drink) than solid |
| Bell Pepper | Base.BellPepper | ✅ Moderate (Mixed pickles) | 🟢 Low | Usually fermented with other vegetables |
| Tomato | Base.Tomato | ❌ Rare (Too acidic for lacto) | ❌ Skip | Better suited for canning/sauce |
| Potato | Base.Potato | ❌ No (Starch, not suitable) | ❌ Skip | Not traditionally fermented |
| Broccoli | Base.Broccoli | ⚠️ Minimal (Modern trend only) | ❌ Skip | No strong historical precedence |
| Leek | Base.Leek | ⚠️ Minimal (Rare) | ❌ Skip | Onions more common |
| Lettuce | Base.Lettuce | ❌ No (Too delicate) | ❌ Skip | Would become mushy |
| Brussels Sprouts | Base.BrusselSprouts | ⚠️ Minimal (Modern, rare) | ❌ Skip | No strong tradition |
| Onion | Base.Onion | ✅ Moderate (Pickled onions) | 🟢 Low | Common but less central |
| Green Onions | Base.GreenOnions | ⚠️ Minimal (Garnish in kimchi) | ❌ Skip | Too delicate as primary ingredient |

### Priority Classification

**🔴 High Priority (Next Implementations):**
1. **Cucumbers** - Universal pickle tradition, simple implementation

**🟡 Medium Priority (Phase 2):**
2. **Carrots** - Strong tradition, often mixed with other vegetables
3. **Radish** - Essential for authentic kimchi, strong Korean tradition
4. **Turnip** - Historical European and Japanese traditions

**🟢 Low Priority (Phase 3):**
5. **Beets** - Interesting option, more often made into kvass (drink)
6. **Bell Pepper** - Usually mixed, could be interesting variant
7. **Onion** - Supporting ingredient, less common as primary

**❌ Not Recommended:**
- Tomato (too acidic for lacto-fermentation)
- Potato (starch content makes it unsuitable)
- Broccoli (no historical precedence)
- Leek (better alternatives exist)
- Lettuce (too delicate, would disintegrate)
- Brussels Sprouts (no strong tradition)
- Green Onions (too delicate)

## Implementation Strategy

### Standard Pattern for Each Vegetable

Each fermented vegetable should follow this structure:

**Items (6 per vegetable):**
1. LactoFermented[Vegetable] - Glass jar, raw fermented
2. [JarName]Of[Vegetable]Stew - Glass jar, cooked
3. LactoFermented[Vegetable]ClayJar - Clay jar, raw fermented
4. ClayJarOf[Vegetable]Stew - Clay jar, cooked
5. LactoFermented[Vegetable]GlazedJar - Glazed jar, raw fermented
6. GlazedJarOf[Vegetable]Stew - Glazed jar, cooked

**Recipes (3 per vegetable):**
1. Make Fermented [Vegetable] - Glass jar variant
2. Make Clay Jar Fermented [Vegetable] - Clay jar variant
3. Make Glazed Jar Fermented [Vegetable] - Glazed jar variant

**Naming Convention:**
- Use "Fermented [Vegetable]" for display names (e.g., "Fermented Cucumbers", "Fermented Carrots")
- Exception: Sauerkraut for cabbage (well-known traditional name)

**Recipe Requirements (Standard):**

**IMPORTANT:** Ingredient order matters! All consumable items must come BEFORE the `-fluid` line.

Correct order:
1. `item 1 tags[SharpKnife] mode:keep flags[IsNotDull;SharpnessCheck]` - Tool (kept)
2. `item 1 [Base.EmptyJar/ClayJar/ClayJarGlazed] mode:destroy flags[ItemCount]` - Jar (consumed as whole item)
3. `item X [Base.Vegetable] flags[InheritFoodAge;ItemCount] mode:destroy` - Vegetables (consumed as whole items, quantity varies)
4. `item 3 [Base.Salt]` - Salt (consumed)
5. `item 1 [*] mode:keep` - Water container placeholder (kept)
6. `-fluid 1.0 [Water;TaintedWater]` - Water (1 liter, consumed)

**Critical Flags:**
- **Jars:** `mode:destroy flags[ItemCount]` - Ensures whole jar is consumed, not treated as portionable
- **Vegetables:** `flags[InheritFoodAge;ItemCount] mode:destroy` - **IMPORTANT: Use InheritFoodAge, NOT InheritFood!**
  - `InheritFoodAge` inherits only freshness/age (allows our hardcoded nutrition for multiple vegetables)
  - `InheritFood` inherits ALL properties including nutrition from ONE item (wrong for multi-vegetable recipes)
- **Why ItemCount?** Without this flag, food items are treated as portionable (like partially-eaten food) and only a portion is consumed

**Note:** Vegetable quantity varies by type to maintain consistent jar output:
- 1× for large vegetables (Cabbage)
- 2× for substantial vegetables (Turnip)
- 3× for medium vegetables (Cucumber, Carrot, Beet, Pepper, Onion)
- 8× for small vegetables (Radish)

**Item Properties (Standard):**
- DaysFresh: 120 (vs ~2-5 for fresh vegetables) - stays fresh for 4 months
- DaysTotallyRotten: 240 (vs ~4-12 for fresh vegetables) - 8 months total lifespan
- Degradation period: 120 days (from stale to rotten)
- ThirstChange: +5 (reflects high salt content)
- Weight: Original vegetable weight + 0.5 (for jar and brine)
- Nutrition: Based on source vegetable stats
- IsCookable: TRUE (can be heated into stew)
- Temperature: Neutral (no GoodHot/BadCold - eaten at any temperature)
- **ReplaceOnUse: MUST use Base. prefix!**
  - Glass jar: `ReplaceOnUse = Base.EmptyJar`
  - Clay jar: `ReplaceOnUse = Base.ClayJar`
  - Glazed jar: `ReplaceOnUse = Base.ClayJarGlazed`
  - Without Base. prefix, jars disappear when used in evolved recipes!
- ReplaceOnCooked: Appropriate stew variant (uses module prefix: Pseudonymous.)

**Cooked Stew Properties:**
- DaysFresh: 3 (cooked food spoils faster)
- DaysTotallyRotten: 5
- GoodHot: TRUE (stew is better hot)
- BadCold: FALSE (still edible cold)

### Phased Implementation Plan

#### Phase 1: Core Vegetables (Immediate)
1. ✅ Cabbage (Sauerkraut) - COMPLETE
2. ✅ Cucumber (Fermented Cucumbers) - COMPLETE
   - Most universally recognized
   - 3 cucumbers per jar

#### Phase 2: Traditional Favorites (Short Term)
3. ✅ Carrots - COMPLETE
4. 🟡 Radish - Essential for Korean-style ferments
5. 🟡 Turnip - Historical European tradition

#### Phase 3: Specialty Items (Long Term)
6. 🟢 Beets - Unique flavor, kvass tradition
7. 🟢 Bell Pepper - Mixed pickle component
8. 🟢 Onion - Pickled onion tradition

#### Phase 4: Mixed Ferments (Advanced)
- Consider recipes that combine vegetables:
  - Kimchi-style (Cabbage + Radish + others)
  - Mixed pickles (Cucumber + Carrot + Pepper)
  - Jardinière (French mixed vegetables)

## Recipe Scaling Strategy

### Hunger-Based Scaling
To ensure all fermented jars provide consistent value, recipes are scaled based on hunger values rather than using a flat 1:1 ratio. The target is approximately **-25 to -30 hunger per jar**, matching the sauerkraut baseline.

### Vegetable Requirements Table

| Vegetable | Base Hunger | Quantity Required | Jar Output Hunger | Priority | Notes |
|-----------|-------------|-------------------|-------------------|----------|-------|
| Cabbage | -24 | 1 | -25 | ✅ High (Done) | Perfect 1:1 ratio |
| Cucumber | -10 | 3 | -30 | 🔴 High (Next) | Pickling cucumbers |
| Carrots | -8 | 3 | -24 | 🟡 Medium | Carrot sticks in jar |
| Radish | -3 | 8 | -24 | 🟡 Medium | Small, need many |
| Turnip | -18 | 2 | -36 | 🟡 Medium | Substantial vegetable |
| SugarBeet | -9 | 3 | -27 | 🟢 Low | Beet pickles |
| BellPepper | -8 | 3 | -24 | 🟢 Low | Mixed pickle component |
| Onion | -10 | 3 | -30 | 🟢 Low | Pickled onions |
| Broccoli | -9 | N/A | N/A | ❌ Skip | No historical precedent |

**Scaling Rationale:**
- **Target range:** -24 to -36 hunger per jar ensures consistent value
- **Small vegetables** (radish -3) require more units to fill a jar
- **Large vegetables** (cabbage -24, turnip -18) require fewer units
- **Medium vegetables** (cucumber, carrot, beet -8 to -10) require 3 units
- Jar output hunger = sum of input vegetables (no fermentation loss/gain)

**Example Scaling:**
- 1 cabbage (-24) → 1 jar of sauerkraut (-25)
- 3 cucumbers (3 × -10 = -30) → 1 jar of pickles (-30)
- 8 radishes (8 × -3 = -24) → 1 jar of pickled radishes (-24)

This ensures:
- Consistent nutritional value across all fermented jars
- Realistic quantities (small vegetables need more)
- Balanced resource investment (you need more of cheaper/smaller vegetables)

## Design Considerations

### Shelf Life Rationale
After analyzing the game's spoilage mechanics and comparing with other preserved foods:
- **DaysFresh = 120, DaysTotallyRotten = 240** provides 8 months total lifespan
- Fresh phase (120 days) represents peak quality fermented vegetables
- Degradation phase (120 days) represents slow decline but still edible
- Comparison: Fresh cabbage (2/4 days), Potatoes (28/280 days)
- Real-world fermented vegetables: 4-12 months at room temperature
- Game balance: Makes fermentation a valuable long-term preservation strategy without being overpowered

### Nutrition Balance
- Fermented versions should have similar nutrition to source vegetables
- ThirstChange should reflect salt content (+5 is appropriate)
- Shelf life extension is the primary benefit (120/240 days = 8 months vs 2-8 days for fresh vegetables)
- Significant preservation: ~30-60x longer than fresh vegetables
- Slight weight increase for jar and brine (+0.5 kg)

### Recipe Balance
- All recipes use same inputs: vegetable + salt + water + jar + knife
- Water requirement: 1.0 liter (realistic for brine in a jar)
- Time requirement: 200 game units (reasonable for "fermentation")
- XP Award: 10 Cooking XP (higher than simple cooking)
- Can use any water source (clean or tainted - salt preserves)

### Jar Type Consistency
- All fermented items come in 3 jar variants:
  - Glass jar (Base.EmptyJar)
  - Clay jar (Base.ClayJar)
  - Glazed clay jar (Base.ClayJarGlazed)
- Each jar type properly returns itself when consumed
- Icons match jar type (JarWhite, ClayJar_Fired, ClayJar_Glazed_Fired)

### Cooked Variants
- Each fermented item can be cooked into a stew
- Cooking reduces shelf life (3/5 days vs 120/240)
- Cooked stew versions have GoodHot = true (better hot)
- Fermented versions are temperature-neutral (no GoodHot/BadCold)
- Maintains same jar type when cooked
- Returns same jar type when eaten

## Technical Implementation Notes

### Build 42 Recipe Syntax

**Critical Discovery:** Ingredient order and flags are essential for proper consumption!

**Ingredient Ordering Rules:**
- **ALL consumable items must be listed BEFORE the `-fluid` line**
- Items listed AFTER `-fluid` line are NOT properly consumed by default
- Standard order: Tools (kept) → Consumables → Water placeholder (kept) → `-fluid` line

**Essential Flags:**
- `flags[ItemCount]` on jars and vegetables - Treats items as whole units, not portionable
- `mode:destroy` on jars and vegetables - Explicitly marks for consumption (though default for items before `-fluid`)
- `flags[InheritFoodAge;ItemCount]` on vegetables - **Use InheritFoodAge (age only), NOT InheritFood (all properties)**
  - InheritFoodAge preserves our hardcoded nutrition while inheriting freshness/age
  - InheritFood would copy nutrition from ONE item, breaking multi-vegetable recipes
- Without `ItemCount`, food items only partially consumed (game treats them as portionable like half-eaten food)

**Other Syntax Rules:**
- Use lowercase `time` not uppercase `Time`
- Items before `-fluid` line must have quantity 1 (except those with specific amounts like salt)
- Fluid line format: `-fluid 1.0 [Water;TaintedWater]` (1.0 = 1 liter)
- Water placeholder: `item 1 [*] mode:keep,` comes immediately before `-fluid` line

**Example (correct order):**
```
inputs
{
    item 1 tags[SharpKnife] mode:keep flags[IsNotDull;SharpnessCheck],
    item 1 [Base.EmptyJar] mode:destroy flags[ItemCount],
    item 3 [Base.Cucumber] flags[InheritFoodAge;ItemCount] mode:destroy,
    item 3 [Base.Salt],
    item 1 [*] mode:keep,
        -fluid 1.0 [Water;TaintedWater],
}
```

### Common Mistakes to Avoid

1. **Missing Base. prefix on ReplaceOnUse**
   - ❌ Wrong: `ReplaceOnUse = EmptyJar`
   - ✅ Correct: `ReplaceOnUse = Base.EmptyJar`
   - Impact: Without Base. prefix, jars disappear when used in evolved recipes

2. **Using InheritFood instead of InheritFoodAge**
   - ❌ Wrong: `flags[InheritFood;ItemCount]`
   - ✅ Correct: `flags[InheritFoodAge;ItemCount]`
   - Impact: InheritFood copies nutrition from ONE vegetable, breaking multi-vegetable recipes

3. **Placing consumables after -fluid line**
   - ❌ Wrong: `-fluid 1.0 [Water]` then vegetables/jars
   - ✅ Correct: Vegetables/jars then `-fluid 1.0 [Water]`
   - Impact: Items after -fluid line are not properly consumed

4. **Missing ItemCount flag**
   - ❌ Wrong: `item 3 [Base.Cucumber]`
   - ✅ Correct: `item 3 [Base.Cucumber] flags[ItemCount]`
   - Impact: Food treated as portionable, only partial consumption

### Testing Checklist (Per Vegetable)
- [ ] All 6 items load without errors
- [ ] All 3 recipes appear in crafting menu
- [ ] Recipes require correct ingredients
- [ ] **CRITICAL:** All ingredients properly consumed (vegetables, jars, salt, water)
- [ ] **CRITICAL:** Whole vegetables consumed (not just portions)
- [ ] **CRITICAL:** Whole jars consumed (not kept in inventory)
- [ ] Fermented items have correct shelf life (120/240 days = 8 months total)
- [ ] Food age/freshness inherited from input vegetables to output jar
- [ ] **CRITICAL:** Eating jar directly returns correct empty jar (Base.EmptyJar, Base.ClayJar, or Base.ClayJarGlazed)
- [ ] **CRITICAL:** Using jar in evolved recipe (salad, stew, etc.) uses portions and eventually returns empty jar
- [ ] Cooking produces stew variant
- [ ] Stew has reduced shelf life (3/5 days)
- [ ] Icons display correctly for all jar types
- [ ] ThirstChange works as intended (+5)

## File Structure

### Items File Location
`mymods/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt`

### Recipes File Location
`mymods/PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`

### Naming Conventions
- Module: `Pseudonymous`
- Items: `Pseudonymous.[ItemName]`
- Recipes: `craftRecipe Make [Display Name]`
- Display names: Clear and descriptive
  - "Jar of Sauerkraut" not "LactoFermentedCabbage"
  - "Clay Jar of Pickles" not "LactoFermentedCucumberClayJar"

## Historical & Cultural Context

### Why Lacto-Fermentation?
- **Historical Importance:** One of oldest food preservation methods (thousands of years)
- **Pre-refrigeration:** Essential for winter food storage
- **Health Benefits:** Probiotics, vitamins, digestibility
- **Kentucky Setting:** Rural setting where traditional preservation methods would be valued
- **Survival Context:** Perfect for post-apocalyptic food preservation

### Real-World Examples
- **Sauerkraut:** German, Eastern European staple
- **Kimchi:** Korean national dish, UNESCO heritage
- **Dill Pickles:** American tradition (actually lacto-fermented, not vinegar)
- **Japanese Tsukemono:** Various pickled vegetables
- **Russian/Ukrainian pickles:** Cucumbers, tomatoes, cabbage
- **Middle Eastern torshi:** Mixed vegetable ferments

## Future Enhancements

### Possible Advanced Features (Post-MVP)
1. **Fermentation Time Variation:** Different vegetables take different times
2. **Spice/Herb Additions:** Dill, garlic, peppercorns for flavor variants
3. **Mixed Ferments:** Recipes combining multiple vegetables
4. **Brine Mechanics:** Save/reuse brine from finished ferments
5. **Temperature Effects:** Faster in summer, slower in winter
6. **Skill Progression:** Better success rate with higher cooking skill
7. **Quality Variations:** Chance for exceptional or poor batches

### Integration with Other Mods
- **PseudoSaltWell:** Natural synergy - well provides saltwater source
- **PseudoClay:** Clay jars for authentic storage
- **Farming Mods:** Increased vegetable yields make fermentation more viable

## Conclusion

This plan provides a systematic approach to expanding the PseudoSaltRecipes mod with historically-authentic lacto-fermented vegetables. Starting with cucumbers (pickles) and progressing through vegetables with strong fermentation traditions ensures each addition has cultural and practical validity for the Project Zomboid setting.

The standardized implementation pattern makes it straightforward to add new vegetables while maintaining consistency across the mod. Each vegetable follows the same structure: 6 items, 3 recipes, 3 jar variants, maintaining balance and player expectations.
