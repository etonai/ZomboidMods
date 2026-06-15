# PseudoSaltRecipes vs VanillaCraftableFoods: Mod Breakage Analysis

**Created:** 2026-06-14  
**Purpose:** Identify why PseudoSaltRecipes fails in B42 by comparing it to the working VanillaCraftableFoods.42 mod  
**Version:** Project Zomboid 42.11.0

---

## Overview

VanillaCraftableFoods works. PseudoSaltRecipes does not. Both use only `.txt` script files (no Lua) and the same B42 `craftRecipe` system. The differences below are code-verified against the actual files.

Files examined:
- `notmymods/VanillaCraftableFoods/42/` — working reference
- `mymods/PseudoSaltRecipes/42/` — broken mod

---

## Differences Found (Ranked by Likely Impact)

---

### 1. Tag Namespace and Casing — CRITICAL

**VanillaCraftableFoods (working):**
```
item 1 tags[base:sharpknife;base:meatcleaver] mode:keep flags[IsNotDull;SharpnessCheck],
item 2 [Base.Salt;Base.SeasoningSalt],
```

**PseudoSaltRecipes (broken):**
```
item 1 tags[SharpKnife;MeatCleaver] mode:keep flags[IsNotDull;SharpnessCheck],
item 2 [Base.Salt],
```

B42 requires tag references to include the module namespace prefix (`base:`) and be **lowercase**. The old B41 format used PascalCase without a prefix (`SharpKnife`, `MeatCleaver`). The game will fail to match tools against `SharpKnife` because the tag no longer exists under that name — it is now `base:sharpknife`.

**Fix:** Change all `tags[...]` entries to use the `base:` prefix and lowercase:
- `tags[SharpKnife;MeatCleaver]` → `tags[base:sharpknife;base:meatcleaver]`
- `tags[SharpKnife]` → `tags[base:sharpknife]`

---

### 2. `InheritFood` Flag Renamed to `InheritFoodAge` — CRITICAL

**VanillaCraftableFoods (working):**
```
flags[InheritFoodAge;ItemCount]
```

**PseudoSaltRecipes (broken):**
```
flags[InheritFood;ItemCount]
```

The flag `InheritFood` was renamed to `InheritFoodAge` in B42. Using the old name means the game either ignores it silently or throws a parse error. This affects nearly every recipe input in PseudoSaltRecipes.

**Fix:** Replace every instance of `InheritFood` with `InheritFoodAge`.

---

### 3. `OnCreate` Callbacks — CRITICAL

**VanillaCraftableFoods (working):**  
No `OnCreate` in any `craftRecipe` block.

**PseudoSaltRecipes (broken):**
```
OnCreate = Recipe.OnCreate.CutFillet,
OnCreate = Recipe.OnCreate.CutChicken,
OnCreate = Recipe.OnCreate.CutAnimal,
```

The `Recipe.OnCreate.*` callback namespace is a B41 pattern. In B42 the recipe scripting system was rewritten and these handlers no longer exist under those names. If the game tries to call a non-existent callback it will likely error and refuse to register the recipe.

**Fix:** Remove `OnCreate` lines from all recipes. Since itemMapper already handles the output routing, OnCreate is redundant here. If you need side-effects (e.g. skill gain), use the `xpAward` field which is already present.

---

### 4. Recipe Names Containing Spaces — HIGH RISK

**VanillaCraftableFoods (working):**
```
craftRecipe PrepareTaco
craftRecipe PrepareHotdogBun
craftRecipe MakeSoySauce
```

**PseudoSaltRecipes (broken):**
```
craftRecipe Make Salted Fillet
craftRecipe Salt Meat ChickenStyle
craftRecipe Salt Meat AnimalStyle
craftRecipe Make Sauerkraut
craftRecipe Make Clay Jar Sauerkraut
```

B42 appears to treat recipe names as single tokens. Spaces in the name may cause parse failures or silent registration failures. All working B42 mods (including VanillaCraftableFoods) use single-word PascalCase names. This is a consistent pattern across the entire working mod.

**Fix:** Remove spaces from recipe names:
- `Make Salted Fillet` → `MakeSaltedFillet`
- `Salt Meat ChickenStyle` → `SaltMeatChickenStyle`
- `Make Sauerkraut` → `MakeSauerkraut`
- etc.

---

### 5. Missing itemMapper Entry for `Base.Chicken` — BUG

In the `Salt Meat AnimalStyle` recipe, `Base.Chicken` is listed as a valid input:

```
item 1 [Base.Rabbitmeat;Base.Venison;Base.Beef;Base.Steak;Base.Chicken;Base.ChickenFillet;...] mappers[meatType]
```

But the `itemMapper meatType` block does **not** include a mapping for `Base.Chicken`:

```
itemMapper meatType
{
    Pseudonymous.SaltedRabbitmeat = Base.Rabbitmeat,
    Pseudonymous.SaltedVenison = Base.Venison,
    Pseudonymous.SaltedBeef = Base.Beef,
    Pseudonymous.SaltedSteak = Base.Steak,
    Pseudonymous.SaltedChickenFillet = Base.ChickenFillet,   ← present
    Pseudonymous.SaltedPork = Base.Pork,
    ...
    -- Base.Chicken is MISSING here
}
```

The item `SaltedChicken` IS defined in `PseudoSaltItems.txt`, so the output item exists. The mapper just doesn't reference it, meaning `Base.Chicken` would either be consumed without producing output or would block the recipe from being offered when Chicken is in inventory.

**Fix:** Add `Pseudonymous.SaltedChicken = Base.Chicken,` to the `meatType` mapper in `Salt Meat AnimalStyle`.

---

### 6. `mod.info` Missing `versionMin` — LOW RISK

**VanillaCraftableFoods:**
```
versionMin=42.19
```

**PseudoSaltRecipes:**
```
name=PseudonymousEd's Salt Preservation Recipes
poster=poster.png
id=PseudoSaltPreservation
description=Recipes for preserving food with salt
```

No `versionMin` field. This is unlikely to be a breaking issue (the game will still load the mod), but it means the game won't warn users if they try to run it on an incompatible version.

**Fix:** Add `versionMin=42.0` (or the specific version you developed against).

---

### 7. Fluid Input Syntax — INVESTIGATE

**VanillaCraftableFoods (working):**
```
item 1 [*],
-fluid 1.0 [Water],
```

**PseudoSaltRecipes (broken):**
```
item 1 [*] mode:keep,
        -fluid 1.0 [Water;TaintedWater],
```

There are two sub-differences here:

a) **`mode:keep` on the fluid container**: VanillaCraftableFoods never applies `mode:keep` to the `[*]` wildcard container that holds fluid. The `[*]` container is always consumed. Marking it `mode:keep` may confuse the fluid system.

b) **`TaintedWater` as a fluid type**: VanillaCraftableFoods only uses `[Water]`. Whether `TaintedWater` is a valid B42 fluid type for recipe inputs is unconfirmed. If it's not recognized it could cause the fluid requirement to never be satisfied.

---

## Summary Table

| Issue | Location | Severity | Status in VanillaCraftableFoods |
|---|---|---|---|
| Tag naming (`SharpKnife` → `base:sharpknife`) | Recipes | Critical | Uses `base:` prefix, lowercase |
| `InheritFood` → `InheritFoodAge` flag | Recipes | Critical | Always uses `InheritFoodAge` |
| `OnCreate = Recipe.OnCreate.*` callbacks | Recipes | Critical | Not used at all |
| Spaces in recipe names | Recipes | High | Never uses spaces in names |
| Missing `Base.Chicken` in mapper | Salt Meat AnimalStyle | Medium | N/A |
| Missing `versionMin` | mod.info | Low | Present (`versionMin=42.19`) |
| `mode:keep` on fluid container | Sauerkraut/Fermented recipes | Low/Investigate | Never uses `mode:keep` on `[*]` |
| `TaintedWater` fluid type | Sauerkraut/Fermented recipes | Low/Investigate | Not used |

---

## Most Likely Root Cause

The three critical issues (tag naming, `InheritFood` flag, and `OnCreate` callbacks) are all leftover B41 syntax that was not updated when the mod was ported to B42. Any one of these could prevent all recipes in the module from registering. The tag naming issue is almost certainly what causes the knife/cleaver tool to never match, making every recipe impossible to craft even if they do load.

The `InheritFood` issue would cause food age inheritance to silently fail, meaning output items would always start at 0 age rather than inheriting from inputs — a behaviour bug rather than a load failure.

The `OnCreate` callbacks are the highest risk for an outright load error or parse failure.
