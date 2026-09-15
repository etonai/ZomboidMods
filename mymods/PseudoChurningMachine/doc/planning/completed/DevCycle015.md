# DevCycle 015: Swap Sprite to the White Washing Machine

**Status:** Verified — Complete
**Start Date:** 2026-09-14
**Target Completion:** 2026-09-14

---

## Goal

Purely cosmetic: change the Churning Machine's in-world tile from the Blue Combo Washer/Dryer (`appliances_laundry_01_0`) to the White Washing Machine, per Ed's own observation that it's sometimes `appliances_laundry_01_7`. This is motivated by realism (a top-loading washer fits a "churning" mechanism better than a front-loading combo unit) — **not** an attempt to fix idea #2's reclassification hypothesis (Wash Menu, wrong displayed name, borrowed inventory) from `doc/ideas/PseudoChurningMachineDC11Plus.md`. No assumption is made that this cycle changes or fixes anything beyond the visual.

**Background:** `claudeDocs/claude_washingMachineAnalysis.md` documents the real vanilla objects this sprite family is associated with — `IsoClothingWasher` (plain washer), `IsoClothingDryer` (plain dryer), and `IsoCombinationWasherDryer` (the combo unit the current `appliances_laundry_01_0` tile is named for, per `Mov_BlueComboWasherDryer` in `moveable.txt`). That doc is what originally established these are hard-coded `IsoObject` Java classes (not scripted entities), each driven by `ClothingWasherLogic`/`ClothingDryerLogic` with a fixed 90-in-game-minute cycle — the same underlying mechanism idea #2's reclassification hypothesis suspects our tile triggers. Worth a re-read if Phase 2 turns up a reclassification-related difference worth recording (e.g. a plain washer's single "Turn On"/"Turn Off" menu vs. the combo unit's mode-switching one) — the doc's own "Comparison to Other Analyzed Objects" table and per-object breakdown explain what each specific object variant actually does, in case the new tile resolves to a different one of the three.

## Desired Outcome

- The Churning Machine displays as the White Washing Machine tile in-world, not the Blue Combo Washer/Dryer.
- Confirmed in-game that `appliances_laundry_01_7` is in fact the correct tile — Ed's own note hedges "sometimes uses," so this needs verification, not assumption.
- No change to any existing gameplay logic: milk gate, Turn On/Off, the running sound (working since DevCycle 014), milk removal and butter generation (DC006/DC007), and the 10-minute cycle (DC010) all continue to work exactly as before — this is a single sprite-reference change, nothing else.
- If the tile turns out to change any reclassification-related symptom (Wash Menu wording, displayed name, the borrowed item-inventory capacity from idea #2), that's recorded as an incidental observation for idea #2's own still-open backlog item — not a goal of this cycle, and not something this cycle attempts to fix either way.

---

## Tasks

### Phase 1: Swap the tile

**Status:** Work Complete — in-game verification pending

- [x] Confirmed `appliances_laundry_01_7` is a real, valid tile in the same sprite sheet as the current `appliances_laundry_01_0` (`media42_20_4/lua/server/Items/ApplianceOverlays.lua:19`, a real overlay-mapped entry) — its specific visual (white, top-loading) is not independently confirmable from any decompiled source available to this project, so this remains Ed's in-game observation as the working candidate, not a confirmed fact until Phase 2 checks it.
- [x] Changed `entity_ChurningMachine.txt`'s `component SpriteConfig { face S { layer { row = appliances_laundry_01_0 } } }` to `row = appliances_laundry_01_7`. No other file was touched.

**Technical Notes:**

`entity_ChurningMachine.txt` line 37: `row = appliances_laundry_01_0` → `row = appliances_laundry_01_7`. Single-value change, exactly as scoped — nothing else in the entity script or `ChurningMachineCode.lua` references the sprite row.

### Phase 2: In-game verification

**Status:** Verified

- [x] Ran `utilities\CopyModToZomboid.bat PseudoChurningMachine` before testing.
- [x] **Confirmed by Ed: the Churning Machine now visually displays as the White Washing Machine** — `appliances_laundry_01_7` was the correct tile on the first try.
- Marked Verified by Ed's explicit direction (2026-09-14), per `DevelopmentProcess.md`'s permission-gated `Verified` status. The remaining checklist items (milk gate/Turn On/Off/running sound/butter generation/cycle length unaffected; any reclassification-symptom difference) were not individually itemized in this test — this DevCycle's only change was a single sprite-row value, touching no gameplay logic at all, so no regression is expected there, but it's recorded here as reasoned-about rather than explicitly re-tested this pass.

**Technical Notes:**

---

## Notes and Risks

- This is a purely cosmetic DevCycle. It is explicitly not motivated by, and not expected to resolve, idea #2's reclassification hypothesis — any observed change there is incidental information to record, not a goal.
- If Phase 2 finds `appliances_laundry_01_7` is wrong, finding the *correct* tile would need in-game tile browsing (the same limitation idea #7 already hit looking for a top-loading variant tile) — not something resolvable by more source reading.
- Per `AGENTS.md`, no implementation begins until Ed explicitly requests it — this document defines the plan only.

---

## Completion Summary

**Completion Date:** 2026-09-14

**Phases Completed:** Both phases (tile swap, in-game verification) completed and verified in a single session.

**Work Deferred:** None — this DevCycle's own Desired Outcome (correct tile, no other change) was fully met.

**Accomplishments:**
- The Churning Machine now displays as the White Washing Machine (`appliances_laundry_01_7`) instead of the Blue Combo Washer/Dryer (`appliances_laundry_01_0`) — confirmed correct on the first try, no need to search further tile indices.
- Single-value change (`entity_ChurningMachine.txt`'s `SpriteConfig.row`), nothing else touched — matches the low-risk pattern idea #6 already established for this file.

**Metrics:** 2 phases, 1 file changed, 1 line changed — the smallest DevCycle in this mod's history.

**Lessons / Notes:**
- Purely cosmetic changes scoped this tightly (a single data value, no logic touched) can be planned, implemented, and verified in one pass without needing the incremental, single-variable caution larger or riskier changes (like DC011-DC014's audio investigation) require.
- The reclassification-symptom observation from idea #2 (whether the Wash Menu/displayed name/borrowed inventory look different with this tile) was not explicitly checked or reported in this pass — worth asking about specifically if idea #2 is ever picked up, rather than assuming it was silently confirmed one way or the other here.
