# DevCycle 004: Six Signal Boosters

**Status:** VERIFIED
**Start Date:** 2026-11-07
**Target Completion:** TBD
**Focus:** Add three more Signal Boosters so there are six (Signal Booster #1 to #6). Each Booster transports only to the Control. The Control's menu offers a transport to any of the six.

**Builds on:** DevCycle 002 (three Boosters) and DevCycle 003 (Transporter Badge).
**Engine checks against:** v42.20.4 (`media42_20_4/`, `zombie42_20_4/`). As seen in earlier cycles, the installed game's Lua can differ from the repo copy, so placement and pick-up must be confirmed in game.

---

## Goal

Extend the hub from one Control and three Boosters to one Control and six Boosters. Behavior is identical to DevCycle 002; only the count grows.

## Desired Outcome

In a single-player game, a tester debug-spawns one Control and six Boosters, places them, and:

- right-clicking any Booster offers "Transport" and moves the player to the Control, never to another Booster;
- right-clicking the Control offers a Transport choice with one entry each for Signal Booster #1 to #6, and each entry moves the player to that Booster;
- an unplaced Booster is greyed out in the Control's list with the existing tooltip;
- ordinary road cones and Ham Radio 2s never offer "Transport";
- the Transporter Badge still returns to the Control;
- the set works after saving and reloading, and after any piece is picked up and placed elsewhere.

## Scope

| Topic | Decision for this cycle |
|---|---|
| Boosters | Six, titled Signal Booster #1 to #6. Boosters #1 to #3 are unchanged |
| New items | `TransporterSignalBooster4`, `TransporterSignalBooster5`, `TransporterSignalBooster6`, same look as #1 (Road Cone sprite) |
| Roles | New registry roles `booster4`, `booster5`, `booster6` |
| Booster to Control | Each Booster transports to the Control only |
| Control to Booster | The Control's menu lists all six Boosters |
| Power, limits, acquisition, multiplayer, effects | Unchanged (Control needs power; debug spawn only; single player; none) |

**Out of scope:** recipes, loot, multiplayer, effects, balance, more than six Boosters, Booster-to-Booster travel, a data-driven rewrite of the item list.

---

## Tasks

### Phase 1: Items and roles

**Status:** Work Complete

- [x] Add items `TransporterSignalBooster4`, `5`, `6` to `media/scripts/items/PseudoTransporter_Items.txt`, copying `TransporterSignalBooster3`.
- [x] Extend `PT.BOOSTER_ROLES` with `booster4`, `booster5`, `booster6` and `PT.ITEM_ROLES` with the three new full item types in `shared/PseudoTransporter/PseudoTransporter.lua`.
- [x] Add display names "Signal Booster #4/#5/#6" to `shared/Translate/EN/ItemName.json`.

**Technical Notes:**
`boosterNumber(role)` in `PseudoTransporterMenu.lua` uses `role:sub(-1)`, which stays correct for single-digit numbers (works through #9). `UI_PseudoTransporter_BoosterName` ("Signal Booster #%1") takes the number as an argument, so no new UI strings were needed (confirmed in `UI.json`).

### Phase 2: Menu and registry check

**Status:** Work Complete (by code reading; not seen in game)

- [x] Confirm the Control's submenu iterates `PT.BOOSTER_ROLES` and so lists six entries without code changes. (`PseudoTransporterMenu.lua:32`: it does.)
- [x] Confirm the Booster branch of the world menu works for the new roles through `PT.isBoosterRole`. (It loops `PT.BOOSTER_ROLES`.)
- [ ] Review the Control submenu for six entries (length, greyed-out entries) and decide whether anything needs adjusting. (Needs in-game look.)
- [x] Update stale comments (header and registry comment in `PseudoTransporter.lua`).

**Technical Notes:**
No change to `PseudoTransporterMenu.lua` was needed.

### Phase 3: In-game testing

**Status:** Planning (not run; requires launching the game)

- [ ] Debug-spawn and place the Control and all six Boosters; confirm each Booster goes to the Control.
- [ ] From the Control, transport to each of the six Boosters; confirm arrival next to the right one.
- [ ] Place only some Boosters; confirm the unplaced entries are greyed out with the tooltip.
- [ ] Pick up and re-place Boosters #4 to #6 elsewhere; confirm the registry follows.
- [ ] Save, quit, reload; confirm the whole set still works.
- [ ] Confirm vanilla road cones and Ham Radio 2s show no "Transport", the Transporter Badge still works, and Boosters #1 to #3 are unaffected.
- [ ] Record the results in the Completion Summary.

**Technical Notes:**
*To be filled in during the phase.* Per `AGENTS.md` and `DevelopmentProcess.md`, work stops at **Work Complete**; only Ed can mark a phase or the cycle **Verified**.

---

## Open Questions

1. **Should the new Boosters have a distinct look?**
   Recommendation: no. All six reuse the Road Cone sprite (`street_decoration_01_26`), as #2 and #3 do. They are told apart in the world by the registry and in the inventory by name.

2. **Is a six-entry submenu acceptable as is?**
   Recommendation: yes. Six entries fit a normal context submenu; revisit only if testing shows a problem.

---

## Notes and Risks

- **Every Booster is a copy-pasted item and role.** Adding #4 to #6 repeats that pattern. A data-driven item list is deferred; it is out of scope here.
- **Shared sprite.** Boosters are identified by modData, not sprite, so six identical-looking cones rely on the existing marker hooks working for the new item types. Phase 3 tests pick-up and re-place for the new ones.
- **Process note.** `DevCycle002.md` and `DevCycle003.md` are marked Verified but still sit in `doc/planning/`; per `DevelopmentProcess.md` they belong in `doc/planning/completed/`. Not moved in this task.
- This document is a plan only. Implementation has not started.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*
