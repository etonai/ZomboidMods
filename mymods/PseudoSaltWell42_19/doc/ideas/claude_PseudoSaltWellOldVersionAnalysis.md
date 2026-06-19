# PseudoSaltWell (Old / B41) Mod Analysis - CLAUDE.md

**Created:** 2026-06-19
**Game version analyzed against:** Project Zomboid 42.11.0 (`media/` in this repo)
**Mod analyzed:** `mymods/PseudoSaltWell_Old` (B41.51-era code, present in two near-duplicate copies: `PseudoSaltWell_Old/media/...` and `PseudoSaltWell_Old/42/media/...`)
**Purpose:** Identify exactly which parts of the old mod are incompatible with current B42 (42.11.0) APIs, using the vanilla code in `media/` as ground truth, to inform the in-progress port (`mymods/PseudoSaltWell` and `modPlans/pseudoSaltWellBuild42MigrationPlan.md`).

## Scope note

`PseudoSaltWell_Old` contains two copies of the same B41 source: a root copy (`media/lua/...`) and a `42/` copy that is identical in logic (header still says "Take Saltwater 41.51") — it was copied into a `42/` folder but never actually updated for B42 APIs. This analysis treats them as one codebase. It is distinct from `mymods/PseudoSaltWell/42`, which is an **already in-progress B42 rewrite** (uses `craftRecipe`, `ISFillPotFromWell`, etc.) — that rewrite is referenced below only to show which obsolete patterns it has already replaced.

## File Inventory (old mod)

```
PseudoSaltWell_Old/
├── mod.info                                   (id=PseudoSaltWell, tiledef=...8724)
├── media/lua/client/TimedActions/PSWTakeSaltwater.lua
├── media/lua/client/TimedActions/PSWTakeSaltwaterKettle.lua
├── media/lua/client/UI/PSWSaltWater.lua
├── media/lua/client/BuildingObjects/ISUI/PMRSBuildMenu.txt   (disabled, .txt not .lua)
├── media/lua/server/PseudoRecipe.lua
├── media/lua/server/SaltedMeats.lua            (dead code, all "OLD"-suffixed)
├── media/lua/shared/Translate/EN/ContextMenu_EN.txt
└── media/scripts/PseudoSaltWell.txt            (items + recipes)
```

## Findings: APIs/patterns in the old mod that are broken or obsolete under 42.11.0

### 1. Pot/Kettle "fluid" simulation via item-swapping is obsolete — B42 has a real FluidContainer system

The old mod fakes "saltwater in a pot" by removing the `Pot` item and adding a distinct `Pseudonymous.SaltwaterPot` item (`PSWTakeSaltwater.lua:42-43`, `PSWTakeSaltwaterKettle.lua:42-43`), then uses `ReplaceOnUse`/`ReplaceOnCooked` item-script fields to chain `SaltwaterPot → SaltPot → Pot` (`PseudoSaltWell.txt:23-24, 60-61`).

B42 vanilla containers (e.g. `Pot`, `Kettle`) now carry a real `component FluidContainer { ... }` (confirmed at `media/scripts/generated/items/normal.txt:4019-4026` for `Pot`: `Capacity = 1.5`, `TransferRate = 5.0`, etc.), backed by `FluidType` and manipulated via `cont:addFluid(...)`, `cont:getFluidContainer()`, `ISFluidContainerMenu` (`media/lua/client/ISUI/ISFluidContainerMenu.lua`). There is no item-identity swap involved — the same physical `Pot` item just holds different fluid contents.

**Consequence:** the old mod's entire pot/kettle/salt item chain (`SaltwaterPot`, `SaltPot`, `SaltwaterKettle`, `SaltKettle`) models something the engine now does natively, and is not how a B42-native saltwater well should work. Note the in-progress port at `mymods/PseudoSaltWell/42` has **not** adopted the FluidContainer approach either — it still creates a distinct `PseudoSaltWellB42.SaltwaterPot` item (`ISFillPotFromWell.lua:52`). This is worth flagging back to the migration plan as a design choice, not an oversight to silently inherit.

### 2. `ISBuildMenu.buildMiscMenu` no longer exists — the build-menu monkeypatch is dead code

`PMRSBuildMenu.txt:25` redefines the global function `ISBuildMenu.buildMiscMenu` wholesale (copy-pasting vanilla cross/stone-pile/picket logic just to splice in a "Saltwater Well" option). A search of the current `media/` tree finds **no** `buildMiscMenu` anywhere — the function doesn't exist in 42.11.0's build-menu code at all (the carpentry submenu system was reworked; see `media/lua/client/BuildingObjects/ISUI/ISInventoryBuildMenu.lua` for the current equivalent). This file is already named `.txt` not `.lua` in the old mod, i.e. it was already disabled/non-functional even under B41 ("Though disabled..." comment at line 3) — but as written it could not load under B42 regardless, since the function it overrides is gone.

**Consequence:** the well-placement flow this file implements cannot be ported by patching the same global; the current B42 build/placement system needs its own integration point (the in-progress port already takes a different approach — see `modPlans/PseudoSaltWellBuild42ModPlan.md` for what it uses instead).

### 3. Context-menu registration pattern still works, but the gating logic is fragile/obsolete

`PSWSaltWater.lua:86-87` hooks `Events.OnPreFillWorldObjectContextMenu` — this event still exists in 42.11.0 (confirmed via grep of `media/lua/client/ISUI/ISWorldObjectContextMenu.lua` and 8 other current files), so the hook point itself survives. However:
- Well detection is done purely by sprite-name string match (`thisObject:getSprite():getName() == "pseudoed_01_6"`, `PSWSaltWater.lua:33,60`) with no object-type or mod-data check, and only inspects `worldobjects[1]` rather than iterating the full `worldobjects` table.
- Container availability is checked with `player:getInventory():getItemCount("Base.Pot", true)` (`PSWSaltWater.lua:23`) which finds *any* pot in inventory, including ones already mid-fluid-chain in B42 terms — this check predates fluid-fullness concepts entirely.

### 4. `recipe { }` block syntax is the old (pre-`craftRecipe`) format

`PseudoSaltWell.txt:253-311` uses the legacy `recipe Name { ingredient, Result:X, OnCreate:fn, ... }` syntax. The already-ported mod (`mymods/PseudoSaltWell/42/media/scripts/recipes/PseudoSaltWellRecipes.txt`) uses the current `craftRecipe Name { timedAction = ..., inputs { item N [Type] } outputs { item N Type } }` block syntax instead, confirming the format has changed for B42 (separate `inputs`/`outputs` blocks, explicit `timedAction`, no single `Result:` field). The old recipe blocks as written will not parse/behave correctly under 42.11.0's recipe loader.

### 5. Debug `print()` calls and dead code throughout

- `PSWSaltWater.lua:20,49` — unconditional `print()` on every context-menu fill (this event fires very frequently; left in, this is a perf/log-spam issue, not just style).
- `PseudoRecipe.lua:13,23,31,45-49,57,65,79-83` — extensive `print()` debugging left in recipe callbacks.
- `SaltedMeats.lua` is entirely dead: every function is suffixed `OLD` and is not referenced by any recipe in `PseudoSaltWell.txt` (the live recipes call `MakeSaltedMeat` / `SaltFishFillet_OnCreate` from `PseudoRecipe.lua`, not the `*OLD` variants here). The file is harmless cruft but should not be carried into a clean port.

### 6. Copy/paste bug: undefined `fuelAmount`

Both `PSWTakeSaltwater:new` (`PSWTakeSaltwater.lua:54`) and `PSWTakeSaltwaterKettle:new` (`PSWTakeSaltwaterKettle.lua:54`) contain `o.fuelAmount = fuelAmount;` where `fuelAmount` is never a parameter or local — it resolves to a global `nil`. This is inert (the field is never read), but is a clear leftover from copying some other timed-action template (likely a fuel/fire source action) and should not be reproduced in the port.

### 7. Hardcoded item types (`Base.Pot`, `Base.Kettle`, `Base.Salt`) — still valid, no change needed here

For completeness: `Base.Pot`, `Base.Kettle`, and `Base.Salt` (e.g. `PseudoRecipe.lua:4-9`, `PSWSaltWater.lua:23,50`) are still valid vanilla item IDs in 42.11.0 (`Pot` confirmed at `media/scripts/generated/items/normal.txt:4001`). These references are not a porting concern by themselves — only the surrounding fluid/recipe/build-menu mechanics around them are obsolete.

## Comparison Summary

| Old mod mechanic | Status under 42.11.0 | Evidence |
|---|---|---|
| Item-swap pot/kettle "fluid" chain | Superseded by native `FluidContainer` | `normal.txt:4019-4026`, `ISFluidContainerMenu.lua` |
| `ISBuildMenu.buildMiscMenu` monkeypatch | Function removed; cannot load | grep of `media/` returns zero matches |
| `Events.OnPreFillWorldObjectContextMenu` hook | Still valid | used in 9 current `media/lua` files |
| `recipe { Result:X, OnCreate:fn }` syntax | Replaced by `craftRecipe { inputs{} outputs{} }` | live contrast with `mymods/PseudoSaltWell/42/.../PseudoSaltWellRecipes.txt` |
| `Base.Pot` / `Base.Kettle` / `Base.Salt` IDs | Unchanged | `normal.txt:4001` |
| Sprite-string well detection (`pseudoed_01_6`) | Mechanically still possible, but fragile/no type-safety | `PSWSaltWater.lua:33,60` |

## Recommendation

The old mod cannot be ported by incremental patching — sections 1, 2, and 4 above are structural (data-model, build-integration, and recipe-syntax level), not surface API renames. This matches the fact that the existing migration effort already restarted the codebase under `PseudoSaltWellB42` namespace with new files (`ISFillPotFromWell.lua`, `craftRecipe` blocks) rather than editing the old files in place — that approach is correct. The one open design question worth raising with the user is item 1: whether the port should keep mimicking fluids via item-swap (as it currently does) or move to a native `FluidContainer`-based saltwater fluid, which would be more idiomatic for 42.11.0 but is a larger change.

---
*This analysis is based on direct comparison of `mymods/PseudoSaltWell_Old` against the vanilla Lua/scripts in `media/` for Project Zomboid 42.11.0, plus the current state of the in-progress port at `mymods/PseudoSaltWell/42`.*
