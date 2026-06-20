# DevCycle 001: Stand up PseudoSaltWell for 42.19.0

**Status:** Paused — see "Where this left off" below
**Start Date:** 2026-06-19
**Target Completion:** TBD
**Focus:** Incrementally rebuild the saltwater well mod in this directory, porting the working 42.11.0 implementation from `mymods/PseudoSaltWell/42` forward, verifying every ported file against current `media/` lua before it's trusted.

## Where this left off (2026-06-19)

Phases 1-5 are all **Work Complete** (porting done). The cycle is paused mid-investigation of an **open bug**, not blocked on implementation work. Pick up by reading the "Open investigation: campfire build error" entry under Phase 4 (below), which ends with a requested bisection test the user hasn't run yet:
- **Test A:** enable only `42/media/scripts/` (items + recipes), disable/remove `42/media/lua/` entirely, retry the build-cheat campfire placement.
- **Test B:** enable only `42/media/lua/`, disable/remove `42/media/scripts/` entirely, retry the same test.

Confirmed so far: campfire build-cheat is clean with the mod fully disabled, and logs a Java overload-resolution error (`ItemContainer.new(...)`, all-vanilla call site with hardcoded arguments) when the mod is enabled — real correlation, mechanism not yet identified. The translation file (`ContextMenu.json`) has been ruled out as the cause. Phase 6 (full in-game verification pass) has not been started and shouldn't be until this is resolved, since it would just re-surface the same unexplained error.

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

**Status:** Work Complete

- [x] Ported `ISFillPotFromWell.lua` and `ISFillKettleFromWell.lua` (shared/TimedActions) — both extend `ISBaseTimedAction`, take `(character, well, container, time)`, remove the empty container and add a saltwater item. Verbatim port; `getEmitter():playSound(...)` and `faceThisObject(...)` confirmed live and unchanged (e.g. `media/lua/shared/Camping/TimedActions/ISRemoveCampfireAction.lua`).
- [x] Ported `WellFillMenu.lua` (client) — hooks `Events.OnFillWorldObjectContextMenu`, finds the well by `obj:getName() == "SaltwaterWell"`, builds pot/kettle submenus from inventory contents.
- [x] **Fix applied:** `WellFillMenu.lua`'s two raw literal menu strings now use `getText("ContextMenu_FillPotWithSaltwater")` / `getText("ContextMenu_FillKettleWithSaltwater")`. Also fixed the same gap left over in `LocationBasedHoleMenu.lua` from Phase 2 (`"Dig a Hole"` → `getText("ContextMenu_DigAHole")`), as planned.
- [x] **Translation file format resolved:** confirmed *zero* `.txt` UI string-table files exist anywhere under `media/lua/shared/Translate` (only `credits.txt`/`language.txt` metadata remain as `.txt`); all UI strings, including `ContextMenu`, are `.json` now (e.g. `media/lua/shared/Translate/EN/ContextMenu.json`). Added `42/media/lua/shared/Translate/EN/ContextMenu.json` with the three new keys, in JSON form, not the old `.txt` key=value form originally planned.
- [x] **Verified against `media/`:** `Base.Pot`/`Base.Kettle` full item IDs still resolve (`Pot` at `media/scripts/generated/items/normal.txt:4001`); `Events.OnFillWorldObjectContextMenu.Add`, `ISContextMenu:getNew`, and `context:addSubMenu` all confirmed live and unchanged (e.g. `media/lua/shared/Camping/ISCampingMenu.lua:171-172`).

**Technical Notes:**
Functionally this phase was low-risk — it's the same item-add/item-remove pattern used throughout the mod. The only real work was the translation-key fix, which also surfaced a format change (`.txt` → `.json`) that the original plan hadn't anticipated. Not yet covered by a manual test — `WellFillMenu` can't be exercised until Phase 4 lands the saltwater items it depends on (`PseudoSaltWellB42.SaltwaterPot`/`SaltwaterKettle`), so testing is deferred to a later smoke-test pass rather than added as its own sub-phase now.

### Phase 4: Port items and container-emptying

**Status:** Work Complete

- [x] Ported `PseudoSaltWellItems.txt` (scripts/items) — `SaltwaterPot`, `SaltPot`, `SaltwaterKettle`, `SaltKettle`, all under module `PseudoSaltWellB42`, kept unchanged per the Decisions above (no rename, no `FluidContainer` rework).
- [x] Ported `ISEmptySaltwaterContainer.lua` (shared/TimedActions) and `EmptySaltwaterMenu.lua` (client) verbatim — manual remove/add pattern, explicitly chosen because `ReplaceOnUseOn` + vanilla "Pour on Ground" was found to drop items (per the in-code comment and Part 5 plan notes).
- [x] **Fix applied (same category as Phase 3):** `EmptySaltwaterMenu.lua`'s `"Empty Container"` literal switched to `getText("ContextMenu_EmptyContainer")`; key added to `ContextMenu.json` alongside the Phase 3 keys.
- [x] **Verified against `media/`:** `ReplaceOnUse`, `ReplaceOnCooked`, `IsCookable`, `MinutesToCook`, `MinutesToBurn`, `CookingSound` all confirmed live with the same field names — closest vanilla analogue is `SugarBeetPulpPot` (`media/scripts/generated/items/food.txt:548-574`), a vanilla "pot with cooked contents, replaced on use" item using the identical pattern. `ReplaceOnCooked` specifically confirmed live at `food.txt:2132,2816,10914`. `Events.OnFillInventoryObjectContextMenu.Add` confirmed live (`media/lua/client/Context/ISContextManager.lua:42`). The `instanceof(item, "InventoryItem")` / `item.items[1]` fallback pattern in `EmptySaltwaterMenu.createMenu` confirmed live and identical in multiple current files (e.g. `media/lua/shared/Fluids/ISFluidUtil.lua:36`).

**Technical Notes:**
Per the Decisions section above, these items still model "saltwater in a pot" via distinct item types and manual inventory swaps rather than the engine's native `FluidContainer`/`FluidType` system that current vanilla `Pot`/`Kettle` actually use — confirmed intentional for this cycle, not a gap. No vanilla item in current scripts uses `component FluidContainer` together with `ReplaceOnUse`/`ReplaceOnCooked`-style item-swap fields, so this mod's approach and vanilla's fluid approach are simply two different, non-overlapping models — nothing here needed reconciling with `FluidContainer`, since this mod doesn't touch it.

**Test Run 5 (2026-06-19): Two real item-script bugs found via in-game crash, fixed.**

User tried to open the debug Cheat Item Viewer (to spawn an empty pot for testing) and got a Lua crash, logged to `doc/ideas/console.txt`. Stack trace: `Lua(Vanilla).initList(ISItemsListTable.lua:290)` → `java.lang.RuntimeException: attempted index: toString of non-table: null`. The crashing line is vanilla code (`media/lua/client/ISUI/AdminPanel/ISItemsListTable.lua:290`): `v:getItemType():toString()`, called on every loaded item while building the viewer's category list.

Root cause, confirmed by checking current vanilla item scripts:
1. **`Type = Food,` is obsolete.** Checked all 722 food items in `media/scripts/generated/items/food.txt` — zero use the old `Type = ` field; all use `ItemType = base:food,` instead (e.g. `food.txt:6`, `food.txt:5-6` for `PanFriedVegetablesForged`). Our four items (`SaltwaterPot`, `SaltPot`, `SaltwaterKettle`, `SaltKettle`) only set `Type = Food,`, never `ItemType`, so `getItemType()` returned `nil` for them and the viewer's `:toString()` call on that `nil` crashed.
2. **Tag values were also wrong format.** Vanilla `Pot` uses `Tags = base:cookable;base:hasmetal;base:smeltablesteelmedium,` and `Kettle` uses `Tags = base:cookable;base:hasmetal;base:smeltableironsmall,` (`media/scripts/generated/items/normal.txt:4017,4120`) — namespaced (`base:`) and lowercase. Our items had `Tags = Cookable;HasMetal;SmeltableIronMedium,` (Pot-based items) / `...SmeltableIronSmall,` (Kettle-based) — wrong casing, missing the `base:` prefix, and the Pot-based items even named the wrong metal (vanilla `Pot` smelts as steel, not iron).

**Fix applied:** replaced `Type = Food,` with `ItemType = base:food,` in all four items, and corrected all four `Tags` lines to the namespaced/lowercase vanilla form matching the underlying container type (steel-medium for the Pot-based items, iron-small for the Kettle-based items).

Checked the rest of the supplied `console.txt`: the mod loaded cleanly (`loading PseudoSaltWell`, translation override accepted) with no script parse errors at load time — the bug only manifested when the debug item viewer scanned all items, not during normal mod loading. No other PseudoSaltWell-related entries found in the log. Re-test of the cheat item viewer needed to confirm the fix.

**Open investigation: campfire build error, possibly caused by this mod (2026-06-19).**

User built a campfire (successfully, via the build cheat) and a Lua error was logged to console during/around that build — full stack trace entirely in vanilla files (`SCampfireGlobalObject.lua:103`, `buildRecipeCode.lua:520`, `ISBuildIsoEntity.lua`, `ISBuildAction.lua`, with `BuildCheat is active` logged just before it). It was not a crash — the build completed despite the logged error.

User then reported building a campfire successfully with `PseudoSaltWell` disabled. This was initially (and wrongly) recorded here as "the same error reproduces with the mod disabled, therefore unrelated." That was a misreading: the user was reporting a clean, successful build with no error, not a reproduction of the error. Corrected per the user's explicit clarification — the evidence as it actually stands is that the error has only been observed with the mod *enabled*, which points toward the mod as the cause rather than away from it. A 100%-vanilla stack trace does not rule out the mod, since a mod can corrupt shared state vanilla code depends on without ever appearing in the trace itself.

**Leading hypothesis:** this mod's `42/media/lua/shared/Translate/EN/ContextMenu.json` (added in Phase 3, extended in Phase 4) contains only this mod's own 3-4 keys (`ContextMenu_DigAHole`, `ContextMenu_FillPotWithSaltwater`, `ContextMenu_FillKettleWithSaltwater`, `ContextMenu_EmptyContainer`) — it is not a copy of the full vanilla `ContextMenu.json`. The mod-load log explicitly says `mod "PseudoSaltWell" overrides media/lua/shared/translate/en/contextmenu.json`. If PZ's translation loader treats same-path files as a full replace rather than merging keys, this file would wipe out every other vanilla `ContextMenu_*` string while the mod is enabled — including whatever text the camping/campfire build UI looks up — which could plausibly cascade into the build-completion error seen. This can't be confirmed from `media/lua` alone, since the actual merge-vs-replace behavior is implemented in the Java engine, which is out of scope to inspect here.

**Diagnostic instructions given to the user:** remove only `ContextMenu.json` from the mod (leave every other file enabled) and attempt the same campfire build with the cheat again.
- If the error disappears with only that file removed: confirms the translation-file-replace hypothesis. Fix would be to ship a translation file that doesn't collide with the vanilla file at that exact path (e.g. only add keys without occupying the same `ContextMenu` namespace file, or include the full vanilla key set so nothing is lost — needs confirming which approach the loader actually supports before deciding).
- If the error persists with that file removed: hypothesis is wrong, and the cause lies elsewhere in the mod (the next files to check would be `LocationBasedHoleMenu.lua`, `WellFillMenu.lua`, and `EmptySaltwaterMenu.lua`, since they're the only other files that hook global `Events.*` handlers that run on every relevant menu-fill, even though none of them appear to touch campfire/build-related code paths on inspection).

**Result: hypothesis disproven (2026-06-19).** User removed `ContextMenu.json` only, left the rest of the mod enabled, and the error still occurred. The translation-file-replace hypothesis is ruled out.

**Re-examined the actual vanilla call site to find a better hypothesis.** The failing call is:
```lua
-- buildRecipeCode.lua:520
luaObject:addContainer()
-- SCampfireGlobalObject.lua:103
container = ItemContainer.new("campfire", square, isoObject, 1, 1)
```
The logged error (`No implementation found for function: new(String, IsoGridSquare, IsoThumpable, Double, Double)`) is a Java-overload-resolution failure on this exact call. The `1, 1` arguments are hardcoded literals in vanilla's own script — not influenced by any item, recipe, menu, or other content this mod ships. There is no value under this mod's control anywhere in this call chain. This is a stronger basis for ruling the mod out than the earlier "stack trace is all vanilla" reasoning (which was rightly not accepted as sufficient), since this time the actual *inputs* to the failing call are vanilla-fixed, not just the code executing them. Most plausible explanation: a Kahlua Lua-to-Java numeric binding issue (Lua number literals bind as `Double`, and whatever overload of `ItemContainer.new` the engine now expects may want `int`), independent of any mod.

**Correlation confirmed, no further repeat testing needed (2026-06-19).** The "disable the entire mod and retry" step requested above had already been done — it's the same test the user reported earlier (campfire built cleanly with `PseudoSaltWell` fully disabled), which is what the original misreading in this log was about. So the standing evidence is: clean build with the mod fully disabled, error logged with the mod enabled (translation file specifically ruled out as the cause). That's a real, confirmed correlation, not a coincidence needing re-verification.

**Next diagnostic step: bisect which half of the mod is responsible.** Since the mechanism still isn't identified (the failing vanilla call's arguments are hardcoded literals, so the cause has to be some indirect shared-state effect, not a direct value our mod controls), and the game can't be run from here to test directly, the plan is to narrow it by enabling half the mod at a time and repeating the build-cheat campfire test:
- **Test A:** enable only `42/media/scripts/` (items + recipes), disable/remove `42/media/lua/` entirely.
- **Test B:** enable only `42/media/lua/` (digging/filling/emptying code and menus), disable/remove `42/media/scripts/` entirely.

Whichever half reproduces the error narrows the next round of investigation to that half's files. Awaiting results.

This phase's items/recipes work (Type/ItemType, Tags fixes) stands as Work Complete regardless of this investigation's outcome — this is a separate, newly-discovered issue, not a defect in the items themselves.

### Phase 5: Port salt-extraction recipes

**Status:** Work Complete

- [x] Ported `PseudoSaltWellRecipes.txt` (scripts/recipes) — `craftRecipe Get Salt From Pot` / `Get Salt From Kettle`, using `timedAction = OpenTinCan`, `inputs`/`outputs` blocks.
- [x] **Fix applied:** the source file used lowercase `tags = InHandCraft;CanBeDoneInDark`. Checked every recipe file under `media/scripts/generated/recipes/` (42 files, 623 occurrences total) — every single one uses `Tags =` (capital T); zero use lowercase `tags =`. Changed to `Tags =` in both recipes for consistency with the confirmed-live convention.
- [x] **Verified against `media/`:** `timedAction = OpenTinCan` confirmed live and used the same way in `media/scripts/generated/recipes/recipes_cannedFood.txt:6,23`; `category = Cooking` (lowercase) confirmed correct as written (`recipes_cannedFood.txt:9` etc.); `Base.Salt` confirmed present in `media/scripts/generated/items/food.txt`. `inputs`/`outputs` block structure matches `recipes_tailoring.txt` and `recipes_cannedFood.txt` exactly.

**Technical Notes:**
Low risk overall, syntax matched a confirmed-current example almost exactly — the one real finding was the `tags`/`Tags` casing, which is an easy thing to miss since PZ's script parser may tolerate it silently in some contexts; fixed it anyway since the live convention is unanimous.

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
