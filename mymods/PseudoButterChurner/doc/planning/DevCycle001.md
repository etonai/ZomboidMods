# DevCycle 001: Automatic Butter Churner Foundation

**Status:** In Progress
**Start Date:** 2026-08-30
**Target Completion:** TBD
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
- [ ] Launch B42 with `PseudoButterChurner` enabled and confirm there are no script parse errors.
- [ ] Confirm the entity's crafting UI panel actually opens on interaction and behaves as expected for a plain `CraftLogic` host (Phase 2 assumption).
- [ ] Convert a washing machine in-game and confirm the `AutoButterChurn` entity appears correctly.
- [ ] Fill the entity with milk, start it, and confirm it produces butter automatically every 500 in-game seconds without further interaction.
- [ ] Confirm power loss mid-cycle correctly halts production via `AutoButterChurnCode.checkPower` (Phase 3), and that `getViableResource(0)` is actually populated with the milk resource when this hook fires.
- [ ] Confirm output-overflow pausing behavior (Q4, via `CraftLogic`'s own free-output-slot gating) and non-milk fluid rejection (Q5, via the `AutoButterChurnMilk` fluid filter) both behave as designed.
- [ ] Confirm the fluid `Resources` group entry (`Fluid@Input@20.0@AutoButterChurnMilk@null@null`) parses and creates a working 20 L milk-only input as intended (Q1/Q2/Q3, and the Phase 1 `FluidContainer`-vs-`Resources` correction).

**Technical Notes:**
In-game verification is required before marking this cycle `Verified`. Agents may move implementation phases to `Work Complete` after static checks, but only Ed can approve `Verified` status, per `doc/planning/DevelopmentProcess.md`. Nothing in this DevCycle has been run in a live game yet — everything above the unchecked items is a static/code-level check only.

---

## Open Questions

Carried over from `doc/ideas/claude_automaticButterChurning.md` §7. Status reflects this cycle's implementation; items marked **Open** still need Phase 5 in-game confirmation even where code is written.

1. **Combined fluid + item container on one entity.** **Implemented, unverified in-game.** Turned out to be moot as originally framed: `component Resources` fluid entries are self-contained (own internal `FluidContainer`), so there's no conflict with a separate item-output resource in the same `Resources` component — both live in the same component, just different resource groups. Code written; needs Phase 5 confirmation it actually loads and behaves correctly.

2. **`CraftLogic` on a plain (non-Drying/Mashing/Furnace) entity.** **Implemented, unverified in-game.** Prototyped with plain `CraftLogic` per the recommendation. Needs Phase 5 confirmation.

3. **Fluid unit-to-liter mapping.** **Open.** Proceeded with `Capacity = 20.0` per the recommendation; still unconfirmed in-game.

4. **Output overflow behavior.** **Resolved, no custom code needed.** `CraftLogic`'s own `willOutputsAccommodate()`/`getFreeOutputSlotCount()` already implements exactly the recommended "pause when output can't fit" behavior natively — see Phase 1 Technical Notes.

5. **Non-milk fluid handling.** **Implemented.** `fluidFilter AutoButterChurnMilk` whitelists Cow Milk + Sheep Milk, referenced by the `Resources` fluid entry.

6. **Learnable recipe requirement.** **Deferred.** Not implemented this cycle — see Phase 2 and Notes and Risks. Conversion is currently gated on Electrical ≥ 5 only, no schematic/magazine item.

7. **Reusing the manual churn's sound.** **Deferred.** Phase 4 not started this cycle; `AutoButterChurn` is currently silent.

8. **Power draw amount.** **Deferred.** No power-consumption mechanism was implemented at all this cycle (only an on/off `haveElectricity()` check) — see Phase 3.

9. **Which washing machines qualify for conversion?** **Implemented.** Restricted to plain `IsoClothingWasher` via `instanceof` check.

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

## File Manifest (this cycle)

- `PseudoButterChurner/42/media/scripts/entities/workstations/entity_AutoButterChurn.txt`
- `PseudoButterChurner/42/media/scripts/fluids/PseudoButterChurnerFluidFilters.txt`
- `PseudoButterChurner/42/media/scripts/recipes/PseudoButterChurnerRecipes.txt`
- `PseudoButterChurner/42/media/lua/shared/AutoButterChurnCode.lua`
- `PseudoButterChurner/42/media/lua/shared/TimedActions/ISConvertToAutoButterChurn.lua`
- `PseudoButterChurner/42/media/lua/client/ISUI/ISAutoButterChurnContextMenu.lua`
- `PseudoButterChurner/42/media/lua/shared/Translate/EN/IG_UI.json`
- `PseudoButterChurner/42/media/lua/shared/Translate/EN/Recipes.json`
- `PseudoButterChurner/42/media/lua/shared/Translate/EN/Tooltip.json`
- `PseudoButterChurner/42/media/lua/shared/Translate/EN/ContextMenu.json`

---

## Completion Summary

*This cycle is not yet closed — do not move to `doc/planning/completed/` yet. Filled in early per current progress; revise when the cycle actually closes.*

**Completion Date:** Not yet closed.
**Phases Completed:** 1, 2, 3 (implementation done; static checks only, no in-game verification). Phase 5 partially done (static checks). Phase 4 not started.
**Work Deferred:** Sound (Phase 4, Q7), recipe-learn/schematic unlock (Q6), power draw/fuel consumption (Q8) — all pushed to a future DevCycle. All in-game verification (Phase 5's unchecked items) is pending.

**Accomplishments:**
- Implemented the `AutoButterChurn` scripted entity (`Resources` + `CraftLogic` with `StartMode = Automatic`), corrected from the design doc's original sketch after tracing the decompiled resource system (no separate `FluidContainer` component; fluid filtering via a named `fluidFilter` script object).
- Implemented the `auto_churn_butter` recipe (5 L milk → 1 Butter, `time = 500`, tagged for `AutoButterChurn`).
- Implemented the washing-machine-to-`AutoButterChurn` conversion flow: context-menu gate (screwdriver + Electrical 5 + empty/off) and a custom timed action swapping the legacy `IsoClothingWasher` for the new entity in place.
- Implemented power gating via the recipe's `OnUpdate` hook, using a verified `CraftRecipeData → Resource → GameEntity → CraftLogic component` chain (not the design doc's speculative `getCharacter()` path) to force-stop the craft when its square loses power.
- Added all required translation strings (entity name, recipe name, tooltips, context-menu option).
- Found and fixed one real defect before finishing: Lua-style `--` comments in `entity_AutoButterChurn.txt`, which are not valid in this script format, would have broken script loading.

**Metrics:**
- Files created: 10 (1 entity script, 1 fluid filter script, 1 recipe script, 3 Lua files, 4 translation JSON files).
- Static checks passed: all new JSON validated as well-formed; all referenced vanilla identifiers cross-checked against decompiled 42.20.4 sources.
- In-game checks completed: none.

**Lessons / Notes:**
- The design doc (`doc/ideas/claude_automaticButterChurning.md`) got the high-level architecture right (`CraftLogic` + `StartMode = Automatic`) but its component-level sketch in §4 had three assumptions that didn't survive contact with the decompiled resource/crafting-recipe system: the `FluidContainer` component, the inline fluid `whitelist` block, and the `OnUpdate` hook's `getCharacter()`-based power check. All three are documented with their corrected replacements in the Phase 1 and Phase 3 Technical Notes above — useful precedent for future entity-based DevCycles in this mod family.
- `Perks.Electricity`, not `Perks.Electrical`, is the correct in-code perk name for the Electrical skill.
- This cycle is a good example of why Phase 5 exists as a separate, explicitly-gated step: a substantial amount of plausible-looking script/Lua was written and cross-checked against decompiled source, but none of it has been proven to actually work in a running game yet.
