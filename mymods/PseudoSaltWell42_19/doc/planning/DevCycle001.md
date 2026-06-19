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

**Status:** Planning

- [ ] Confirm `PseudoSaltWell42_19/PseudoSaltWell/42/mod.info` matches the existing `mymods/PseudoSaltWell/42/mod.info` (id, pack, tiledef) — already present and identical, just verify.
- [ ] Confirm `PseudoSaltWell42_19/PseudoSaltWell/common/media/` already has `pseudoed_salt_01.tiles`, `texturepacks/pseudoed_salt_01.pack`, `textures/Item_MEATSaltedFishFillet.png` — already present, just verify they're the same assets (no Part6 custom-tile rework needed; we're reusing the existing `pseudoed_01_6` well sprite, not building new graphics).
- [ ] Create the empty `42/media/lua/{client,server/BuildingObjects,shared/TimedActions}` and `42/media/scripts/{items,recipes}` directories to receive ported files.

**Technical Notes:**
No new design here — this phase only confirms the skeleton already dropped into `PseudoSaltWell42_19/PseudoSaltWell/` is consistent with the source mod before any code is copied in.

### Phase 2: Port location-based well/hole digging

**Status:** Planning

- [ ] Port `SaltwaterLocationDetector.lua` (shared) — defines `isSaltwaterLocation(x, y)` against a coordinate table. No engine API surface; safe to copy as-is.
- [ ] Port `ISLocationBasedHole.lua` (server/BuildingObjects) — derives `ISBuildingObject`, uses `IsoThumpable.new`, `BuildingHelper.getShovelAnim`, `square:getFloor()`, `square:isInARoom()`, `luautils.stringStarts`, `sq:disableErosion()` + `sendServerCommand('erosion', 'disableForSquare', ...)`.
- [ ] Port `LocationBasedHoleMenu.lua` (client) — hooks `Events.OnFillWorldObjectContextMenu`, looks for an existing "Shovel" submenu via `getText("ContextMenu_Shovel")` and a `DigGrave`-tagged item.
- [ ] **Verify against `media/`:** grep current `media/lua` for `ISBuildingObject`, `IsoThumpable`, `BuildingHelper.getShovelAnim`, `disableErosion`, and `ContextMenu_Shovel` usage to confirm none of these have been renamed or changed signature since 42.11. Do not assume — confirm each one has a live match before treating the port as done.

**Technical Notes:**
This is the highest-risk phase: it's the only part of the mod that overrides engine-level building/placement behavior (ghost-tile rendering, erosion suppression, room/floor validation) rather than just adding items or context-menu options. If any of the verified APIs have changed shape, this phase will need rework before Phase 3 can be meaningfully tested in-game.

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

- All "verify against `media/`" steps must be done by reading the actual current `media/lua` and `media/scripts` files in this repo — per project ground rules, only the `media/` lua files are available for this check, not the full game install. If a given API can't be located in `media/`, treat it as unverified, not as confirmed-safe.
- Phase 2 (building/placement) carries the most risk of silent breakage, since `ISBuildingObject`/`IsoThumpable` placement code is the part of the mod most exposed to engine internals rather than stable scripting APIs.
- `doc/ideas/claude_PseudoSaltWellOldVersionAnalysis.md` analyzed the *original* B41 mod, not the 42.11 codebase being ported here — most of its findings (broken `buildMiscMenu` monkeypatch, legacy `recipe{}` syntax, debug `print()` spam) do not apply to this codebase, which already uses the modern digging/context-menu/`craftRecipe` patterns. Only its fluid-modeling question carries forward (Open Question 1).

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*
