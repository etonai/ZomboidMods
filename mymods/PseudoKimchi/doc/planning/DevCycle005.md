# DevCycle 005: Kimchi Recipe Food Unit Fix

**Status:** Work Complete
**Start Date:** 2026-07-02
**Target Completion:** 2026-07-02
**Focus:** Fix PseudoKimchi recipes so edible ingredients use hunger-unit quantities instead of `ItemCount` whole-item counts, and reduce Kentucky Kimchi happiness benefit to 10.

---

## Goal

Correct the three Kentucky Kimchi craft recipes so they do not require unintended whole-item counts for edible ingredients. The previous cabbage input used:

```txt
item 24 [Base.Cabbage] flags[InheritFoodAge;ItemCount],
```

With `ItemCount`, that meant 24 whole cabbages. That was not the design intent. The corrected recipe requires 24 hunger units of cabbage, which is equivalent to one full cabbage because vanilla `Base.Cabbage` has `HungerChange = -24.0`.

This should also prevent a partially eaten cabbage from satisfying the cabbage requirement, because a partial cabbage should have less than 24 hunger units remaining.

DC5 now also includes Ed's requested balance change: Kentucky Kimchi should only give 10 happiness. In Project Zomboid item script terms, that means changing the current `UnhappyChange = -20` to `UnhappyChange = -10` on all Kentucky Kimchi jar variants.

## Desired Outcome

Each PseudoKimchi recipe requires the intended food quantity without forcing absurd whole-item counts:

- 24 hunger units of cabbage, not 24 whole cabbages.
- 2 garlic.
- 1 dried jalapeno.
- 1 cooked little bait fish.

Each Kentucky Kimchi item gives only 10 happiness:

- `KentuckyKimchi`: `UnhappyChange = -10`
- `KentuckyKimchiClayJar`: `UnhappyChange = -10`
- `KentuckyKimchiGlazedJar`: `UnhappyChange = -10`

Jar inputs, tools, and water handling keep their current item-count behavior where appropriate.

---

## Affected Files

Recipe target:

- `mymods/PseudoKimchi/PseudoKimchi/42/media/scripts/recipes/PseudoKimchiRecipes.txt`

Item balance target:

- `mymods/PseudoKimchi/PseudoKimchi/42/media/scripts/items/PseudoKimchiItems.txt`

Recipes in scope:

- `MakeKentuckyKimchi`
- `MakeClayJarKentuckyKimchi`
- `MakeGlazedJarKentuckyKimchi`

Items in scope:

- `KentuckyKimchi`
- `KentuckyKimchiClayJar`
- `KentuckyKimchiGlazedJar`

---

## Original Recipe Problem

All three recipes previously contained these edible ingredient lines:

```txt
item 24 [Base.Cabbage] flags[InheritFoodAge;ItemCount],
item 1 [Base.Garlic] flags[InheritFoodAge;ItemCount],
item 1 [Base.PepperJalapenoDried] flags[ItemCount],
item 1 [Base.BaitFish] flags[IsCookedFoodItem;InheritFoodAge;ItemCount],
```

`ItemCount` is correct for jar inputs because the recipe consumes a container object. It was not intended for the edible ingredients in this cycle.

---

## Evidence Checked During Recipe Implementation

Relevant vanilla food values in `media/scripts/generated/items/food.txt`, plus Ed-approved recipe amounts:

| Item | Vanilla hunger | Implemented recipe amount |
|---|---:|---:|
| `Base.Cabbage` | `-24.0` | `24` |
| `Base.Garlic` | `-5.0` | `2` |
| `Base.PepperJalapenoDried` | `-1.0` | `1` |
| `Base.BaitFish` | `-3.0` | `1` |

Relevant vanilla recipe pattern in `media/scripts/generated/recipes/recipes_cooking.txt`:

```txt
item 1 [Base.Cabbage] flags[InheritFoodAge],
item 1 [Base.MincedMeat] flags[InheritFoodAge;IsCookedFoodItem],
item 1 [Base.Onion] flags[InheritFoodAge],
```

B42 code evidence:

- `zombie42_19/inventory/recipemanager/ItemRecord.java` uses `1.0F` when `sourceRecord.isUseIsItemCount()` is true.
- For food inputs without `ItemCount`, `ItemRecord.getUses()` returns `(int)(-foodItem.getHungerChange() * 100.0F)`.
- `ItemRecord.applyUses()` consumes food by reducing hunger, calories, carbohydrates, lipids, proteins, and related food stats by the used percentage.
- `zombie42_19/scripting/entity/components/crafting/InputScript.java` treats non-`ItemCount`, non-`destroy`, non-`keep` food inputs with meaningful hunger as partial-item inputs.

---

## Implemented Recipe Changes

For each of the three PseudoKimchi recipes, the edible ingredient lines are now:

```txt
item 24 [Base.Cabbage] flags[InheritFoodAge],
item 2 [Base.Garlic] flags[InheritFoodAge],
item 1 [Base.PepperJalapenoDried],
item 1 [Base.BaitFish] flags[IsCookedFoodItem;InheritFoodAge],
```

These non-food/container/tool lines were preserved:

```txt
item 1 tags[base:sharpknife] mode:keep flags[IsNotDull;SharpnessCheck],
item 1 [Base.EmptyJar] mode:destroy flags[ItemCount],
item 1 [Base.ClayJar] mode:destroy flags[ItemCount],
item 1 [Base.ClayJarGlazed] mode:destroy flags[ItemCount],
item 5 [Base.Salt],
item 1 [*] mode:keep,
        -fluid 1.0 [Water;TaintedWater],
```

Salt currently has no `ItemCount` flag, so it was not part of the recipe bug fixed here.

---

## Planned Happiness Change

All three Kentucky Kimchi items currently have:

```txt
UnhappyChange = -20,
```

Per Ed's request, each should be reduced to:

```txt
UnhappyChange = -10,
```

This work has now been implemented as part of DC5.

---

## Tasks

### Phase 1: Confirm Food Unit Semantics

**Status:** Work Complete

- [x] Re-read the PseudoKimchi recipes and identify every edible ingredient line using `ItemCount`.
- [x] Confirm the B42 craft recipe behavior for food inputs without `ItemCount`.
- [x] Confirm that the numeric amount without `ItemCount` is interpreted as food uses derived from hunger for food inputs.
- [x] Confirm that requiring 24 hunger units of `Base.Cabbage` should reject partially eaten cabbage.
- [x] Re-check vanilla recipe examples using food inputs without `ItemCount`.

### Phase 2: Confirm Intended Food Amounts

**Status:** Work Complete

- [x] Confirm `Base.Cabbage` has `HungerChange = -24.0`, so the cabbage input should be `item 24 [Base.Cabbage] flags[InheritFoodAge]`.
- [x] Set the garlic input to `item 2 [Base.Garlic] flags[InheritFoodAge]` per Ed's direction; remove `ItemCount`.
- [x] Confirm `Base.PepperJalapenoDried` has `HungerChange = -1.0`, so the dried jalapeno input can remain `item 1` while removing `ItemCount`.
- [x] Keep the cooked little bait fish input at `item 1 [Base.BaitFish] flags[IsCookedFoodItem;InheritFoodAge]` per Ed's direction; remove only `ItemCount`.
- [x] Leave `Base.Salt` unchanged unless verification shows it needs separate handling.

### Phase 3: Update All Kimchi Jar Recipes

**Status:** Work Complete

- [x] Update `MakeKentuckyKimchi` edible inputs.
- [x] Update `MakeClayJarKentuckyKimchi` edible inputs.
- [x] Update `MakeGlazedJarKentuckyKimchi` edible inputs.
- [x] Preserve jar input lines and their `mode:destroy flags[ItemCount]` behavior.
- [x] Preserve the sharp knife `mode:keep` line.
- [x] Preserve the water container/fluid syntax.
- [x] Do not change outputs, item ids, recipe names, nutrition, models, translations, or metadata.

### Phase 4: Recipe Verification

**Status:** Work Complete

- [x] Read back `PseudoKimchiRecipes.txt` after editing.
- [x] Confirm no edible ingredient line in the three kimchi recipes still has `ItemCount`.
- [x] Confirm jar inputs still have `ItemCount`.
- [x] Check script brace balance.
- [x] Confirm file encoding remains UTF-8 without BOM.

### Phase 5: Reduce Kentucky Kimchi Happiness Benefit

**Status:** Work Complete

- [x] Update `KentuckyKimchi` from `UnhappyChange = -20` to `UnhappyChange = -10`.
- [x] Update `KentuckyKimchiClayJar` from `UnhappyChange = -20` to `UnhappyChange = -10`.
- [x] Update `KentuckyKimchiGlazedJar` from `UnhappyChange = -20` to `UnhappyChange = -10`.
- [x] Preserve nutrition, spoilage, jar-return, model, translation, and recipe behavior.
- [x] Read back the item script and confirm exactly three `UnhappyChange = -10` lines are present.

### Phase 6: Final Verification

**Status:** Planning

- [ ] Launch or ask Ed to launch with PseudoKimchi enabled and verify the recipes no longer require 24 whole cabbages.
- [ ] Verify Kentucky Kimchi happiness benefit is 10 in game.
- [ ] Keep this DevCycle at `Work Complete` after implementation until Ed approves `Verified`.

---

## Notes and Risks

- Ed explicitly requested implementation of the recipe part of DC5.
- Ed added a new DC5 requirement after the recipe work was completed: Kentucky Kimchi happiness should only be 10.
- The happiness change is implemented; DC5 is `Work Complete` pending in-game verification and Ed approval for `Verified`.
- The cabbage issue is clear: `ItemCount` turned `24` into 24 whole cabbages.
- Garlic is set to quantity `2` per Ed's correction. Bait fish remains at quantity `1`. This cycle removes their `ItemCount` flags while using those approved numeric amounts.
- Dried jalapeno also remains at quantity `1`; this cycle removes its `ItemCount` flag without changing the numeric amount.
- Do not mark this cycle `Verified` without Ed's explicit approval.

---

## Completion Summary

**Completion Date:** 2026-07-02
**Status:** Work Complete
**Files modified:**

- `mymods/PseudoKimchi/PseudoKimchi/42/media/scripts/recipes/PseudoKimchiRecipes.txt`
- `mymods/PseudoKimchi/PseudoKimchi/42/media/scripts/items/PseudoKimchiItems.txt`
- `mymods/PseudoKimchi/doc/planning/DevCycle005.md`

**Accomplishments:**

- Removed `ItemCount` from cabbage, garlic, dried jalapeno, and bait fish inputs in all three Kimchi recipes.
- Changed garlic quantity from `1` to `2` per Ed's correction.
- Preserved jar input `ItemCount` handling for glass, clay, and glazed clay jars.
- Preserved sharp knife, salt, water, outputs, item ids, recipe names, nutrition, models, translations, and metadata during recipe editing.
- Verified recipe script brace balance: 10 opening braces and 10 closing braces.
- Verified recipe script starts with `6D 6F 64 75`, so no UTF-8 BOM is present.
- Reduced Kentucky Kimchi happiness benefit to 10 by changing all three item variants to `UnhappyChange = -10`.
- Verified item script brace balance: 4 opening braces and 4 closing braces.
- Verified item script starts with `6D 6F 64 75`, so no UTF-8 BOM is present.

**Work Deferred:**

- Installed-copy update for game testing, if needed.
- In-game recipe and item-balance verification with PseudoKimchi enabled.