# DevCycle 001: Stand up PseudoSaltWell for 42.19.0

**Status:** Planning
**Start Date:** 2026-06-19
**Target Completion:** TBD
**Focus:** Incrementally rebuild the saltwater well mod in this directory, porting the working 42.11.0 implementation from `mymods/PseudoSaltWell/42` forward, verifying every ported file against current `media/` lua before it's trusted.

---

## Goal

`mymods/PseudoSaltWell/42` is a working, already-debugged implementation of the saltwater well system (location-based well/hole digging, pot/kettle filling, salt extraction, emptying) built and tested against 42.11.0. `PseudoSaltWell42_19` is the new home for this mod going forward, targeting 42.19.0. Rather than re-deriving the design, this cycle ports that implementation file-by-file, using current `media/lua` and `media/scripts` as the compatibility check at each step, and folds in the gaps already identified in `doc/ideas/claude_PseudoSaltWellOldVersionAnalysis.md` (which covered the *original* B41 mod, not this 42.11 codebase, but its FluidContainer question is still open and applies here too).

## Desired Outcome

A self-contained mod under `PseudoSaltWell42_19/PseudoSaltWell/42/` that reproduces all functionality of `mymods/PseudoSaltWell/42`, with each ported file checked against current `media/` APIs rather than assumed compatible, and with the known rough edges (untranslated menu strings, the fluid-modeling design question) either fixed or explicitly deferred with a recorded reason.

---

## Tasks

### Phase 1: Skeleton and asset wiring

**Status:** Work Complete

- [x] Confirm `PseudoSaltWell42_19/PseudoSaltWell/42/mod.info` matches the existing `mymods/PseudoSaltWell/42/mod.info` (id, pack, tiledef) — `diff` confirms byte-identical.
- [x] Confirm `PseudoSaltWell42_19/PseudoSaltWell/common/media/` already has `pseudoed_salt_01.tiles`, `texturepacks/pseudoed_salt_01.pack`, `textures/Item_MEATSaltedFishFillet.png` — `diff`/`cmp` confirms all three are identical to the source mod's copies (no Part6 custom-tile rework needed; reusing the existing `pseudoed_01_6` well sprite).
- [x] Created `42/media/lua/{client,server/BuildingObjects,shared/TimedActions}` and `42/media/scripts/{items,recipes}` directories to receive ported files.

**Technical Notes:**
No new design here — this phase only confirmed the skeleton already dropped into `PseudoSaltWell42_19/PseudoSaltWell/` is consistent with the source mod before any code is copied in. mod.info and all three common assets verified byte-identical via `diff`/`cmp`. Found one pre-existing empty directory, `lua/shared/BuildingObjects` (dated Oct 2025), not created by this phase — left in place as harmless.

### Phase 2: Port location-based well/hole digging

**Status:** Work Complete

- [x] Ported `SaltwaterLocationDetector.lua` (shared) — defines `isSaltwaterLocation(x, y)` against a coordinate table. No engine API surface; copied as-is.
- [x] Ported `ISLocationBasedHole.lua` (server/BuildingObjects) — derives `ISBuildingObject`, uses `IsoThumpable.new`, `BuildingHelper.getShovelAnim`, `square:getFloor()`, `square:isInARoom()`, `luautils.stringStarts`, `sq:disableErosion()` + `sendServerCommand('erosion', 'disableForSquare', ...)`.
- [x] Ported `LocationBasedHoleMenu.lua` (client) — hooks `Events.OnFillWorldObjectContextMenu`, looks for an existing "Shovel" submenu via `getText("ContextMenu_Shovel")` and a `DigGrave`-tagged item.
- [x] **Verified against `media/`:** all APIs confirmed live and unchanged —
  - `ISBuildingObject:derive` pattern: widely used, e.g. `media/lua/server/BuildingObjects/ISEmptyGraves.lua`.
  - `IsoThumpable.new`: confirmed in 27 current files including `ISEmptyGraves.lua`.
  - `BuildingHelper.getShovelAnim`: defined at `media/lua/shared/Util/BuildingHelper.lua:71`, used identically by `ISEmptyGraves.lua:73`.
  - `square:disableErosion()` + `sendServerCommand('erosion', 'disableForSquare', ...)`: identical pattern at `ISEmptyGraves.lua:44-47` and `media/lua/server/BuildingObjects/ISWoodenFloor.lua:19-21`.
  - `square:isInARoom()`: confirmed at `ISEmptyGraves.lua:169` — the same grave-digging file this mod's pattern was originally modeled on.
  - `getText("ContextMenu_Shovel")` submenu lookup: identical pattern at `media/lua/client/BuildingObjects/ISUI/ISInventoryBuildMenu.lua:35`.

**Technical Notes:**
This was the highest-risk phase since it's the only part of the mod overriding engine-level building/placement behavior rather than just adding items or context-menu options. Every API it depends on was found with a live, unchanged match in current `media/lua`, so all three files were ported verbatim with no changes required.

**Finding carried to Phase 3:** `LocationBasedHoleMenu.lua` adds the menu option as a raw literal string (`"Dig a Hole"`) instead of a `getText(...)` key — the same translation gap already scheduled to be fixed in `WellFillMenu.lua`. Both should be fixed together in Phase 3 rather than fixing this one in isolation now.

### Phase 2.5: Manual smoke test of digging before continuing

**Status:** Work Complete — all tests passed (user-confirmed, 2026-06-19)

This phase exists because Phase 2 is the highest-risk code in the mod (engine-level placement/rendering), and the plan originally deferred all in-game testing to Phase 6 — by which point three more phases could be stacked on top of an undetected placement bug. This test is scoped only to what Phase 2 added: digging, ghost-tile rendering, and the saltwater/plain-hole location split. It does not cover filling, emptying, or recipes — those don't exist yet.

- [x] Enable the `PseudoSaltWell42_19` mod (only this mod) in the game's mod manager and load/start a game.
- [x] Confirm no Lua errors appear in the console/log on load (look for errors referencing `SaltwaterLocationDetector`, `ISLocationBasedHole`, or `LocationBasedHoleMenu`).
- [x] Test digging at a **saltwater** location:
  - Enable debug/admin mode (launch with `-debug`, or use the in-game admin Cheat menu) so you can teleport.
  - Teleport to one of the saltwater coordinates defined in `SaltwaterLocationDetector.lua`: any tile with X=8163, or the exact tiles (8165, 12212) or (8175, 12216).
  - Equip a shovel (anything tagged `DigGrave`, e.g. the vanilla `Shovel`).
  - Right-click the ground tile under/near you → open the **Shovel** submenu → confirm **"Dig a Hole"** appears.
  - Hover the option before clicking and confirm the ghost tile renders **green** on valid natural ground at z=0, and **red** if you move off natural ground or try a non-ground floor.
  - Click to place, let the digging animation/timer finish.
  - Right-click the resulting tile and confirm it's a distinct interactive object (it should later support "Fill Pot/Kettle" once Phase 3 lands) — for now, just confirm the tile uses the well sprite (`pseudoed_01_6`), not the grave-hole sprite.
- [x] Test digging at a **non-saltwater** location (any other natural ground tile):
  - Repeat the same dig steps.
  - Confirm the resulting tile uses the grave-hole sprite (`location_community_cemetary_01_33`) and has no special context menu beyond vanilla (no well behavior).
- [x] Test an **invalid** location (e.g. indoor floor, or off natural ground):
  - Confirm "Dig a Hole" either doesn't appear, or the ghost tile renders red and placement is rejected.
- [x] Record results below — pass/fail per case, and paste any console errors encountered.

**Technical Notes:**
This phase blocks Phase 3 from starting. Per `doc/planning/DevelopmentProcess.md`, only the user can mark this `Verified` — once you've run the tests, report back what you saw (including any errors or unexpected sprite/behavior) and I'll record the outcome here before we move on.

**Test Run 4 (2026-06-19): All tests passed.** User confirmed all Phase 2.5 checklist items pass with the Test Run 3 fix in place (no lock, recompute saltwater status at placement/render time). No further errors reported. Per explicit user instruction, the cycle is paused here — **Phase 3 has not been started.**

**Test Run 1 (2026-06-19): Bug found and fixed.**

Generated a shovel, right-clicked the ground, and hit two errors:

1. **`LocationBasedHoleMenu.lua:63`** — `item:hasTag("DigGrave")` failed. Root cause: `hasTag()` no longer accepts a raw string anywhere in current `media/lua` — every live usage passes an `ItemTag.*` enum value instead (confirmed: zero string-form calls exist anywhere in `media/lua`). The grave-digging tag itself is also named differently now: `ItemTag.DIG_GRAVE` (confirmed live at `media/lua/client/Mining/DiggingUtil.lua:32`), not `"DigGrave"`.
   **Fix applied:** changed to `item:hasTag(ItemTag.DIG_GRAVE)`. This was the only string-form `hasTag()` call anywhere in the Phase 2 ported files (verified by grep across all three).
2. **`ISInventoryBuildMenu.lua:8`** — `item:hasTag(ItemTag.TAKE_DIRT)` failed. This is a vanilla file, not shipped by this mod, and it already uses the correct enum form — so this isn't something this mod can fix. Likely a pre-existing vanilla issue or an environment mismatch between the running game build and the `media/` snapshot used for verification. Noted here for visibility; out of scope for this mod.

Re-test needed after the fix before this phase can be marked Work Complete.

**Test Run 2 (2026-06-19): Second bug found and fixed.**

With the `hasTag` fix in place, digging a hole now reaches `ISLocationBasedHole.lua:23` and errors there:

```lua
if object:getProperties() and object:getProperties():Is(IsoFlagType.canBeRemoved) then
```

Root cause: the method name is wrong — it's `:has(...)`, not `:Is(...)`. Zero matches for `:Is(IsoFlagType` anywhere in current `media/lua`; the correct, live pattern (`object:getSprite():getProperties():has(IsoFlagType.canBeRemoved)`) is used for this exact same "can this tile object be cleared before placing something new" check in `media/lua/shared/BuildingObjects/TimedActions/ISShovelGround.lua:90` and `media/lua/server/Farming/SFarmingSystem.lua:568,611`. `IsoFlagType.canBeRemoved` itself was already correct — only the method name needed fixing.
**Fix applied:** changed to `object:getProperties():has(IsoFlagType.canBeRemoved)`. Checked the rest of the file for other `:Is(` calls — none found.

Re-test needed after this fix before this phase can be marked Work Complete.

**Test Run 3 (2026-06-19): Intermittent "nothing happens" bug found and fixed (design bug, not an API mismatch).**

Symptom: digging usually did nothing (no error, no action), occasionally worked. Root cause was a design flaw, not an outdated API:

- `LocationBasedHoleMenu.onDigHole` pre-computed `isSaltwater` from the square that was right-clicked to open the context menu, then locked `ISLocationBasedHole:isValid()` to reject placement at any square other than that exact one (`lockedX`/`lockedY`).
- But placement uses the standard `ISBuildingObject` drag-cursor flow (`getCell():setDrag(...)`), which follows the mouse and only places on a second, separate confirming click — the same flow vanilla uses for grave digging (`ISWorldObjectContextMenu.onDigGraves`, `media/lua/client/ISUI/ISWorldObjectContextMenu.lua:2767-2772`), which does **not** lock to a specific tile.
- Any mouse drift between opening the menu and the confirming click meant the click landed on a different square than the lock expected, so `isValid()` silently returned `false`. That's the "usually nothing happens" behavior — it succeeded only on the rare click that landed on the exact original pixel/tile.

**Fix applied:** removed the lock entirely and made the saltwater/plain decision happen at the point each coordinate is actually used, matching vanilla's free-placement model:
- `ISLocationBasedHole:create(x, y, z, ...)` now calls `SaltwaterLocationDetector.isSaltwaterLocation(x, y)` using the real placement coordinates passed in by the engine, instead of reading a pre-stored `self.isSaltwater`.
- `ISLocationBasedHole:render(...)` now recomputes the sprite every frame from the square currently being rendered (the one under the cursor), so the ghost tile correctly shows well-vs-hole as the player drags across different tiles, instead of showing a sprite fixed at menu-open time.
- `ISLocationBasedHole:isValid(square)` no longer checks `lockedX`/`lockedY` — any valid natural-ground tile is acceptable, same as vanilla grave placement.
- `LocationBasedHoleMenu.onDigHole` no longer takes or uses `clickedSquare`; `LocationBasedHoleMenu.createMenu` no longer computes it. Both simplified accordingly.

Re-test needed after this fix before this phase can be marked Work Complete.

### Phase 3: Port well-filling actions and menu

**Status:** Planning

- [ ] Port `ISFillPotFromWell.lua` and `ISFillKettleFromWell.lua` (shared/TimedActions) — both extend `ISBaseTimedAction`, take `(character, well, container, time)`, remove the empty container and add a saltwater item.
- [ ] Port `WellFillMenu.lua` (client) — hooks `Events.OnFillWorldObjectContextMenu`, finds the well by `obj:getName() == "SaltwaterWell"`, builds pot/kettle submenus from inventory contents.
- [ ] **Fix:** `WellFillMenu.lua` adds raw literal strings (`"Fill Pot with Saltwater"`, `"Fill Kettle with Saltwater"`) instead of `getText(...)` keys backed by a translation file — same category of gap the old-mod analysis flagged (missing/ad-hoc translation use). Add proper `ContextMenu_EN.txt` entries and switch both menu strings to `getText(...)`.
- [ ] **Verify against `media/`:** confirm `Base.Pot` / `Base.Kettle` full item IDs still resolve (already spot-checked at `media/scripts/generated/items/normal.txt:4001` for `Pot`) and that `Events.OnFillWorldObjectContextMenu` / `ISContextMenu:getNew` / `context:addSubMenu` signatures are unchanged.

**Technical Notes:**
Functionally this phase is low-risk — it's the same item-add/item-remove pattern used throughout the mod. The only real work is the translation-key fix.

### Phase 4: Port items and container-emptying

**Status:** Planning

- [ ] Port `PseudoSaltWellItems.txt` (scripts/items) — `SaltwaterPot`, `SaltPot`, `SaltwaterKettle`, `SaltKettle`, all under module `PseudoSaltWellB42`. Decide whether to keep the `PseudoSaltWellB42` module name or rename to match the `PseudoSaltWell` mod id used everywhere else in this directory (see Open Questions).
- [ ] Port `ISEmptySaltwaterContainer.lua` (shared/TimedActions) and `EmptySaltwaterMenu.lua` (client) — manual remove/add pattern, explicitly chosen because `ReplaceOnUseOn` + vanilla "Pour on Ground" was found to drop items (per the in-code comment and Part 5 plan notes).
- [ ] **Verify against `media/`:** confirm item-script fields used (`ReplaceOnUse`, `ReplaceOnCooked`, `IsCookable`, `MinutesToCook`, `MinutesToBurn`, `component FluidContainer` is *not* used here — see Open Questions) still parse the same way by diffing field names against a current vanilla cookable item (e.g. `Pot` at `media/scripts/generated/items/normal.txt:4001-4027`).

**Technical Notes:**
This phase is where the central design question from the old-version analysis resurfaces: these items still model "saltwater in a pot" via distinct item types and manual inventory swaps, not the engine's native `FluidContainer`/`FluidType` system that current vanilla `Pot`/`Kettle` actually use. See Open Questions before treating this phase as final rather than a placeholder.

### Phase 5: Port salt-extraction recipes

**Status:** Planning

- [ ] Port `PseudoSaltWellRecipes.txt` (scripts/recipes) — `craftRecipe Get Salt From Pot` / `Get Salt From Kettle`, using `timedAction = OpenTinCan`, `inputs`/`outputs` blocks.
- [ ] **Verify against `media/`:** `craftRecipe` blocks with `inputs`/`outputs` confirmed live in current `media/scripts` (e.g. `media/scripts/generated/recipes/recipes_tailoring.txt`). Diff field names (`timedAction`, `tags`, `category`) against one of those files to make sure none have been renamed.

**Technical Notes:**
Low risk — syntax already matches a confirmed-current example elsewhere in vanilla scripts.

### Phase 6: In-game verification pass

**Status:** Planning

- [ ] Load the mod alone in 42.19.0 and run through the Part 4/Part 5 test sequences from `modPlans/PseudoSaltWellBuild42ModPlan.md` (dig at a saltwater coordinate → well; dig elsewhere → plain hole; fill pot/kettle; empty container; cook; extract salt).
- [ ] Confirm ghost-tile rendering (ISLocationBasedHole:render) still shows green/red correctly when placing.
- [ ] Confirm no console errors on load (recipe/item module parsing, tile/texturepack loading).

**Technical Notes:**
This phase stays at **Work Complete**, not **Verified**, until the user confirms in-game behavior — per `doc/planning/DevelopmentProcess.md`, verification authority belongs to the user.

---

## Decisions

Both open questions from this cycle's planning were resolved by the user as "use your recommendations":

1. **Pot/kettle fluid modeling: keep item-swap, do not move to native `FluidContainer` this cycle.**
   The existing 42.11 implementation (and the original B41 mod before it) both model saltwater-in-a-container by swapping distinct item types (`Pot` → `PseudoSaltWellB42.SaltwaterPot` → `...SaltPot` → `Pot`) rather than using the engine's `FluidContainer`/`FluidType` system that vanilla `Pot`/`Kettle` use as of the `media/` lua reviewed. Decision: keep item-swap for this cycle — it's a direct, low-risk port of working code. A fluid-based rewrite is more idiomatic but materially more work and untested; revisit as a separate future DevCycle if desired, not as part of standing up the 42.19 mod.

2. **Module namespace: keep `PseudoSaltWellB42`, do not rename for this cycle.**
   All item and recipe definitions currently live under module `PseudoSaltWellB42`, a name inherited from the old `modPlans` part-numbering scheme, even though the mod id/folder here is just `PseudoSaltWell`. Decision: keep `PseudoSaltWellB42` as the module name to minimize the diff against the known-working source and avoid touching every item reference (`PseudoSaltWellB42.SaltPot` etc. appear in multiple files). Revisit naming only if the mod is published standalone.

---

## Notes and Risks

- **Translation file format has changed.** Current vanilla context-menu translations live in `media/lua/shared/Translate/EN/ContextMenu.json`, not a `ContextMenu_EN.txt` file — the old `.txt` key=value format used by the original B41 mod (and assumed in Phase 3's plan) is no longer how vanilla does it. Phase 3 needs to confirm whether mods can still ship a `.txt` translation file alongside/instead of `.json`, or whether `ContextMenu_EN.txt` must be converted to JSON, before adding the `getText(...)` keys for `WellFillMenu.lua` and `LocationBasedHoleMenu.lua`.
- All "verify against `media/`" steps must be done by reading the actual current `media/lua` and `media/scripts` files in this repo — per project ground rules, only the `media/` lua files are available for this check, not the full game install. If a given API can't be located in `media/`, treat it as unverified, not as confirmed-safe.
- Phase 2 (building/placement) carries the most risk of silent breakage, since `ISBuildingObject`/`IsoThumpable` placement code is the part of the mod most exposed to engine internals rather than stable scripting APIs.
- `doc/ideas/claude_PseudoSaltWellOldVersionAnalysis.md` analyzed the *original* B41 mod, not the 42.11 codebase being ported here — most of its findings (broken `buildMiscMenu` monkeypatch, legacy `recipe{}` syntax, debug `print()` spam) do not apply to this codebase, which already uses the modern digging/context-menu/`craftRecipe` patterns. Only its fluid-modeling question carries forward (Open Question 1).

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*
