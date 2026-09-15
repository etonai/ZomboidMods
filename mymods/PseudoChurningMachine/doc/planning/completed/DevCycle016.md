# DevCycle 016: Convert a Real White Washing Machine into a Churning Machine (Replacement-Based)

**Status:** Verified — Complete
**Start Date:** 2026-09-14
**Target Completion:** 2026-09-14

---

## Goal

Let a player convert a real, found-in-the-world White Washing Machine (`IsoClothingWasher`) into a Churning Machine, via idea #8's **replacement-based** approach from `doc/ideas/PseudoChurningMachineDC11Plus.md`: remove the real object and place our own scripted `Pseudonymous.ChurningMachine` entity in its square, rather than attaching a flag to the real object and running our logic alongside it (the flag-based approach DevCycle 013 tried and abandoned).

**Why replacement-based is now a much better fit than when idea #8 first considered it.** Idea #8's original analysis deprioritized replacement-based specifically because it "throws away the real object's audio/inventory 'for free' wins" — at the time, the scripted entity's own running sound was silent (not fixed until DevCycle 014) and the flag-based approach's main appeal was inheriting the real object's already-working audio. That reasoning no longer holds: the scripted entity now has fully working audio (DC014), a fully working `FluidContainer` and milk-to-butter cycle (DC005-DC010), and a correct visual (DC015, the White Washing Machine tile). Replacement-based no longer gives anything up — and it entirely sidesteps DC13's actual blocker (a real converted washer/dryer's fluid container being unreliable across different object instances, since replacement never touches or depends on the real object's container at all).

**Conversion requirement (per Ed):** a screwdriver in inventory and Electricity skill level 6. Assumed to be a *tool* requirement (checked, not consumed) — matching the pattern vanilla's own Moveable system uses for the generic "Electrician" screwdriver category (`ISMoveableDefinitions.lua:313`, `Base.Screwdriver`) — flagged as an assumption to confirm, not stated explicitly by Ed.

## Desired Outcome

- A player with a screwdriver in inventory and `Perks.Electricity` level 6+ sees a "Convert to Churning Machine" option when right-clicking a real, plain White Washing Machine (`IsoClothingWasher` — not the combo washer/dryer, not a dryer).
- A player missing either requirement does not see the option (or sees it clearly gated/unavailable) — no silent failure.
- Selecting the option removes the real washer object and places a working Churning Machine entity in its square — visually and functionally identical to one built normally via the existing `CraftRecipe`, including the working running sound (DC014), milk gate, and butter production.
- **Bonus phase:** the Churning Machine's `FluidContainer` capacity is increased from 20L to 50L, per idea #7's capacity precedent — applied directly to the existing entity, not as a second top-loading variant (idea #7's original framing was a *separate* top-loading entity; this cycle just raises the existing one's capacity, per Ed's literal request).
- No regression to existing behavior for machines built the normal way — this is an additional acquisition path, not a replacement for `CraftRecipe`.

---

## Tasks

### Phase 1: Research the replacement mechanism

**Status:** Work Complete

Both genuinely new technical questions for this mod were answered with a real, traceable vanilla mechanism — not left as an implementation-time guess.

- [x] **How to remove a real placed `IsoObject` from its square via Lua — confirmed: `square:transmitRemoveItemFromSquare(object)`.** Found in actual use in `media42_20_4/lua/server/BuildingObjects/ISBuildIsoEntity.lua:684` and `:978`, for exactly this kind of situation: replacing an existing placed object with a new one at the same square (vanilla's own multi-stage building-upgrade system uses it to remove a "previous stage" object before placing the next stage). It returns an index (`replacedObjectIndex`) that can be reused so the new object claims the same slot. This is server-side code (`ISBuildIsoEntity.lua` lives under `lua/server/`) — confirms this kind of world-mutating removal is expected to happen through server-authoritative code, not directly from a bare client-side `Events.OnFillWorldObjectContextMenu` handler. **Implication for Phase 2:** the actual removal + placement should happen inside a timed action (mirroring how every other build/convert flow in vanilla does it), not directly inside the context-menu callback itself — the context-menu option should only queue a timed action.
- [x] **How to place a new instance of our own scripted `Pseudonymous.ChurningMachine` entity at a square via Lua — confirmed: `GameEntityFactory.CreateIsoObjectEntity(thumpable, gameEntityScript, isFirstTimeCreated)`.** Found in the same file (`ISBuildIsoEntity.lua:674-680`), called on an already-constructed `IsoThumpable` to attach the entity script's components (`FluidContainer`, `ContextMenuConfig`, `CraftRecipe`, etc.) onto it — this is the exact call our own Churning Machine's normal `CraftRecipe`/`BuildWoodenStructureMedium` build flow already goes through under the hood, just never invoked manually by this mod before. After component attachment, `square:AddSpecialObject(thumpable, replacedObjectIndex)` (`ISBuildIsoEntity.lua:729`) is what actually places it on the square, optionally reusing the just-removed object's slot via the index from the removal call above.
  - **One real nuance carried into Phase 2, not fully resolved here:** `ISBuildIsoEntity:setInfo()` always builds an `IsoThumpable` — *except* when the entity script's `isProp()` is true, in which case it takes a completely different path (`ISMoveableSpriteProps:placeMoveableInternal(...)`, no `IsoThumpable` or `GameEntityFactory.CreateIsoObjectEntity` call at all). Our own `entity_ChurningMachine.txt` sets `SpriteConfig.isThumpable = false` — it's not yet confirmed from source which of these two paths actually applies to an entity with that specific flag combination (`isThumpable = false` is not the same script field as `isProp()`, and the relationship between them wasn't traced in this pass). **Phase 2 needs to confirm this before assuming the `IsoThumpable`/`GameEntityFactory` path applies as-is.**
- [x] **Confirmed `instanceof(object, "IsoClothingWasher")`** is the correct, narrow check for "a plain washer," excluding `IsoCombinationWasherDryer`/`IsoClothingDryer` (both real, distinct classes per `claudeDocs/claude_washingMachineAnalysis.md`) — matching "White Washing Machine" specifically.
- [x] **Confirmed the tool-check API, from a real vanilla precedent, not assumed:** `media42_20_4/lua/client/ISUI/ISWorldObjectContextMenu.lua:1264` checks `playerInv:containsTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)` — checking the generic `ItemTag.SCREWDRIVER` tag (matching any valid screwdriver item, not one specific item type) and excluding broken ones, which is a better match for "a screwdriver" than the originally-assumed `Base.Screwdriver`-specific type check. The skill check remains `playerObj:getPerkLevel(Perks.Electricity) >= 6`, already confirmed as the correct internal skill name by idea #8's own prior research.

**Technical Notes:**

Key APIs confirmed for Phase 2:
- Removal: `square:transmitRemoveItemFromSquare(object)` → returns an index.
- Placement: build an `IsoThumpable` (pending the `isProp()`/`isThumpable=false` nuance above) → `GameEntityFactory.CreateIsoObjectEntity(thumpable, gameEntityScript, isFirstTimeCreated)` → `square:AddSpecialObject(thumpable, replacedObjectIndex)`.
- Both should happen inside a timed action, not directly in the context-menu callback, matching vanilla's own server-authoritative pattern for world-mutating build/replace operations.
- Tool check: `playerInv:containsTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)`.
- Skill check: `playerObj:getPerkLevel(Perks.Electricity) >= 6`.
- Object-type check: `instanceof(object, "IsoClothingWasher")`.

**Technical Notes:**

### Phase 2: Implement the conversion action

**Status:** Verified

- [x] Hooked `Events.OnFillWorldObjectContextMenu` in `ChurningMachineCode.lua`, detecting a real plain `IsoClothingWasher` and adding a "Convert to Churning Machine" option gated on the screwdriver + Electricity-6 check from Phase 1 — greyed out with an explanatory tooltip if either requirement is missing, matching the existing milk-gate tooltip pattern already used elsewhere in this mod's own code.
- [x] On selection: queues a new timed action (`ISConvertWasherToChurningMachine`) that removes the real washer object and places a `Pseudonymous.ChurningMachine` entity at the same square, using Phase 1's researched APIs — done inside a timed action rather than directly in the menu callback, per Phase 1's own finding about vanilla's server-authoritative pattern for this kind of world mutation.
- [x] Confirmed the newly-placed entity is fully functional: Turn On/Off, running sound, milk gate, butter production, and the 10-minute cycle all work exactly as they do on a normally-built Churning Machine (Ed, 2026-09-14, after the Phase 5 crash fix).

**Technical Notes:**

New file: `PseudoChurningMachine/42/media/lua/shared/TimedActions/ISConvertWasherToChurningMachine.lua`:
- `complete()` resolves the Churning Machine's own entity script via `SpriteConfigManager.getObjectInfoFromSprite("appliances_laundry_01_7")` — reusing DC015's own sprite-row choice as a name-based lookup key, since this mod has no other way to look up its own entity script by name. `objectInfo:getScript():getParent()` extracts the actual `gameEntityScript` to pass onward, matching `ISBuildIsoEntity.lua`'s own exact call shape.
- Removes the real washer via `square:transmitRemoveItemFromSquare(self.object)`, capturing the returned index.
- Builds a minimal `IsoThumpable.new(getCell(), square, CHURNING_MACHINE_SPRITE, north)` (the 4-arg constructor, confirmed in Phase 1 not to require a builder-cursor table), attaches our entity's components via `GameEntityFactory.CreateIsoObjectEntity(thumpable, gameEntityScript, true)`, then places it via `square:AddSpecialObject(thumpable, replacedObjectIndex)` — reusing the removed object's slot.
- **Not yet confirmed:** whether this `IsoThumpable`-based path is actually correct for an entity whose own script sets `SpriteConfig.isThumpable = false` (the `isProp()` nuance flagged in Phase 1). If Phase 4 shows the placed object is broken/wrong, this is the first thing to revisit.
- Added `ContextMenu_ChurningMachine_Convert` to `ContextMenu.json` and `Tooltip_ChurningMachine_RequiresConversion` to `Tooltip.json` for the new option's label and gating tooltip.

### Phase 3 (Bonus): Increase capacity to 50L

**Status:** Verified

- [x] Changed `entity_ChurningMachine.txt`'s `component FluidContainer { Capacity = 20.0, ... }` to `Capacity = 50.0` — a single-value change, per idea #6's already-established low-risk pattern for this exact field. 50L / 5L = exactly 10 butter sticks on a full cycle; no remainder-math changes needed (nothing in `ChurningMachineCode.lua` hardcodes `20.0`, per idea #6's own prior confirmation — confirmed still true, `ChurningMachineCode.lua` was not touched for this phase).
- [x] Re-verify the existing DC006/DC007 milk-removal/butter-generation test matrix at the new capacity — Phase 4.

**Technical Notes:**

`entity_ChurningMachine.txt` line 22: `Capacity = 20.0` → `Capacity = 50.0`. Nothing else in the entity script or `ChurningMachineCode.lua` changed for this phase.

### Phase 4: In-game verification

**Status:** Verified

- [x] Ran `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [x] **Confirmed the 50L capacity is correct** (Ed, 2026-09-14).
- [X Confirm a player without a screwdriver or without Electricity level 6 does not get a usable "Convert to Churning Machine" option.
- [X] **Attempted conversion — crashed.** Selecting "Convert to Churning Machine" threw a Lua error and aborted the timed action before completing. See Phase 5.
- [X] Confirm a normally-built Churning Machine (via the existing `CraftRecipe`) is unaffected by this cycle's changes.
- [X] Confirm the 50L capacity bonus phase produces 10 butter sticks on a full cycle with a full load.

**Technical Notes:**

### Phase 5: Fix the `complete()` crash — `IsoObject` has no `getNorth()`

**Status:** Verified

**The error, as reported by Ed:**
```
Lua fail. Message: Object tried to call nil in complete
    Lua((MOD:PseudonymousEd's Churning Machine)).complete(ISConvertWasherToChurningMachine.lua:46)
```

- [x] **Root cause identified precisely, not guessed.** Line 46 was `local north = self.object:getNorth()`. `IsoObject.java` (confirmed by re-reading it directly) has **no `getNorth()` method at all** — `getNorth()`/`isNorth()`-style orientation is specific to `IsoThumpable` and other wall/door-like objects that support a north/west facing toggle. `IsoClothingWasher extends IsoObject` directly (not `IsoThumpable`), so a real washer has no orientation concept to read in the first place — this was an unverified assumption carried over from `ISBuildIsoEntity.lua`'s general-purpose build code (which does deal with genuinely orientable objects like walls and doors), not something actually confirmed for a washer specifically before Phase 2's implementation.
- [x] **Fix applied:** removed the `self.object:getNorth()` call entirely. Our own `entity_ChurningMachine.txt` only ever declares a single `face S` (no north-facing variant exists for this entity at all), so the `IsoThumpable.new(...)` call now passes a hardcoded `false` for its `north` parameter, matching the entity's own single-face design rather than trying to read a nonexistent orientation from the real washer being replaced.

**Technical Notes:**

`ISConvertWasherToChurningMachine.lua`: `local north = self.object:getNorth()` removed; `IsoThumpable.new(getCell(), square, CHURNING_MACHINE_SPRITE, north)` now uses `local north = false` (a fixed constant, with a comment explaining why), since the Churning Machine entity has no north-facing variant to select between.

### Phase 6: Match the Churning Machine's facing to the real washer's

**Status:** Verified

Per Ed: `appliances_laundry_01_4`, `_5`, `_6`, and `_7` are the four directions the real White Washing Machine can face. The converted Churning Machine should face the same direction as the real washer it replaced, instead of always using the fixed `appliances_laundry_01_7` regardless of the real object's actual orientation.

- [x] **Confirmed the compass-direction mapping isn't guesswork — found a real vanilla precedent.** `media42_20_4/scripts/generated/entities/appliances/workstations/entity_coffeemachine.txt` (a real vanilla appliance entity) declares all four faces with **consecutive sprite indices in a fixed order: `S, N, E, W` = `base+0, +1, +2, +3`** (`appliances_cooking_01_56..59`). Applied that same convention to our washer's four tiles: `_4`=S, `_5`=N, `_6`=E, `_7`=W. **This is inferred from one analogous entity's convention, not independently confirmed for this specific sprite sheet** — flagged for in-game verification in this phase's last task, same as originally planned.
- [x] Extended `entity_ChurningMachine.txt`'s `component SpriteConfig` to declare all four rows as separate `face` blocks (`S`→`_4`, `N`→`_5`, `E`→`_6`, `W`→`_7`) — required for `SpriteConfigManager.getObjectInfoFromSprite(...)` to resolve any of the four sprites to our entity's script, not just the one previously declared. (Attempted to add an inline comment explaining the ordering assumption directly in the script, but found no confirmed precedent for comment syntax in any actually-parsed script `.txt` in this project — reverted that and kept the rationale here instead, to avoid risking a script parse failure.)
- [x] Updated `ISConvertWasherToChurningMachine.lua`: captures `self.object:getSprite():getName()` before removing the real washer, validates it against the four known rows (`CHURNING_MACHINE_SPRITES` lookup table), and falls back to `appliances_laundry_01_7` with a logged message if unrecognized rather than failing outright. The captured/validated name is used for both the `SpriteConfigManager.getObjectInfoFromSprite(...)` lookup and the replacement `IsoThumpable`'s sprite — replacing the old hardcoded single-sprite constant entirely.
- [x] In-game verification: converted a real washer and confirmed the resulting Churning Machine's facing matches (Ed, 2026-09-14) — the S/N/E/W mapping guess held up.

**Technical Notes:**

- `entity_ChurningMachine.txt`: `component SpriteConfig` now declares `face S` (`_4`), `face N` (`_5`), `face E` (`_6`), `face W` (`_7`) instead of only `face S` (`_7`). As a side effect, a normally-built Churning Machine can now also be rotated among all four directions during placement, which it couldn't before this phase.
- `ISConvertWasherToChurningMachine.lua`: replaced the single `CHURNING_MACHINE_SPRITE` constant with a `CHURNING_MACHINE_SPRITES` lookup table (all four rows) plus a `DEFAULT_CHURNING_MACHINE_SPRITE` fallback; `complete()` now detects and reuses the real washer's own sprite instead of always using the same fixed one.

---

## Notes and Risks

- **Genuinely new technical territory for this mod:** removing a real placed object and programmatically placing a scripted entity via Lua have never been done here before — Phase 1's two research tasks are the real risk in this cycle, not the gating logic (which reuses already-confirmed patterns from idea #8's prior research and this mod's own milk-gate tooltip pattern).
- Scope is deliberately narrow: only the plain White Washing Machine (`IsoClothingWasher`), not the combo washer/dryer or a standalone dryer. Extending to those is a natural follow-on, not part of this cycle.
- The screwdriver requirement is assumed to be a check-only (not consumed) tool requirement — confirm with Ed if a consumed-material design was actually intended instead.
- Unlike DC13's flag-based approach, this cycle does not depend on the real washer's own `FluidContainer` being reliable at all — the real object is discarded entirely, sidestepping that unresolved problem completely.
- Per `AGENTS.md`, no implementation begins until Ed explicitly requests it — this document defines the plan only.

---

## Completion Summary

**Completion Date:** 2026-09-14

**Phases Completed:** All 6 phases (research, implementation, bonus capacity increase, verification, crash fix, facing fix) completed and verified in a single session.

**Work Deferred:** None — this DevCycle's own Desired Outcome was fully met. Combo washer/dryer and standalone-dryer conversion remain explicitly out of scope, as a natural follow-on rather than a gap in this cycle.

**Accomplishments:**
- A player with a screwdriver and Electricity level 6 can convert a real, found-in-the-world White Washing Machine into a fully functional Churning Machine — the first time this mod has removed a real placed object and programmatically placed its own scripted entity via Lua.
- Idea #8 from `PseudoChurningMachineDC11Plus.md` is now actually implemented (replacement-based), after being borrowed-but-abandoned in DC13 and left open ever since.
- Bonus: Churning Machine capacity raised from 20L to 50L (10 butter sticks per full cycle), per idea #7.
- The converted machine now faces the same direction as the real washer it replaced, using a mapping (`S,N,E,W` = consecutive sprite indices) inferred from a real vanilla appliance's own convention (`entity_coffeemachine.txt`) — confirmed correct in-game, not just assumed.
- One real bug found and fixed during verification: `IsoObject` has no `getNorth()` (that's specific to `IsoThumpable`/wall-like objects) — traced precisely rather than patched around.
- As a side effect of Phase 6, a normally-built Churning Machine can now also be rotated among all four directions during placement, which it couldn't before this cycle.

**Metrics:** 6 phases, 1 crash found and fixed, 2 new files created (`ISConvertWasherToChurningMachine.lua`, plus translation additions), 3 existing files modified (`entity_ChurningMachine.txt`, `ChurningMachineCode.lua`, `Tooltip.json`/`ContextMenu.json`).

**Lessons / Notes:**
- Genuinely new technical territory (removing a real object, programmatically placing a scripted entity) was de-risked correctly: Phase 1's research found real, traceable vanilla precedents (`transmitRemoveItemFromSquare`, `GameEntityFactory.CreateIsoObjectEntity`) before any code was written, rather than guessing at APIs during implementation.
- Even with that research, one wrong assumption slipped through (`IsoObject:getNorth()`, carried over from `ISBuildIsoEntity.lua`'s general-purpose code, which does handle genuinely orientable objects) — a reminder that research findings from adjacent/general-purpose code still need a final check against the *specific* object type being used, not just "does this pattern exist somewhere in vanilla."
- Phase 6's compass-direction mapping was resolved the same way Phase 1's mechanism questions were: by finding a real, analogous vanilla example (`entity_coffeemachine.txt`) rather than guessing — and explicitly flagging the inference as unconfirmed until in-game verification, rather than presenting it as settled fact. It held up.
- This cycle is a good contrast with DC13: both attempted real-object interaction, but DC13 (flag-based, kept the real object) hit an unresolved reliability wall and was abandoned, while DC16 (replacement-based, discards the real object) succeeded — direct, in-cycle confirmation that idea #8's own original analysis was right to flag replacement-based as the more robust of the two approaches once audio/visual/functionality were no longer reasons to prefer flag-based.
