# DevCycle 001: Kentucky Kimchi Initial Implementation

**Status:** Work Complete
**Start Date:** 2026-07-01
**Target Completion:** 2026-07-01
**Focus:** Build the first playable B42 version of PseudonymousEd's Kentucky Kimchi.

---

## Goal

Create the initial implementation of the PseudoKimchi mod for Project Zomboid B42. The mod should add a Kentucky-style kimchi recipe using available game ingredients and produce a balanced preserved food item that matches the design notes in `doc/ideas/kimchi_recipe.md`.

This cycle is intentionally limited to the first working version. Future work, such as optional ginger support, should be deferred until the core item and recipe are working cleanly.

## Desired Outcome

PseudoKimchi loads in B42 without script errors. Players can craft Kentucky kimchi in any supported jar type from cabbage, salt, water, garlic, dried jalapeno, and cooked little bait fish, producing jarred food items with the intended nutrition, thirst, happiness, spoilage behavior, and matching jar return on use.

---

## Tasks

### Phase 1: Script Structure and References

**Status:** Work Complete

- [x] Inspect existing B42 food item and recipe script patterns in `media/scripts/generated/`.
- [x] Use `mymods/PseudoSaltRecipes/` as the reference mod for naming, folder structure, script organization, and B42 conventions.
- [x] Decide exact item module/name and recipe name for Kentucky kimchi.

**Technical Notes:**
Use vanilla B42 scripts as the source of truth for syntax. Use `mymods/PseudoSaltRecipes/` as the project-specific reference for local mod structure and conventions when those patterns match B42 generated script conventions.

Implemented under module `Pseudonymous`, matching `PseudoSaltRecipes`. The jarred kimchi items are `Pseudonymous.KentuckyKimchi`, `Pseudonymous.KentuckyKimchiClayJar`, and `Pseudonymous.KentuckyKimchiGlazedJar`; the recipes are `MakeKentuckyKimchi`, `MakeClayJarKentuckyKimchi`, and `MakeGlazedJarKentuckyKimchi`. B42 script files were placed under `PseudoKimchi/42/media/scripts/items/` and `PseudoKimchi/42/media/scripts/recipes/`, following the loaded B42 folder pattern used by `PseudoSaltRecipes`.

### Phase 2: Kentucky Kimchi Item

**Status:** Work Complete

- [x] Add Kentucky kimchi food item scripts under the mod's `42/media/scripts/` tree, one for each supported jar type.
- [x] Set food values based on the design note: nutrition comparable to one cabbage, `thirstChange = 0`, happiness benefit, `DaysFresh = 21`, and `DaysTotallyRotten = 730` if supported by B42 item syntax.
- [x] Investigate whether stale-stage happiness can increase to 20; if unsupported or risky, set the initial happiness value to 20 per the design note.

**Technical Notes:**
The design intent is "same nutritional value as 1 cabbage" rather than a stronger late-game food. Verified B42 cabbage values in `media/scripts/generated/items/food.txt`: `HungerChange = -24.0`, `Calories = 180.0`, `Carbohydrates = 41.0`, `Proteins = 9.0`, `Lipids = 0.7`.

B42 item parsing supports `UnhappyChange` as a single static item field, but no separate stale-only happiness field was found in script parsing or `Food` age handling. Implemented the design fallback as `UnhappyChange = -20` from the start on all jar variants. In Project Zomboid script terms, negative `UnhappyChange` reduces unhappiness, so this represents a happiness benefit.

### Phase 3: Crafting Recipe

**Status:** Work Complete

- [x] Add B42-compatible jar recipes using cabbage, salt, water, garlic, dried jalapeno, and cooked little bait fish.
- [x] Confirm ingredient identifiers and quantities against B42 scripts.
- [x] Ensure the water input uses valid B42 fluid/container syntax.
- [x] Require the appropriate jar container for each recipe, plus work surface, knife, and cooking category.

**Technical Notes:**
Initial target recipe from `doc/ideas/kimchi_recipe.md`: cabbage 24 units, salt 5 units, water 1 liter, garlic 1 unit, dried jalapeno 1 unit, cooked little bait fish 1 unit.

Implemented exactly those ingredient quantities with verified B42 ids: `Base.Cabbage`, `Base.Salt`, `Base.Garlic`, `Base.PepperJalapenoDried`, and `Base.BaitFish`. Added three jar-specific recipes equivalent to the sauerkraut recipes in `PseudoSaltRecipes`: glass jar (`Base.EmptyJar` -> `Pseudonymous.KentuckyKimchi`), clay jar (`Base.ClayJar` -> `Pseudonymous.KentuckyKimchiClayJar`), and glazed clay jar (`Base.ClayJarGlazed` -> `Pseudonymous.KentuckyKimchiGlazedJar`). Each output returns the matching jar through `ReplaceOnUse`. The bait fish input uses `flags[IsCookedFoodItem;InheritFoodAge;ItemCount]` so the recipe requires cooked little bait fish. Food ingredients are consumed with normal B42 item-count recipe inputs, without explicit `mode:destroy`; explicit mode is reserved for the kept knife, transformed jar input, and kept water container. Water uses the same B42 fluid syntax pattern used by `PseudoSaltRecipes`: `item 1 [*] mode:keep` plus `-fluid 1.0 [Water;TaintedWater]`.

Each recipe requires a sharp knife, an `AnySurfaceCraft;Cooking` work surface/category, and one jar input matching the output jar type, following the preservation recipe style in `PseudoSaltRecipes`.

### Phase 4: Mod Metadata and Player-Facing Text

**Status:** Work Complete

- [x] Review `mod.info` for B42 compatibility fields such as `versionMin=42.0`.
- [x] Add or update display names and recipe text where required.
- [x] Preserve the existing mod description tone unless a B42 packaging requirement needs a change.

**Technical Notes:**
The current mod metadata already identifies the mod as `PseudoKimchi`. Keep that id stable unless a load conflict is discovered.

Added `versionMin=42.0` to `PseudoKimchi/42/mod.info`. Added jar-specific display names directly on the item script: `Jar of Kentucky Kimchi`, `Clay Jar of Kentucky Kimchi`, and `Glazed Jar of Kentucky Kimchi`. Updated the copied README so it describes PseudoKimchi instead of the template agriculture mod.

### Phase 5: Verification

**Status:** Work Complete

- [x] Review all new script files for B42 syntax issues.
- [x] Compare recipe and item syntax against known working mods in `mymods/`.
- [x] Record any assumptions or unresolved behavior in this DevCycle document before moving the cycle to Work Complete.

**Technical Notes:**
In-game verification may require user involvement. Do not mark this phase or cycle as `Verified` without explicit user approval.

Read back all generated PseudoKimchi scripts after writing them. Compared item fields and recipe structure against vanilla generated scripts and `PseudoSaltRecipes`; adjusted food ingredient inputs to follow vanilla consumed-food style by omitting explicit `mode:destroy`. Confirmed through `zombie42_19/scripting/objects/Item.java` that `DaysFresh`, `DaysTotallyRotten`, and `UnhappyChange` are valid parsed item fields. No in-game load test was run in this cycle.

---

## Open Questions

1. ~~**Can B42 food items increase happiness only after becoming stale?**~~
   **Resolved:** No B42 script field or food-age code path was found for stale-only happiness. Implemented the fallback from the design note: `UnhappyChange = -20` from the start.

2. ~~**Which exact B42 item should represent dried jalapeno?**~~
   **Resolved:** Use vanilla `Base.PepperJalapenoDried`, confirmed in `media/scripts/generated/items/food.txt`.

3. ~~**Should the first version include optional ginger?**~~
   **Resolved:** No. Ed explicitly confirmed no ginger in DC1.

---

## Notes and Risks

- This cycle was implemented after Ed explicitly requested `implement DC 1`.
- The mod's local `doc/planning/DevCycleTemplate.md` is currently empty, so this document follows the root `DevCycles/DevCycleTemplate.md` structure.
- `mymods/PseudoKimchi/AGENTS.md` prohibits agents from marking work `Verified` without user approval; this cycle is recorded as `Work Complete` only.
- The recipe currently consumes 24 whole `Base.Cabbage` items because the design note said "Cabbage - 24 units." If that was intended as a partial unit count rather than 24 items, the recipe should be adjusted in a future review.
- Kimchi is jarred like the sauerkraut recipes in `PseudoSaltRecipes`; the mod now has equivalent glass jar, clay jar, and glazed clay jar recipes.

---

## Completion Summary

**Completion Date:** 2026-07-01
**Phases Completed:** All
**Work Deferred:** In-game verification and optional ginger investigation.

**Accomplishments:**
- Added the `Pseudonymous.KentuckyKimchi`, `Pseudonymous.KentuckyKimchiClayJar`, and `Pseudonymous.KentuckyKimchiGlazedJar` food items for B42.
- Added the `MakeKentuckyKimchi`, `MakeClayJarKentuckyKimchi`, and `MakeGlazedJarKentuckyKimchi` B42 craft recipes.
- Added `versionMin=42.0` to mod metadata.
- Replaced the copied template README with PseudoKimchi-specific documentation.
- Resolved the stale-happiness question in favor of the documented fallback.

**Metrics:**
- Files modified: 3
- Files added: 2

**Lessons / Notes:**
B42 exposes `UnhappyChange` as a single static item value. Negative values are the happiness benefit behavior used by vanilla foods; no stale-only happiness field was found in item scripts or `Food` age handling.