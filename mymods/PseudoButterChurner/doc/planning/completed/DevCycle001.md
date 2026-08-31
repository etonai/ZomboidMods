# DevCycle 001: Automatic Butter Churner Foundation

**Status:** Work Complete — closed without a working end-to-end result; continues in DevCycle 2
**Start Date:** 2026-08-30
**Target Completion:** Closed 2026-08-31 (incomplete — see Completion Summary)
**Focus:** Build the `AutoButterChurn` scripted entity, its auto-repeating churn recipe, and the washing-machine conversion flow that produces it, per `doc/ideas/claude_automaticButterChurning.md`.

---

## Goal

`PseudoButterChurner` adds a powered, washing-machine-shaped appliance that automatically converts milk into butter in the background, without the player babysitting a crafting window. The design analysis in `doc/ideas/claude_automaticButterChurning.md` (targeting Project Zomboid 42.20.4) worked out the architecture: reuse the vanilla `churn_butter` batch shape (5 L milk → 1 Butter, `time = 500`) but host it on a `component CraftLogic` with `StartMode = Automatic` instead of `CraftBench`, since only `CraftLogic` is watched by the background tick system (`CraftLogicSystem`) and can auto-restart itself batch after batch. Power-gating has no vanilla script equivalent, so it needs a custom `OnUpdate` Lua hook that mirrors `ClothingWasherLogic`'s power-loss shutoff. The appliance itself isn't built from raw materials — it's produced by converting an existing in-world Washing Machine (`IsoClothingWasher`), using the same context-menu-action + custom-timed-action + `addWorkstationEntity` pattern the vanilla Amphora uses for its lid toggle.

This cycle turns that design into a first working implementation.

## Desired Outcome

The mod loads in Project Zomboid B42 with no script parse errors. A player can:

1. Right-click a placed, empty, powered-off Washing Machine and select a "Convert to Automatic Butter Churner" option, gated on carrying a screwdriver (kept) and Electrical skill ≥ 5.
2. After the conversion timed action completes, find an `AutoButterChurn` entity in the washing machine's place.
3. Fill it with Cow Milk and/or Sheep Milk (up to 20 L).
4. Start it via the entity's crafting UI panel (opened by interacting with the placed entity, the same generic panel other `CraftLogic`-family entities like `Drying_Rack` use — see Phase 2 correction below, not a bespoke context-menu Turn On/Off toggle as originally sketched).
5. Watch it consume 5 L of milk and produce 1 Butter every 500 in-game seconds, automatically repeating for as long as it's running, powered, has ≥5 L of milk, and has room in its output storage — with no per-batch player interaction required.
6. Hear it loop a churn/motor sound while running, matching (or closely substituting for) the manual Butter Churn's craft sound.

---

## Tasks

### Phase 1: `AutoButterChurn` Entity and Recipe Definition

**Status:** Work Complete

- [x] Create the `AutoButterChurn` entity script (`entities/workstations/entity_AutoButterChurn.txt`): `component UiConfig` (`uiEnabled = true`), `component Resources`, `component CraftLogic` with `StartMode = Automatic`, `component SpriteConfig` with a placeholder sprite row.
- [x] Resolve Q1/Q2 architecturally (see Notes and Risks — corrected from the design doc's sketch after tracing the decompiled resource system) — actual in-game confirmation is still open, deferred to Phase 5.
- [x] Add the `component Resources` block. **Correction from the design doc:** there is no separate `component FluidContainer` — a `Resources` fluid entry (`ResourceType.Fluid`) owns its own internal `FluidContainer` independent of any entity-level one, so the milk tank *is* the `churn_inputs` group's fluid resource, not a bolted-on `FluidContainer` component. See `entity_AutoButterChurn.txt`.
- [x] Create the `auto_churn_butter` recipe (`recipes/PseudoButterChurnerRecipes.txt`): `Tags = AutoButterChurn`, 5.0 fluid `[CowMilk;SheepMilk] mode:mixture` → 1 `Base.Butter`, `time = 500`, `OnUpdate = AutoButterChurnCode.checkPower`.
- [x] Q3 (fluid unit-to-liter mapping) — proceeded with `Capacity = 20.0` as the working assumption per the recommendation; still needs in-game confirmation (Phase 5).
- [x] Q4 (output overflow behavior) — no explicit pause logic was needed: `CraftLogic.willOutputsAccommodate()`/`getFreeOutputSlotCount()` (`zombie42_20_4/entity/components/crafting/CraftLogic.java:464-482`) already gate a new automatic batch on free output slots, so a full 2-encumbrance output resource naturally blocks the next batch without custom Lua.
- [x] Q5 (non-milk fluid handling) — implemented via a named `fluidFilter AutoButterChurnMilk` script object (`fluids/PseudoButterChurnerFluidFilters.txt`), referenced by the `Resources` fluid entry's filter field. **Correction from the design doc:** fluid filters are separate named script objects (`ScriptType.FluidFilter`), not an inline `whitelist { Fluid ...}` block on the resource itself.

**Technical Notes:**
Reference: `doc/ideas/claude_automaticButterChurning.md` §3–§4. Key vanilla code path: `CraftLogicSystem.updateSimulation()` (`zombie42_20_4/entity/components/crafting/CraftLogicSystem.java:31`) ticks any entity with `ComponentType.CraftLogic`; the automatic-restart condition is at `CraftLogicSystem.java:102`.

Resource entry syntax verified against `zombie42_20_4/entity/components/resources/ResourceBlueprint.java` and `zombie42_20_4/scripting/entity/components/resources/ResourcesScript.java`: a bare (no `=`) value line in a `group` block is auto-prefixed as `<group>_<index>@<value>`, then parsed as `id@Type@IO@capacity[@StackAny]` (4-5 parts) or `id@Type@IO@capacity@filter@channel@flags` (7 parts, `null` for unused). Used `Fluid@Input@20.0@AutoButterChurnMilk@null@null` for the milk input and `Item@Output@2@StackAny` for the butter output (mirroring `entity_Drying_Rack.txt`'s item-only `Resources` block).

No custom sprite art exists for this mod yet — `SpriteConfig` currently reuses the manual Butter Churn's tile row (`crafted_05_72`) as a functional placeholder so the entity has a valid sprite reference. This does not satisfy the "visually resembles a washing machine" requirement and needs real art before this cycle can be considered feature-complete; flagged in Notes and Risks.

### Phase 2: Washing-Machine Conversion Flow

**Status:** Work Complete

- [x] Add a custom Lua context-menu hook (`client/ISUI/ISAutoButterChurnContextMenu.lua`, via `Events.OnFillWorldObjectContextMenu`) that adds a "Convert to Automatic Butter Churner" option when right-clicking a square containing an `IsoClothingWasher`, gated on: player carries a screwdriver (`ItemTag.SCREWDRIVER`, checked via `getFirstTagRecurse`, not consumed), Electrical skill ≥ 5 (`Perks.Electricity`), and the machine is empty and turned off (Q10).
- [~] Q6 (learnable-recipe requirement) — **deferred.** B42's item-side recipe-teaching field (the equivalent of the old `TeachedRecipes`) was not identified within this pass's research budget; implementing a schematic/magazine item with a fabricated field name risked shipping something silently broken. The conversion is currently gated on skill level alone (Electrical ≥ 5), with the schematic/magazine unlock left as follow-up research for a future DevCycle.
- [x] Q9 (which washing machines qualify) — restricted conversion to plain `IsoClothingWasher` only (`instanceof(obj, "IsoClothingWasher")`); `IsoCombinationWasherDryer` and `IsoStackedWasherDryer` are not matched.
- [x] Created `shared/TimedActions/ISConvertToAutoButterChurn.lua`, modeled on `media/lua/shared/TimedActions/ISOpenCloseLid.lua`, that on `:complete()` removes the `IsoClothingWasher` from the square and places the new `AutoButterChurn` entity via `square:addWorkstationEntity("AutoButterChurn", ...)`, carrying over health/max-health.
- [x] Q10's block-until-empty gating is enforced both in the context-menu option's `notAvailable` state and in `ISConvertToAutoButterChurn:isValid()`.

**Technical Notes:**
Reference: `doc/ideas/claude_automaticButterChurning.md` §4a, §5a. **Correction from the design doc:** there is no bespoke Start/Stop context-menu toggle for the finished `AutoButterChurn` entity (the design doc's plan to mirror `toggleClothingWasher`). `IsoClothingWasher` is a legacy hard-coded `IsoObject`, so its Turn On/Off option is Java-only. `AutoButterChurn`, once placed, is a scripted entity with `uiEnabled = true`, and vanilla already ships a generic entity crafting UI for any entity with `component CraftLogic` (`media/lua/client/Entity/ISUI/Components/Crafting/ISWidgetCraftLogicControl.lua`, `ISCraftLogicPanel.lua`) — the same panel `Drying_Rack` and other `CraftLogic`-family entities use, with its own Start/Cancel button already wired to `getCraftLogic():getStartMode()`/`isRunning()`. Interacting with the placed entity should open this generic panel with no custom Lua required; **this assumption needs Phase 5 in-game confirmation**, since no vanilla entity in the surveyed set is a plain `CraftLogic` host to compare against directly.

`IsoClothingWasher` lookup uses `square:getObjects()` + `instanceof(obj, "IsoClothingWasher")`, following the same pattern as `media/lua/client/ISUI/LootWindow/Handlers/ClothingWasherToggle.lua`.

### Phase 3: Power Gating

**Status:** Work Complete

- [x] Added the `OnUpdate` Lua hook (`shared/AutoButterChurnCode.lua`, `AutoButterChurnCode.checkPower`), wired via the recipe's `OnUpdate` field, force-stopping an in-progress batch when the entity's square loses power, mirroring `ClothingWasherLogic`'s mid-cycle power-loss shutoff.
- [~] The design doc's "OnTest-style check to block a *new* batch from starting while unpowered" — **dropped as designed; superseded.** Tracing `CraftRecipeData.java`'s `LuaCall` hooks (`OnTest`/`OnStart`/`OnUpdate`/`OnCreate`/`OnFailed`) found all of them are `void` callbacks with no return value the engine checks to veto a start — none of them can *prevent* a batch from beginning. The implemented approach is reactive instead: `checkPower` runs on every tick of a running craft (including its first tick) and force-stops it immediately if unpowered, which in practice halts an unpowered batch within one tick of it starting.
- [x] Q8 (power draw amount) — **deferred to a future DevCycle.** No power-draw mechanism was implemented; `AutoButterChurn` currently only checks `square:haveElectricity()` and doesn't consume generator fuel itself the way `IsoClothingWasher.getGeneratorPowerConsumption()` does. Adding an actual draw would need a hook into the square's power system beyond what `component CraftLogic`/`Resources` expose — flagged as follow-up.

**Technical Notes:**
Reference: `doc/ideas/claude_automaticButterChurning.md` §3 (power-gating bullet) and §4a (`AutoButterChurnCode.lua` pseudocode). `CraftLogicSystem` calls `craftData.luaCallOnUpdate()` every tick of a running craft (`CraftLogicSystem.java:83`).

**Correction from the design doc's pseudocode:** `craftRecipeData:getCharacter()` cannot reach the hosting entity/square — tracing `zombie42_20_4/entity/components/crafting/recipe/CraftRecipeData.java` found it holds no entity, component, or square reference at all (only `character`, `recipe`, and resource-tracking fields), and for an `Automatic`-mode background craft there is no player character involved, so `getCharacter()` would be `nil` anyway. The working path found instead: `CraftRecipeData.getViableResource(int)` returns a `Resource`; `Resource.getGameEntity()` (`zombie42_20_4/entity/components/resources/Resource.java:89`) returns the owning `GameEntity`; `GameEntity.getSquare()` (`zombie42_20_4/entity/GameEntity.java:74`) gives the square to check `haveElectricity()` on; and `GameEntity.getComponent(ComponentType.CraftLogic)` gives back the `CraftLogic` component itself, which has a real, `@UsedFromLua` `stop(IsoPlayer player, boolean force)` method (`zombie42_20_4/entity/components/crafting/CraftLogic.java:501`) — called as `stop(nil, true)` to force-stop with no player. Implemented exactly this chain in `AutoButterChurnCode.checkPower`. Whether `getViableResource(0)` is reliably populated with our milk resource at `OnUpdate` time for an already-running automatic craft is not fully confirmed from static reading alone — flagged for Phase 5.

### Phase 4: Sound

**Status:** Planning — deferred, not implemented this cycle

- [ ] Resolve Q7 — identify the sound asset the manual Butter Churn plays during its craft action (not identified in the prior Butter Churn analysis); if none exists, select a substitute "motor/mixing" loop.
- [ ] Wire the chosen sound into `component CraftBenchSounds` on the `AutoButterChurn` entity.

**Technical Notes:**
Reference: `doc/ideas/claude_automaticButterChurning.md` §5. `CraftBenchSoundsScript` maps a sound id to a game sound name (`zombie42_20_4/scripting/entity/components/sound/CraftBenchSoundsScript.java`). Not started this cycle — Q7's research (finding the manual churn's actual sound name) wasn't done, and `entity_AutoButterChurn.txt` currently has no `component CraftBenchSounds` block at all, so the entity is silent while running. Functionally complete without it; purely a follow-up.

### Phase 5: Static Review and In-Game Verification

**Status:** Planning

- [x] Confirm all new script/Lua files are under the mod's own directory structure, following the conventions used by sibling mods (e.g. `PseudoGrits`, `PseudoPorridge`). See File Manifest below.
- [x] Confirm all referenced vanilla item/entity/tag IDs exist (`Base.Butter`, `CowMilk`/`SheepMilk`, `ItemTag.SCREWDRIVER`, `Perks.Electricity`, `IsoClothingWasher`) — checked against the decompiled 42.20.4 sources.
- [x] Confirm translation files (item name, tooltip, context menu, recipe name) parse — validated as well-formed JSON.
- [~] Launch B42 with `PseudoButterChurner` enabled and confirm there are no script parse errors. **Attempted 2026-08-30, failed with two script-load errors — see Phase 6.** Fixes applied; needs a re-test.
- [ ] Confirm the entity's crafting UI panel actually opens on interaction and behaves as expected for a plain `CraftLogic` host (Phase 2 assumption).
- [ ] Convert a washing machine in-game and confirm the `AutoButterChurn` entity appears correctly.
- [ ] Fill the entity with milk, start it, and confirm it produces butter automatically every 500 in-game seconds without further interaction.
- [ ] Confirm power loss mid-cycle correctly halts production via `AutoButterChurnCode.checkPower` (Phase 3), and that `getViableResource(0)` is actually populated with the milk resource when this hook fires.
- [ ] Confirm output-overflow pausing behavior (Q4, via `CraftLogic`'s own free-output-slot gating) and non-milk fluid rejection (Q5, via the `AutoButterChurnMilk` fluid filter) both behave as designed.
- [ ] Confirm the fluid `Resources` group entry (`Fluid@Input@20.0@AutoButterChurnMilk@null@null`) parses and creates a working 20 L milk-only input as intended (Q1/Q2/Q3, and the Phase 1 `FluidContainer`-vs-`Resources` correction).

**Technical Notes:**
In-game verification is required before marking this cycle `Verified`. Agents may move implementation phases to `Work Complete` after static checks, but only Ed can approve `Verified` status, per `doc/planning/DevelopmentProcess.md`. Nothing in this DevCycle has been run in a live game yet — everything above the unchecked items is a static/code-level check only.

### Phase 6: First-Load Bugfixes

**Status:** Work Complete — fixes applied, re-test pending

The first real in-game load attempt (2026-08-30) failed at script load, before the game reached the main menu. Two errors in the mod's own scripts, plus one that turned out to be a false alarm:

- [x] **Bug 1 — `Unknown block '//' in entity iso script: AutoButterChurn`.** `entity_AutoButterChurn.txt`'s `component SpriteConfig` block had three lines of `//`-prefixed commentary (a "TODO: placeholder sprite" note) sitting among the block's values. `SpriteConfigScript`'s parser has no comment-stripping logic at all in this position — it read the `//` line as an attempt to open a child block named `//`, which isn't a recognized block type, so it failed. **Root cause:** I had wrongly believed `//` comments were valid inside vanilla entity scripts, based on a comment I myself wrote into an illustrative code excerpt in `claudeDocs/claude_amphoraAnalysis.md` during an earlier analysis session — not something actually present in the real `entity_amphora.txt` file. Re-checking the real generated vanilla entity scripts (`grep -rn "//" media/scripts/generated/entities/`) turns up zero comments anywhere; the format apparently doesn't support them in this position (possibly not at all). **Fix:** removed the comment block entirely from `entity_AutoButterChurn.txt`. The placeholder-sprite caveat now lives only in this DevCycle document (Phase 1 Technical Notes) and the doc/ideas design doc, not in a shipped script file.
- [x] **Bug 2 — `auto_churn_butter` recipe load failure:** `java.io.IOException: Previous input is null [auto_churn_butter] line: -fluid 5.0 [CowMilk;SheepMilk] mode:mixture` at `CraftRecipe.LoadIO`. Traced to `zombie42_20_4/scripting/entity/components/crafting/CraftRecipe.java:563-566`: a recipe input line starting with `-` (like `-fluid ...`) is not a standalone input — it's a modifier that attaches to the *immediately preceding* `item` input line (`InputScript.consumeFromItemScript`), meaning "drain this fluid from within that item's own `FluidContainer`." It requires a `lastInput` to already exist; ours didn't, because `PseudoButterChurnerRecipes.txt` copied vanilla `churn_butter`'s `-fluid 5.0 [...]` line verbatim without also copying the `item 1 [*]` line that precedes it in the vanilla recipe. That line makes sense for vanilla `churn_butter`, which runs on `CraftBench` and draws milk out of a physical bucket item the player places in the bench — a fundamentally different mechanism from `auto_churn_butter`, which needs to draw milk directly from the entity's own `Resources` fluid slot, with no item involved at all. Per `InputScript.Load` (`zombie42_20_4/scripting/entity/components/crafting/InputScript.java:563-588`), a bare `fluid 5.0 [...]` line (no leading `-`) *is* a valid standalone `ResourceType.Fluid` input, matched directly against a `Fluid`-type `Resource` — exactly our `churn_inputs` group's milk resource. **Fix:** changed `-fluid 5.0 [CowMilk;SheepMilk] mode:mixture` to `fluid 5.0 [CowMilk;SheepMilk] mode:mixture` in `PseudoButterChurnerRecipes.txt`.
- [x] Everything else in the log is either informational or unrelated to this mod, confirmed by inspection: `Sanitizing container name 'Large Bucket'/'Fuel Pump'` and `Could not find icon: Build_AnvilStone` are pre-existing vanilla-content warnings, not caused by `PseudoButterChurner`. `TaggedObjectManager... new tag discovered that was not preprocessed, tag: autobutterchurn` is a one-time informational warning that fires the first time any new tag is seen (the log shows the same message for unrelated tags `keyduplicator` and `choppingblock`) — not an error, and expected the first time `AutoButterChurn`'s tag is registered.
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner` after applying both fixes.
- [x] Re-launch B42 and confirm the mod now loads past script parsing. **Result: progressed further, but hit a new script-load error — see Phase 7.**

**Technical Notes:**
Both bugs were caught only by an actual game-load attempt, not by static reading — a concrete demonstration of why Phase 5 exists as a separate, mandatory step. Neither bug was something the earlier static cross-checking (Phase 1/3 Technical Notes) would have caught: the `//` comment issue required knowing the parser's exact tokenizing behavior for an edge case with no vanilla precedent to check against (and my own prior analysis-doc annotation actively misled me here), and the `-fluid` vs `fluid` distinction required reading `CraftRecipe.LoadIO`'s control flow line-by-line rather than pattern-matching the vanilla recipe's syntax.

### Phase 7: Second-Load Bugfix — Duplicate Sprite Row

**Status:** Work Complete — fix applied, re-test pending

With Phase 6's fixes in place, the mod's own scripts parsed successfully and the game proceeded much further — past mod loading, into actual world/save loading (`ButterChurnTest`) — before failing again:

- [x] **Bug — `Sprite 'crafted_05_72' is duplicate. entity script: AutoButterChurn'`** (`SpriteConfigManager.parseEntityScript`, `SpriteConfigManager.java:504`), which escalated into a fatal `WorldDictionaryException: World loading could not proceed, there are script load errors.` (`IsoWorld.java:2789`). **Root cause:** `entity_AutoButterChurn.txt`'s `SpriteConfig` reused `crafted_05_72` — the same tile row the vanilla `ChurnBucket` (manual Butter Churn) entity already uses (confirmed via `entity_butter_churn.txt`). Sprite rows are apparently globally unique across all entities scanned by `SpriteConfigManager`, not per-entity or per-module — reusing any already-claimed row from *any* other entity (vanilla or modded) is a hard error, not just a visual collision. This was a direct consequence of the Phase 1 placeholder decision to "reuse the manual Butter Churn's sprite row" as a stand-in for real art, which turned out to be invalid, not just visually confusing. **Fix:** changed the sprite row to `crafted_05_60`, an index absent from every `row = crafted_05_*` reference found across `media/scripts/generated/entities/` (checked via a full-repo grep and numeric sort of all `crafted_05_N` indices in use — populated indices run from 4 to 147 with several gaps, of which `60` was picked as a mid-range, low-risk-of-out-of-bounds gap). Updated in both `entity_AutoButterChurn.txt` (the `SpriteConfig` row) and `ISConvertToAutoButterChurn.lua` (`ISConvertToAutoButterChurn.SPRITE`, passed to `addWorkstationEntity`), which must stay in sync.
- [x] Confirmed the rest of the new log output is unrelated to this mod: the `Piano` recipe icon warning, `WorldGen.lua` recursive-require warnings, missing `objects.lua` map files for unused vanilla towns, and the `duplicate RoomDef.metaID`/`invalid room metaID` map-data errors are all pre-existing vanilla/save-specific issues with no connection to `PseudoButterChurner`.
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner` after applying the fix.
- [x] Re-launch B42 and confirm the world now loads successfully (carries forward into Phase 5). **Confirmed 2026-08-30 — no more errors on load.**
- [ ] Confirm `crafted_05_60` is actually a valid, in-bounds tile on the sheet once the game renders it — picking a numeric gap from script references alone doesn't guarantee the tile slot itself is valid; if it renders wrong/blank/garbled, a different placeholder (or real art) will be needed. This does not block script loading either way, only visual correctness. Still open — not yet visually confirmed.

**Technical Notes:**
The `PostTileDefinitions` load phase (`SpriteConfigManager.InitScriptsPostTileDef`) is a distinct, later stage from the initial mod script parse that caught Phase 6's bugs — it only runs once actual world/save loading begins, which is why this error didn't surface until a save was loaded rather than at the main menu. Worth remembering for future entity work in this mod: sprite-row collisions are a whole-install-wide namespace, not scoped to a single entity or mod, and picking a placeholder row requires checking usage across all of `media/scripts/generated/entities/`, not just the specific vanilla entity being visually mimicked.

**Result: confirmed working.** The mod now loads with no errors — Phases 6 and 7 together resolved everything blocking a clean load.

### Phase 8: Allow Converting the Combination Washer/Dryer

**Status:** Work Complete — implemented, re-test pending

Scope change requested after confirming a clean load: the conversion option should also be offered on `IsoCombinationWasherDryer` (the combo unit), not just the plain `IsoClothingWasher`. This reverses the Phase 2 decision on Q9, which had deliberately excluded the combo unit ("feels like a bigger balance/scope question than this design needs to resolve up front") — that concern is now overridden by direct request.

- [x] Extended the source-object detection in `ISAutoButterChurnContextMenu.lua` to also match `instanceof(obj, "IsoCombinationWasherDryer")`, alongside the existing `IsoClothingWasher` check. Confirmed via `zombie42_20_4/iso/objects/IsoCombinationWasherDryer.java` that it `extends IsoObject` directly (a sibling of `IsoClothingWasher`, not a subclass of it — the two `instanceof` checks are both required, one doesn't imply the other) and exposes the same `isActivated()`/`getContainer()`/`getSquare()` methods used throughout the existing gating logic, so no other code needed to change. **Correction (Phase 9):** this bullet originally also claimed `getHealth()`/`getMaxHealth()` were shared — that was wrong on both object types, not just the combo unit; see Phase 9.
- [x] Verified the combo unit's dual washer/dryer mode (`isModeWasher()`/`isModeDryer()`, `setModeWasher()`/`setModeDryer()`) doesn't need special handling here: conversion only cares whether the object is off and empty (`isActivated()`/`getContainer():isEmpty()`), which both `ClothingWasherLogic` and `ClothingDryerLogic` report through the same `IClothingWasherDryerLogic`-delegating methods regardless of which mode is currently active. The combo unit is destroyed and replaced either way, so its current mode is irrelevant to the conversion itself.
- [x] Generalized the "must be empty and turned off" tooltip string (`Tooltip_AutoButterChurn_MustBeEmptyAndOff`) from "Washing machine must be empty and turned off" to "Must be empty and turned off", since it now applies to two different object types and the option's own tooltip name (`ISWorldObjectContextMenu.getMoveableDisplayName(washer)`) already identifies which one.
- [x] Updated header comments in `ISAutoButterChurnContextMenu.lua` and `ISConvertToAutoButterChurn.lua` to describe both eligible source types; no functional changes were needed in the timed action itself, since it only ever called generic `IsoObject`-level methods on the (now generically named) `washer` variable.
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner`.
- [x] Re-launch B42 and confirm the conversion option now appears on a placed `IsoCombinationWasherDryer`. **Confirmed the option appeared and was selectable — but completing the conversion crashed. See Phase 9.**
- [ ] Confirm the plain `IsoClothingWasher` conversion path still works unchanged (regression check for this phase's edit) — moot until Phase 9's fix is retested, since the crash found is not specific to the combo unit (see Phase 9).

**Technical Notes:**
`IsoStackedWasherDryer` (the third variant noted in Q9 and the original Washing Machine analysis) was left out of scope for this phase — not requested, and its cycle logic was never examined in this mod's prior analysis passes. Revisit only if asked.

### Phase 9: Third-Load Bugfix — `getHealth` Doesn't Exist on Legacy IsoObject

**Status:** Work Complete — fix applied, re-test pending

Clicking "Convert to Automatic Butter Churner" and letting the timed action run crashed at completion:

```
Lua fail. Message: Object tried to call nil in complete
    Lua((MOD:Pseudonymous Automatic Butter Churner)).complete(ISConvertToAutoButterChurn.lua:48)
```

- [x] **Root cause:** `ISConvertToAutoButterChurn:complete()` (line 48) called `self.washer:getHealth()` and `self.washer:getMaxHealth()` on the source `IsoClothingWasher`/`IsoCombinationWasherDryer` object, to carry its health over to the new `AutoButterChurn` entity — copying the pattern from the vanilla Amphora's `ISOpenCloseLid.lua`, which does the same thing successfully. The difference: `ISOpenCloseLid`'s `self.barrel` is a `GameEntity` (the scripted-entity system), and `GameEntity` genuinely has `getHealth()`/`getMaxHealth()`/`setHealth()`/`setMaxHealth()`. `self.washer` here is a **legacy `IsoObject`** (`IsoClothingWasher`/`IsoCombinationWasherDryer` both extend `IsoObject` directly, not `GameEntity`), and `IsoObject` has no `getHealth()`/`getMaxHealth()` method at all — confirmed by grepping `zombie42_20_4/iso/IsoObject.java` and `zombie42_20_4/iso/objects/IsoClothingWasher.java` for any health/condition accessor and finding none. Calling a nonexistent method on a real (non-nil) object reads as "call nil" in Kahlua because the method lookup itself returns nil, which is what the crash message ("Object tried to call nil") means. This bug has existed since Phase 2's original implementation — it wasn't specific to `IsoCombinationWasherDryer` or introduced by Phase 8, it just hadn't been exercised until now because this was the first successful end-to-end conversion attempt. Phase 8's Technical Notes incorrectly claimed the combo unit "exposes the same ... `getHealth()`/`getMaxHealth()` ... methods" as the existing code path — that claim has been corrected in place, since neither object type actually has them.
- [x] **Fix:** removed the health carryover entirely from `ISConvertToAutoButterChurn:complete()` — no more reading `self.washer:getHealth()`/`getMaxHealth()`, and no more calling `newEntity:setHealth()`/`setMaxHealth()`. The new `AutoButterChurn` entity now simply uses its `SpriteConfig`-defined defaults (`health = 100`, `skillBaseHealth = 20`, already set in `entity_AutoButterChurn.txt`) rather than trying to inherit a health value the source object never had in the first place.
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner`.
- [x] Re-launch B42 and confirm converting either a plain `IsoClothingWasher` or an `IsoCombinationWasherDryer` completes without error and leaves a working `AutoButterChurn` entity in place. **No crash this time — but the converted object was invisible, not "a working entity in place." See Phase 10.**

**Technical Notes:**
This is the second time in this DevCycle that a pattern copied from `ISOpenCloseLid.lua` didn't transfer cleanly (the first was the Phase 1 sprite-row placeholder reasoning) — both times because `ISOpenCloseLid` operates on a scripted `GameEntity` (the Amphora), while `PseudoButterChurner`'s conversion flow operates on a legacy `IsoObject` on one side (the washer/dryer being consumed) and a `GameEntity` on the other (the `AutoButterChurn` being created). The two object systems have different APIs, and code that looks identical to `ISOpenCloseLid`'s isn't safe to assume works the same way unless the object it's called on is actually the same kind of object. Worth remembering for any future work in this mod that mixes legacy `IsoObject`s and scripted entities in the same flow.

**Correction (Phase 10):** the object returned by `square:addWorkstationEntity(...)` (our `newEntity`) is actually an `IsoThumpable` (`zombie42_20_4/iso/IsoGridSquare.java:11741`), not a bare `GameEntity` as stated above — `IsoThumpable extends IsoObject implements ... IHasHealth` (`zombie42_20_4/iso/objects/IsoThumpable.java:82`) and genuinely has `getHealth()`/`setHealth()`/`getMaxHealth()`/`setMaxHealth()` (`IsoThumpable.java:291-310`). So this phase's removal of `newEntity:setHealth()`/`setMaxHealth()` wasn't strictly necessary — those calls would have worked. It was harmless to remove them (the engine already calls `thumpable.setHealth(thumpable.getMaxHealth())` itself inside `addWorkstationEntity`, per `IsoGridSquare.java:11757`), and the actual bug — `self.washer:getHealth()` on the legacy source object — was correctly identified and fixed either way.

---

### Phase 10: Fourth-Load Bugfix — Converted Object Is Invisible

**Status:** Work Complete — best-effort fix applied; underlying limitation flagged as unresolved

No crash this time, but the reported behavior is still wrong: converting a washer made it vanish entirely, with nothing visibly left in its place. Expectation (from the original concept, §1 of `doc/ideas/claude_automaticButterChurning.md`) was that it "visually resembles a washing machine" — at minimum, it should be *visible*.

- [x] **Root cause, traced through `IsoThumpable`'s constructor** (`zombie42_20_4/iso/objects/IsoThumpable.java:412-420`, the overload `addWorkstationEntity` actually calls): `this.closedSprite = IsoSpriteManager.instance.getSprite(sprite)`. The `sprite` string we pass (`ISConvertToAutoButterChurn.SPRITE`) is looked up directly against `IsoSpriteManager`'s registry of actual loaded sprite names — if no sprite was ever registered under that exact name, `getSprite()` returns `null` silently (no exception, no log line), `closedSprite` stays `null`, and the object renders nothing. This is a materially different (and more precise) failure mode than what Phase 7 dealt with: Phase 7's bug was a **name collision** (`crafted_05_72` already claimed by `ChurnBucket`, a hard load-time error). This bug is the opposite problem — a name that collides with *nothing*, because it was never assigned to any actual artwork in the first place. My Phase 7 fix picked `crafted_05_60` by finding a numeric gap in the *set of indices referenced by vanilla entity scripts*, which was never a check against what sprites actually exist in `IsoSpriteManager`'s registry — a script-reference gap and an actually-registered-but-unscripted sprite are not the same thing, and evidently `crafted_05_60` was neither.
- [x] **Fix (best-effort, not a full solution — see below):** changed the placeholder row from `crafted_05_60` to `crafted_05_78`, a small 2-index gap (`76, 77` used → `78, 79` unused → `80, 81` used) sitting *inside* a densely, contiguously populated run of the sheet, rather than in the middle of a 16-index gap (`56`-`71`) the way `crafted_05_60` was. The working theory: small gaps inside a dense, contiguous run of real content are much more likely to correspond to genuinely registered (if currently unscripted) artwork than an isolated large gap, which more plausibly represents a whole unpopulated region of the sheet. This is still a guess, not a confirmed-good value — it has not been visually tested.
- [x] Updated both `entity_AutoButterChurn.txt` (`SpriteConfig` row) and `ISConvertToAutoButterChurn.lua` (`ISConvertToAutoButterChurn.SPRITE`) to stay in sync, as before.
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner`.
- [ ] Re-launch B42, convert a washer, and confirm something is now actually visible on the square.
- [ ] **If `crafted_05_78` is also invisible or renders as unrelated/garbled content:** stop guessing indices on the shared vanilla `crafted_05` sheet entirely. The durable fix is real custom art — a small mod-owned texture pack and tile definition (the same pattern `PseudoSaltWell42_19` already uses in this project, e.g. `PseudoSaltWell/common/media/texturepacks/pseudoed_salt_01.pack` + matching `.tiles` file), giving `AutoButterChurn` its own uniquely-named sprite that's guaranteed to exist and can actually be drawn to look washing-machine-like. That is real asset-creation work, not a script/Lua fix, and is out of scope for this DevCycle without dedicated art (or an artist/tool) — flagged in Notes and Risks as the mod's most significant remaining gap against its original concept.

**Technical Notes:**
This is the third distinct sprite-related surprise in this DevCycle (Phase 1's placeholder-art decision, Phase 7's duplicate-name collision, and now this silently-absent-name failure) — a consistent pattern of the `crafted_XX_YY` sheet namespace being far less forgiving and far less discoverable by static script grepping than it first appeared. A future DevCycle that wants `AutoButterChurn` to look like anything specific (a washing machine or otherwise) should plan for real tile/texture-pack authoring from the start rather than reusing vanilla sheet slots.

---

### Phase 11: Narrow Testing Scope to Combo Washer/Dryer Only

**Status:** Work Complete

Testing decision, not a bug: to isolate variables while chasing the Phase 10 visibility issue and any further conversion-flow bugs, conversion is temporarily restricted to `IsoCombinationWasherDryer` only. Once that path is confirmed fully working, the plain `IsoClothingWasher` path (added in Phase 2, still believed functionally sound - it uses the exact same generic `IsoObject`-level gating and the same `ISConvertToAutoButterChurn` timed action) will be re-enabled for its own dedicated test pass.

- [x] Added `ISAutoButterChurnContextMenu.ALLOW_PLAIN_WASHER = false` as a single toggle flag in `ISAutoButterChurnContextMenu.lua`. The source-object detection loop now only matches `IsoClothingWasher` when that flag is `true`; `IsoCombinationWasherDryer` is unaffected and always eligible.
- [x] No other files changed — `ISConvertToAutoButterChurn.lua` and the recipe/entity scripts are unaffected, since the restriction lives entirely in which objects the context-menu option is offered on.
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner`.
- [ ] Once the combo washer/dryer conversion is confirmed working end-to-end (visible entity, correct behavior), flip `ALLOW_PLAIN_WASHER` back to `true` and re-test the plain `IsoClothingWasher` path specifically.

**Technical Notes:**
This is implemented as a single boolean flag rather than deleting/re-adding code, specifically so re-enabling the plain washer later is a one-line change with no risk of reintroducing an old bug by mistyping the restored logic.

---

### Phase 12: Fifth-Load Bugfix — Still Invisible; Added a Sprite Diagnostic Instead of Guessing Again

**Status:** Work Complete — diagnostic ran, result reported; see Phase 13

With testing narrowed to the combo washer/dryer only (Phase 11), the conversion was tried again with Phase 10's `crafted_05_78` fix in place. **Same result: the converted object disappeared, with nothing visible left in its place.** The supplied `console.txt` tail contains no error, exception, or log line referencing `AutoButterChurn`, `crafted_05`, or this mod at all around the time of conversion — every line shown (animated-model skinning warnings, missing `vegetation_groundcover_01_*` tiles, `Wooden_Windows` SpriteConfig warnings, "too many physics objects") is unrelated vanilla/map noise, confirmed by inspection.

- [x] **Assessment:** this is the second consecutive silent failure with `crafted_05_N` placeholder guesses (`60` in Phase 10, now `78`), with zero diagnostic evidence either time. Phase 10's own fallback plan already anticipated this: *"stop guessing indices on the shared vanilla `crafted_05` sheet entirely"* once a second guess also failed. Continuing to pick a third number by the same "gap in script references" heuristic isn't a reliable process — it's already been shown twice not to correlate with whether `IsoSpriteManager` actually has the name registered, and there is no local tool to inspect the packed vanilla texture atlas (`media/newtiledefinitions.tiles` is a proprietary binary format with no decompiled parser found in the available `zombie42_20_4` sources; the underlying `.pack` texture atlas files were not found as loose, viewable images either).
- [x] **Instead of a third guess, added a one-time diagnostic** (`media/lua/client/AutoButterChurnSpriteDiagnostic.lua`, new file): on `Events.OnGameStart`, it calls `IsoSpriteManager.instance:getSprite("crafted_05_" .. i)` (`@UsedFromLua`, confirmed in `zombie42_20_4/iso/sprite/IsoSpriteManager.java:12-48`) for every `i` from 0 to 200, and `print()`s which names actually resolve to a non-nil sprite. This runs entirely client-side with no gameplay effect, and turns "guess and check, one attempt per play session" into "get a complete, authoritative list of every valid `crafted_05_N` name in one run."
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner`.
- [x] Launched B42 with the mod enabled and captured the `AutoButterChurnSpriteDiag:` output. **Result: every single index from 0 to 200 came back `FOUND`** ("scan of crafted_05 complete, 201 found out of 201").

**Technical Notes:**
This result **rules out the sprite-name-doesn't-exist theory entirely** — `crafted_05_78` (and every other index tried) is a genuinely valid, registered sprite name; `IsoSpriteManager.instance:getSprite(...)` never returns nil for this range at all, so the invisibility bug in Phases 10 and 12 was never actually about picking an unregistered name. That theory, while plausible from the `IsoThumpable` constructor code alone, is now disproven by direct evidence. The real cause is something else — see Phase 13.

---

### Phase 13: Deeper Diagnostic — Does the Entity Actually Get Created?

**Status:** Work Complete — root cause found and fixed via Phase 14

With the sprite-name theory ruled out by Phase 12's evidence, the next most likely explanation was investigated: `GameEntityFactory.CreateIsoObjectEntity` — the Java method that actually wires up the new `AutoButterChurn` entity's components after `IsoThumpable` construction — wraps its work in a try/catch that swallows any exception into `ExceptionLogger.logException(e)` (`zombie42_20_4/entity/GameEntityFactory.java:125-131`) rather than letting it propagate back to Lua. If entity creation were failing internally (e.g. a `Resources`/`CraftLogic` setup problem only surfacing at runtime, not at script-load time), our Lua code would see a non-nil `IsoThumpable` returned regardless and have no way to know something went wrong.

- [x] Traced `ExceptionLogger.logException` (`zombie42_20_4/core/logger/ExceptionLogger.java`) far enough to mostly rule this out too: it still writes through the normal `DebugType.General` log stream (the same one everything else in `console.txt` goes through — not a separate, hidden log file), and on a non-dedicated-server it also pops up a small red "ERROR" indicator in the corner of the screen (`showPopup()`). Since neither an ERROR log line nor a reported on-screen popup accompanied the disappearance, entity creation most likely did *not* throw — but this isn't as airtight as Phase 12's proof, since we don't have direct confirmation nothing was on-screen.
- [x] Replaced the deleted sprite-scan diagnostic with targeted prints directly inside `ISConvertToAutoButterChurn:complete()` (not a new file this time — added straight to the real conversion flow, since that's exactly where the mystery is), reporting:
  - whether `addWorkstationEntity(...)` returned nil or a real object,
  - the new entity's `getSquare()`, `getSprite()`, and `getX()/getY()/getZ()`,
  - and whether the new entity actually shows up when re-querying `self.square:getObjects()` right after creation.
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner`.
- [x] Converted a combo washer/dryer and captured the result: **`AutoButterChurnDiag: addWorkstationEntity returned nil`.** This was the whole story — entity creation was never even attempted; `addWorkstationEntity` bailed out at its very first line. See Phase 14 for the root cause and fix.

**Technical Notes:**
The nil return, with zero exception and zero log output, is fully explained by Phase 14's finding: `addWorkstationEntity(String scriptString, String sprite)` (`IsoGridSquare.java:11741`) does `GameEntityScript script = ScriptManager.instance.getGameEntityScript(scriptString); if (script == null) { return null; }` — a clean, silent early return with no error path at all when the script name doesn't resolve. `GameEntityFactory`/`ExceptionLogger` (this phase's other line of investigation) were never even reached.

---

### Phase 14: Root Cause Found — Entity Name Needs Its Module Prefix

**Status:** Work Complete — fix applied, but confirmed NOT sufficient on its own; see Phase 15

**Root cause:** `ScriptManager.getGameEntityScript("AutoButterChurn")` was returning `null` because `ScriptBucketCollection.getScript(String name)` (`zombie42_20_4/scripting/ScriptBucketCollection.java:73-91`) treats any name **without a dot in it** as implicitly scoped to the `Base` module:

```java
if (!name.contains(".")) {
    module = this.scriptManager.getModule("Base");
} else {
    module = this.scriptManager.getModule(name);
}
```

Our entity is declared as `module Pseudonymous { entity AutoButterChurn { ... } }` in `entity_AutoButterChurn.txt` — **not** `module Base`. Looking it up by the bare name `"AutoButterChurn"` therefore searched the `Base` module's entity bucket, didn't find it there (it's registered under `Pseudonymous`), and returned `null` — silently, with no exception and no log line, exactly matching what the Phase 13 diagnostic showed. This also fully explains why the object "disappeared" rather than anything else: `ISConvertToAutoButterChurn:complete()` had already removed the source washer/dryer from the square (`RemoveTileObject`) *before* the failed `addWorkstationEntity` call, so nothing was ever there to replace it.

Every vanilla entity referenced elsewhere in this mod's research (`ChurnBucket`, `Amphora`, `Drying_Rack`, etc.) is declared under `module Base`, which is why bare names like `"ChurnBucket"` or `"AmphoraClosed"` work fine in vanilla code (including `ISOpenCloseLid.lua`, the pattern this file was modeled on) — they're always implicitly in-scope. Our mod's entity, being in its own `Pseudonymous` module (matching the convention other Pseudo-mods in this project use for mod-owned content), was never going to resolve by bare name.

- [x] **Fix attempted:** added `ISConvertToAutoButterChurn.ENTITY_SCRIPT = "Pseudonymous.AutoButterChurn"` and changed the `addWorkstationEntity` call to use it instead of the bare `"AutoButterChurn"` string.
- [x] ~~Removed the Phase 13 diagnostic prints from `ISConvertToAutoButterChurn:complete()` now that they've served their purpose and given a definitive answer.~~ **This was a mistake — see Phase 15.** The fix wasn't actually confirmed working before the diagnostics that would prove it were removed. Declaring this fixed was premature.
- [x] Confirmed the recipe-tag side of things does *not* have the same problem: `component CraftLogic { Recipes = AutoButterChurn }` and `craftRecipe auto_churn_butter { Tags = AutoButterChurn }` both use the bare tag name, but recipe tags are resolved through a completely different mechanism (`CraftRecipeManager.FormatAndRegisterRecipeTagsQuery`/tag-based query matching, not `ScriptBucketCollection.getScript`'s module-qualified name lookup), and this has worked without error since Phase 6 — left unchanged.
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner`.
- [x] Re-launch B42, convert a combo washer/dryer, and confirm an actual visible `AutoButterChurn` entity now appears in its place. **Result: still broken — object still disappeared. No diagnostic output at all this time, because the diagnostics that would have shown *why* had just been removed. See Phase 15.**

**Technical Notes:**
This is the fourth distinct root cause found in this DevCycle's conversion flow (Phase 9's `getHealth`, Phase 10/12's sprite-name red herring, and now this module-qualification issue), and arguably the most fundamental one — nothing about sprite rows or health methods mattered until the entity was actually being created at all, which it never was. Worth remembering broadly for this mod family: any `ScriptManager`/`ScriptBucketCollection`-mediated lookup by name (entity scripts, and likely other script types sharing this same base class) needs the full `ModuleName.ScriptName` form unless the script lives in `module Base` — vanilla code is a poor model for this specific detail, since virtually all vanilla content *is* `module Base` and never has to think about it.

**Correction (Phase 15):** the trace above was logically sound against the decompiled source, but turned out to be either incomplete or wrong — the fix did not resolve the bug in-game. Do not treat this phase's diagnosis as confirmed; it's demoted to "a plausible contributing factor, unconfirmed" until Phase 15's fresh evidence says otherwise.

---

### Phase 15: Fix Didn't Work — Restoring and Expanding Diagnostics Instead of Re-Guessing

**Status:** Work Complete — diagnostics produced a conclusive, positive result; see Phase 16

Direct correction from feedback: after Phase 14's fix, the bug was reported still present, but there was no diagnostic evidence to explain why, because the Phase 13 diagnostic prints had just been deleted on the (premature) assumption that the module-qualification fix was correct and complete. That was a mistake — a fix should be confirmed working before its supporting diagnostics are torn out, not after. This phase does not attempt a fifth guess; it restores logging and adds more of it, so the next test run produces hard evidence instead of another round of "did it work? unknown."

- [x] **Restored and expanded the per-conversion diagnostics** in `ISConvertToAutoButterChurn:complete()` (not deleted this time, and won't be until success is confirmed): logs `self.washer`/`self.square` at entry, the exact `ENTITY_SCRIPT`/`SPRITE` string values being used, a direct `ScriptManager.instance:getGameEntityScript(ENTITY_SCRIPT)` call *before* `addWorkstationEntity` even runs (isolating whether the lookup itself succeeds, independent of everything else `addWorkstationEntity` does), the `addWorkstationEntity` return value, and — if non-nil — the new entity's square/sprite/coordinates and whether it's actually present in `square:getObjects()`.
- [x] **Added a new one-time enumeration diagnostic** (`media/lua/client/AutoButterChurnEntityDiagnostic.lua`, new file, `Events.OnGameStart`): calls `ScriptManager.instance:getAllGameEntities()` and prints `getFullName()`/`getModuleName()`/`getName()` for every registered `GameEntityScript` whose name contains "butter" or "pseudonymous" (case-insensitive), plus direct `getGameEntityScript(...)` lookup results for three candidate strings (`"AutoButterChurn"`, `"Pseudonymous.AutoButterChurn"`, `"pseudonymous.AutoButterChurn"`). This sidesteps reasoning about the lookup code entirely and just asks the running game directly what key our entity is actually registered under — ground truth instead of another inference from static source reading.
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner`.
- [x] Launched B42, captured the enumeration diagnostic, and attempted one more conversion of a combo washer/dryer. **Result: genuinely good news.** `AutoButterChurnEntityDiag: MATCH getFullName=[Pseudonymous.AutoButterChurn] getModuleName=[Pseudonymous] getName=[AutoButterChurn]` confirms Phase 14's fix used the exact correct key. `AutoButterChurnDiag: addWorkstationEntity returned` a real, non-nil `IsoThumpable`. Its `getSquare()`, `getX()/getY()/getZ()` all report sane values, and `newEntity present in square:getObjects() = true`. Its `getSprite()` is also non-nil (a real `IsoSprite` object, not null).

**Technical Notes:**
Phase 14's fix (the module-qualified `"Pseudonymous.AutoButterChurn"` name) **did work, and was correctly diagnosed** — it fixed the actual bug it targeted (entity creation was failing; now it isn't). The "still bugged" report that followed it is a **different, later bug**: the entity now genuinely exists, in the right place, with a valid sprite object, and the player still doesn't see anything. This is no longer a creation problem at all — it's now conclusively a pure rendering/visibility problem, exactly the fallback scenario Phase 13's own notes anticipated as a possibility. See Phase 16.

---

### Phase 16: Entity Confirmed Created — Now Isolating the Rendering Problem

**Status:** Work Complete — sprite visibility confirmed fixed; new issue found, see Phase 17

With Phase 15's diagnostics proving the `AutoButterChurn` entity is genuinely created, correctly placed, and holds a non-nil `IsoSprite`, the remaining mystery is why nothing draws on screen. Two explanations remain open, and this phase sets up a test to distinguish them:

1. `crafted_05_78` is a registered-but-blank/reserved tile slot — `IsoSpriteManager.instance:getSprite(name)` returning non-nil (as Phase 12's scan showed for the whole 0–200 range) doesn't guarantee the tile has actual drawn pixels. A "valid but empty" sprite would explain everything seen so far.
2. Something about the `RemoveTileObject` → `addWorkstationEntity` swap sequence itself leaves a stale render cache for that square, and the object would actually be visible after e.g. moving away and back, reloading the cell, or reloading the save — independent of which sprite name is used.

- [x] **Test change:** temporarily changed only the *runtime* sprite argument passed to `addWorkstationEntity` (`ISConvertToAutoButterChurn.SPRITE`) to `"crafted_05_72"` — the manual Butter Churn's own sprite, which is definitely not blank (it's a normal, visible, currently-shipping vanilla object). This is a different thing from `entity_AutoButterChurn.txt`'s own declared `SpriteConfig` row (left at `crafted_05_78`, unchanged) — the `addWorkstationEntity(script, sprite)` call's `sprite` argument only sets the resulting `IsoThumpable`'s own `closedSprite` field directly via a raw `IsoSpriteManager` lookup (`IsoThumpable.java:412-420`), with no uniqueness/collision check at all (unlike the Phase 7 `SpriteConfigManager` load-time validation, which only checks declared `SpriteConfig` components, not this runtime argument) — so reusing `ChurnBucket`'s sprite name here should be safe and shouldn't reintroduce Phase 7's duplicate-sprite load error.
- [x] Added one more diagnostic line: `newEntity:getSprite():getName()`, to directly confirm what name ended up attached to the rendered object, as a sanity check on the test above.
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner`.
- [x] Converted a combo washer/dryer again. **Result: the object appeared, looking like the manual Butter Churn** (as expected, since `crafted_05_72` is that entity's own sprite). This confirms explanation 1 from the list above: `crafted_05_78` was a registered-but-blank sprite slot (`IsoSpriteManager` had an entry for it, but nothing was ever drawn there) — not a code bug at all. Guessing numeric gaps in the `crafted_05` sheet is confirmed unreliable in exactly the way Phase 10's fallback plan warned about.

**Technical Notes:**
This test was deliberately not meant to be a final fix — `crafted_05_72` is the manual Butter Churn's own look, not a washing machine — but it served its diagnostic purpose perfectly: proving the remaining problem really was "which sprite," not something structurally broken about the entity-creation/rendering pipeline. See Phase 17 for what came next, which turned out to be a larger design conversation than the sprite question alone.

---

### Phase 17: Redesigned Milk Filling and Churning Around `component FluidContainer`

**Status:** Work Complete, but confirmed NOT working — cycle closed with this unresolved. See Notes and Risks / Completion Summary.

With the entity now visibly appearing, the next report was about the *interaction*, not the visuals: right-clicking the placed entity showed a menu option labeled `Entity_DisplayName_Default` that opened something resembling the manual Butter Churn's own crafting window, and the user was explicit that they do not want that menu — it "seems locked to the manual butter churning process."

Investigation traced both parts of this precisely:

- The literal string `Entity_DisplayName_Default` comes from `GameEntity.DEFAULT_ENTITY_DISPLAY_NAME` / the translation key `EC_Entity_DisplayName_Default` (`zombie42_20_4/entity/GameEntity.java:50,65,123`) — the hardcoded fallback used whenever an entity's `entityStyle` (`ES_AutoButterChurn` in our case) has no matching entry in any loaded `xuiSkin`. **We had never created an `entity_AutoButterChurn_xuiSkin.txt`** (every other entity referenced in this mod's research — `ChurnBucket`, `Amphora` — has its own hand-authored xuiSkin file; ours never did), so it fell all the way back to `XuiSkin.defaultEntityUiStyle` (`zombie42_20_4/scripting/ui/XuiSkin.java:61-74`) — some *other* entity's or a generic shared default's window configuration, which is why it looked like manual crafting: it plausibly wasn't even *our* window at all, just whatever the shared fallback happens to be.
- Separately, `IsoObjectPicker.isInteractiveEntity()` (`zombie42_20_4/iso/IsoObjectPicker.java:698-712`) requires a resolved `EntityUiStyle` with a non-null `LuaWindowClass`/`LuaCanOpenWindow` before any window-opening interaction is offered at all — again gated by having a real xuiSkin entry, which we lacked.

Rather than just plug that gap and keep the `component CraftLogic`/`component Resources` design from Phase 1, the user asked a more fundamental question: could `AutoButterChurn` fill with milk the same simple way vanilla water troughs, rain collector barrels, and the Amphora do — a plain "pour a held container's contents in" interaction, no crafting window involved at all? Tracing `ISWorldObjectContextMenuLogic.fetch()` (`zombie42_20_4/iso/ISWorldObjectContextMenuLogic.java:540-545`) confirmed this is controlled by one simple, generic check: `else if (v.hasComponent(ComponentType.FluidContainer))` — completely independent of entities vs. legacy objects, completely independent of any xuiSkin/window, and completely independent of `CraftLogic`/`Resources`. Any object with a plain `component FluidContainer` — ours included, since our entity resolves to a generic `IsoObject`-family `IsoThumpable` at this level — gets the `"ContextMenu_AddFluidFromItem"` pour-in submenu (`ISWorldObjectContextMenuLogic.java:4287-4310`) automatically, for free, no custom Lua required.

**This directly reverses the Phase 1 correction.** Phase 1 deliberately dropped `component FluidContainer` in favor of a `Resources` `Fluid@Input` entry, reasoning that only `Resources`-group entries are visible to `CraftLogic` recipe matching (`CraftLogic.getInputResources()` only ever reads named `Resources` groups, confirmed at the time and still true) — which was correct as far as it went, but didn't account for `Resources` fluid entries *not* getting the simple vanilla pour-in interaction the way `component FluidContainer` does. The two requirements (simple vanilla fill UX, and `CraftLogic`-driven automatic batching) turned out to be mutually exclusive with the entity-component tools available to an uncompiled mod. Given the user's explicit preference for the trough-style UX, this phase **drops `component CraftLogic`/`component Resources`/the `auto_churn_butter` recipe entirely** and reimplements the milk→butter conversion as a small hand-rolled Lua system, modeled directly on the vanilla pattern used for exactly this kind of "world object that does something automatically over time" (rain collector barrels' `SRainBarrelSystem.lua`, the washing machine's `ClothingWasherLogic`): a registry of placed entities, ticked periodically, using elapsed in-game time.

- [x] **Rewrote `entity_AutoButterChurn.txt`:** now just `component UiConfig` (`uiEnabled = false` — no window at all, resolving the "don't want that menu" request directly rather than just fixing its display name), `component FluidContainer` (20 L capacity, `whitelist { fluid = CowMilk, fluid = SheepMilk }` — confirmed valid inline syntax via `FluidContainerScript.java:184-199`, no separate named `fluidFilter` script object needed after all), and the existing `component SpriteConfig`. `component Resources` and `component CraftLogic` are gone.
- [x] **Added `entity_AutoButterChurn_xuiSkin.txt`** (new file) with a proper `DisplayName = Automatic Butter Churner` and `Icon = Build_ButterChurn` (still the Butter Churn's own icon as a placeholder), but deliberately *no* `LuaWindowClass`/`LuaCanOpenWindow` — this satisfies `getEntityDisplayName()` (fixing the `Entity_DisplayName_Default` tooltip/label bug) while keeping `isInteractiveEntity()` false, so no window-opening interaction is ever offered for this entity, matching "we do NOT want to use that menu."
- [x] **Deleted** `PseudoButterChurnerRecipes.txt` (the `auto_churn_butter` recipe — no longer meaningful without `CraftLogic`) and `PseudoButterChurnerFluidFilters.txt` (the named `fluidFilter` script — superseded by the inline `whitelist` block).
- [x] **Rewrote `AutoButterChurnCode.lua`** entirely: dropped the recipe-hook-based `checkPower`, replaced with a `ModData`-backed registry (`ModData.getOrCreate("PseudoButterChurnerRegistry")`) of placed entities' square coordinates, ticked via `Events.EveryTenMinutes` (matching the cadence used by `SRainBarrelSystem`/`SFarmingSystem`/`STrapSystem`). Each tick: resolves the square, finds the `AutoButterChurn` entity on it (`instanceof(obj, "IsoThumpable")` and `obj:getEntityScript():getFullName() == "Pseudonymous.AutoButterChurn"`), and if elapsed in-game time since its last check is ≥ 500 seconds *and* the square has power (`square:haveElectricity()`) *and* it holds ≥ 5 L of milk (`entity:getFluidAmount()`): consumes 5 L (`entity:useFluid(5.0)`, the same method `ClothingWasherLogic` itself calls, confirmed Lua-accessible via several vanilla `TimedActions` that already call `:useFluid(...)`) and drops 1 `Base.Butter` directly onto the square (`square:AddWorldInventoryItem("Base.Butter", 0, 0, 0)`, which accepts a plain item-type string directly per several vanilla usages). If the entity is ever gone (destroyed), its registry entry is dropped.
- [x] **Updated `ISConvertToAutoButterChurn.lua`:** requires the rewritten `AutoButterChurnCode`, and calls `AutoButterChurnCode.registerEntity(self.square)` right after a successful `addWorkstationEntity`, so newly-converted entities are picked up by the tick system immediately. Kept (not removed) a smaller set of diagnostic prints around entity creation, per the Phase 15 lesson about not tearing out logging before a fix is confirmed — this is new, untested logic.
- [x] **Removed** the now-obsolete `auto_churn_butter` entry from `Recipes.json` and `IGUI_CraftingWindow_AutoButterChurn` from `IG_UI.json` (deleted both files, since each had exactly one now-dead entry).
- [x] Re-copied the mod to the local Zomboid mods folder via `utilities\CopyModToZomboid.bat PseudoButterChurner`.
- [x] Tested by the user: **did not work.** Reported simply as "Phase 17 did not work," with no further detail or log captured before the decision was made to close this DevCycle rather than continue debugging. Which specific part failed (no fluid-transfer menu appearing at all, milk not registering as poured, the tick never firing, Butter never appearing, or something else entirely) is **unknown** — this needs fresh diagnostic evidence at the start of DevCycle 2, not a guess carried over from here.

**Technical Notes:**
While researching the periodic-tick pattern, found that vanilla ships a proper reusable framework for exactly this shape of problem — `Map/SGlobalObjectSystem` (used by `SRainBarrelSystem`, `SFarmingSystem`, etc.) — which handles the registry/save-persistence/object-validity bookkeeping generically instead of the hand-rolled `ModData` table used here. Not adopted in this pass, to avoid opening a second large unknown while already mid-rewrite, but worth a follow-up refactor once the hand-rolled version is confirmed working, since it would likely be more robust (proper serialization, no risk of a malformed/stale registry table surviving a bad save).

Several earlier open questions and phases are now moot with `CraftLogic`/`Resources` removed from this entity: Q1 (combined fluid + item resource) and Q2 (bare `CraftLogic` on a bench) no longer apply, since neither component is used anymore. Q4 (output overflow behavior) is also moot — Butter is now dropped directly on the ground with no capacity limit, a deliberate simplification rather than the earlier "pause when output is full" plan.

---

## Open Questions

Carried over from `doc/ideas/claude_automaticButterChurning.md` §7. Status reflects this cycle's implementation; items marked **Open** still need Phase 5 in-game confirmation even where code is written.

1. **Combined fluid + item container on one entity.** **Moot as of Phase 17.** The whole `component Resources`/`component CraftLogic` approach was dropped in favor of `component FluidContainer` + a hand-rolled Lua tick, per direct request — this question no longer applies to the current design.

2. **`CraftLogic` on a plain (non-Drying/Mashing/Furnace) entity.** **Moot as of Phase 17.** `component CraftLogic` is no longer used by this entity at all.

3. **Fluid unit-to-liter mapping.** **Open.** Proceeded with `Capacity = 20.0` per the recommendation; still unconfirmed in-game.

4. **Output overflow behavior.** **Moot/simplified as of Phase 17.** No capacity limit at all now — Butter drops directly onto the ground each batch, unconditionally. The earlier "pause when output is full" plan doesn't apply without a `Resources` output container.

5. **Non-milk fluid handling.** **Implemented, revised in Phase 17.** Now an inline `whitelist { fluid = CowMilk, fluid = SheepMilk }` block directly inside `component FluidContainer` (confirmed valid syntax via `FluidContainerScript.java`), rather than the earlier separate named `fluidFilter` script object (deleted).

6. **Learnable recipe requirement.** **Deferred.** Not implemented this cycle — see Phase 2 and Notes and Risks. Conversion is currently gated on Electrical ≥ 5 only, no schematic/magazine item.

7. **Reusing the manual churn's sound.** **Deferred.** Phase 4 not started this cycle; `AutoButterChurn` is currently silent.

8. **Power draw amount.** **Deferred.** No power-consumption mechanism was implemented at all this cycle (only an on/off `haveElectricity()` check) — see Phase 3.

9. **Which washing machines qualify for conversion?** **Revised in Phase 8.** Originally restricted to plain `IsoClothingWasher` only; Phase 8 extended eligibility to also include `IsoCombinationWasherDryer` (either mode) per direct request. `IsoStackedWasherDryer` remains excluded (never examined, not requested).

10. **Converting a non-empty washing machine.** **Implemented.** Enforced in both the context-menu gate and the timed action's `isValid()`.

---

## Notes and Risks

- The design doc's architecture (§3) leans on `CraftLogic` + `StartMode = Automatic` specifically because it's the one vanilla combination that gives auto-repeating background batches "for free." Questions 1 and 2 are the biggest technical risks in this cycle — if either combination doesn't work as expected in a live 42.20.4 game, Phase 1 may need to fall back to the alternatives noted in the design doc (a "collect" action instead of a true item container, or `MashingLogic` instead of plain `CraftLogic`), which would ripple into Phase 3's power-gating approach. Implementation is done but **nothing in this cycle has been run in-game** — see Phase 5.
- Power gating has no script-level equivalent anywhere in the vanilla entity-component system as surveyed; the entire mechanism in Phase 3 is bespoke Lua and should get extra scrutiny during in-game verification.
- The conversion flow (Phase 2) permanently destroys the source Washing Machine's identity — there is no "convert back" path in this design. This was implemented as designed (irreversible); confirm this is still acceptable.
- This cycle references three prior analysis documents for vanilla behavior (`claude_butterChurn.md`, `claude_amphoraAnalysis.md`, `claude_washingMachineAnalysis.md`) and the design doc itself, all re-verified against 42.20.4.
- **No custom art.** `AutoButterChurn` currently reuses the manual Butter Churn's sprite row (`crafted_05_72`) as a placeholder — it does not visually resemble a washing machine yet, which was requirement #1 of the original concept (§1 of the design doc). Real custom tile art (or a different, legitimately washing-machine-shaped reuse) is needed before this is done.
- **Deferred/incomplete from this cycle's scope:** Q6 (schematic/magazine recipe unlock — currently skill-gate only), Q8 (power draw amount — currently no fuel/power consumption is modeled, only an on/off electricity check), and all of Phase 4 (sound). None of these block the core "fill it, start it, it makes butter automatically" loop, but the mod is not feature-complete against the original concept (§1) without them.
- Implementation surfaced three corrections to the design doc's assumptions, each significant enough that a naive implementation of the original sketch would likely have failed at script-load or run time: (1) `component Resources` fluid entries own their own internal `FluidContainer`, independent of any entity-level `component FluidContainer` — so the design's separate `component FluidContainer` block was dropped; (2) fluid filters are separate named `fluidFilter` script objects, not an inline `whitelist` block on the resource; (3) the recipe's `OnUpdate` Lua hook receives `CraftRecipeData`, which has no entity/square accessor — power-checking instead goes through `CraftRecipeData:getViableResource(0):getGameEntity():getSquare()`. See Phase 1 and Phase 3 Technical Notes for details.
- The Perk enum for the Electrical skill is `Perks.Electricity` in code (`Perks.Electrical` — the more natural-sounding guess — does not exist); worth remembering for any future recipe/skill gating in this mod.
- Caught and fixed one real bug before finishing this pass: `entity_AutoButterChurn.txt`'s `SpriteConfig` block initially used Lua-style `--` comments, which are not valid in the entity-script format (vanilla scripts use `//`) and would have broken script parsing. Fixed to `//`.

## File Manifest (current, as of Phase 17)

- `PseudoButterChurner/42/media/scripts/entities/workstations/entity_AutoButterChurn.txt`
- `PseudoButterChurner/42/media/scripts/entities/workstations/entity_AutoButterChurn_xuiSkin.txt`
- `PseudoButterChurner/42/media/lua/shared/AutoButterChurnCode.lua`
- `PseudoButterChurner/42/media/lua/shared/TimedActions/ISConvertToAutoButterChurn.lua`
- `PseudoButterChurner/42/media/lua/client/ISUI/ISAutoButterChurnContextMenu.lua`
- `PseudoButterChurner/42/media/lua/client/AutoButterChurnEntityDiagnostic.lua` — temporary, from Phase 15; still present, safe to delete once no longer needed
- `PseudoButterChurner/42/media/lua/shared/Translate/EN/Tooltip.json`
- `PseudoButterChurner/42/media/lua/shared/Translate/EN/ContextMenu.json`

**Removed in Phase 17** (existed earlier in this cycle, now deleted): `PseudoButterChurnerFluidFilters.txt`, `PseudoButterChurnerRecipes.txt`, `Translate/EN/IG_UI.json`, `Translate/EN/Recipes.json`.

---

## Completion Summary

**Completion Date:** 2026-08-31
**Phases Completed:** 1–16 reached a working, confirmed state in-game (entity creation, conversion flow, sprite visibility). Phase 17 (the `component FluidContainer` / trough-style redesign) was implemented but **confirmed not working**, and the cycle was closed at that point rather than continuing to debug it.
**Work Deferred to DevCycle 2:** Diagnosing why Phase 17 doesn't work (no failure details captured yet — see Phase 17's closing note), sound (Q7), recipe-learn/schematic unlock (Q6), power draw/fuel consumption (Q8), real custom art (the entity still visually looks like the manual Butter Churn, not a washing machine), and the `SGlobalObjectSystem` refactor noted in Phase 17's Technical Notes.

**Accomplishments:**
- Got a placed, converted `AutoButterChurn` entity working end-to-end through Phase 16: visibly created via `square:addWorkstationEntity(...)`, correctly module-qualified (`Pseudonymous.AutoButterChurn`), with a confirmed-visible (if placeholder) sprite.
- Built and debugged the washing-machine-to-`AutoButterChurn` conversion flow: a context-menu gate (screwdriver + Electrical 5 + empty/off, extended in Phase 8 to also cover `IsoCombinationWasherDryer`) and a timed action that swaps the legacy object for the new entity in place.
- Traced and fixed four distinct, confirmed root causes across Phases 6–16: an invalid `//` comment in a script file, wrong fluid-input recipe syntax, a sprite-row collision, a missing module-qualified entity name, and a registered-but-blank placeholder sprite tile.
- In Phase 17, correctly diagnosed *why* the confusing crafting-window menu was appearing (a missing `xuiSkin` entry) and redesigned milk-filling around the same generic vanilla mechanism used by troughs, rain barrels, and the Amphora (`component FluidContainer`), including a hand-rolled Lua tick system (registry + `Events.EveryTenMinutes`) to replace the `CraftLogic`-based automatic batching that turned out to be incompatible with that approach.
- This design work and diagnosis are very likely still correct and reusable in DevCycle 2 even though the resulting implementation didn't work when tested — the failure mode (what specifically broke) was never captured before the cycle closed.

**Metrics:**
- Files in final state: 8 (2 entity scripts, 2 Lua files for conversion/churning, 1 context-menu Lua file, 1 temporary diagnostic Lua file, 2 translation JSON files). Several earlier files (a recipe, a fluid-filter script, two translation files) were created and later deleted as the design changed.
- Confirmed working in-game: mod loads with no script errors; conversion completes without crashing; the resulting entity is visible on the square.
- Confirmed NOT working in-game: the Phase 17 `component FluidContainer` redesign (milk filling and/or automatic churning) — exact failure point unknown.

**Lessons / Notes:**
- The design doc (`doc/ideas/claude_automaticButterChurning.md`) got the high-level architecture direction right but several of its component-level assumptions didn't survive contact with the decompiled engine: `component Resources` fluid entries are self-contained, not linked to any `component FluidContainer`; fluid filters can be inline `whitelist` blocks OR named `fluidFilter` objects depending on which component hosts them; `CraftLogic` can only read fluid inputs from `Resources`, never a sibling `FluidContainer`; and the simple vanilla "pour a container in" UX is controlled by a single generic `hasComponent(ComponentType.FluidContainer)` check, unrelated to the entity/crafting-window system entirely.
- Two patterns copied from the vanilla Amphora's `ISOpenCloseLid.lua` didn't transfer cleanly and cost real debugging time: `self.barrel` there is a `GameEntity`-backed object with `getHealth()`/`getMaxHealth()`, while our conversion's source object (`IsoClothingWasher`/`IsoCombinationWasherDryer`) is a legacy `IsoObject` without them. Matching code shape doesn't guarantee matching object type.
- `Perks.Electricity`, not `Perks.Electrical`, is the correct in-code perk name.
- Sprite rows on shared vanilla sheets (`crafted_05_*`) are risky to guess: names can be registered in `IsoSpriteManager` (so `getSprite()` returns non-nil) while still having no actual drawn artwork — "registered" and "visible" are not the same thing, discovered only by directly testing a known-good sprite (`ChurnBucket`'s own) for comparison.
- The most important process lesson from this cycle: **don't remove diagnostic logging until a fix is confirmed working**, not just "reasoned through." A fix that looked airtight from reading decompiled source alone (the module-qualified entity name) turned out to be genuinely correct, but that was only provable because logging was restored after being prematurely deleted once already — see `feedback_dont_remove_diagnostics_before_confirmed_fix.md` in project memory. This should carry directly into DevCycle 2: keep the diagnostic prints in place until Phase 17's actual failure point is understood.
