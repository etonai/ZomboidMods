# DevCycle 002: Three Signal Boosters

**Status:** VERIFIED
**Start Date:** 2026-11-06
**Target Completion:** TBD
**Focus:** Add two more Signal Boosters so there are three (Signal Booster #1, #2 and #3). Each Booster can transport only to the Control. The Control's menu offers a transport to any of the three.

**Builds on:** `doc/planning/completed/DevCycle001.md` (Verified)
**Engine checks against:** v42.20.4 (`media42_20_4/`, `zombie42_20_4/`). Note from DevCycle 001: the installed game's `ISMoveableSpriteProps.lua` differs from the repo copy, so anything touching placement or pick-up must be confirmed in game.

---

## Goal

Turn the single pair into a hub: one Transporter Control and three numbered Signal Boosters. From a Booster the player goes to the Control. From the Control the player picks which Booster to go to.

## Desired Outcome

In a single-player game, a tester debug-spawns one Control and three Boosters, places them, and:

- right-clicking a Booster offers "Transport" and it moves the player to the Control, never to another Booster;
- right-clicking the Control offers a Transport choice with one entry each for Signal Booster #1, #2 and #3, and each entry moves the player to that Booster;
- ordinary road cones and Ham Radio 2s still never offer "Transport";
- the whole set still works after saving and reloading, and after any piece is picked up and placed elsewhere.

## Scope

| Topic | Decision for this cycle |
|---|---|
| Boosters | Three, titled Signal Booster #1, #2, #3. The existing Booster becomes #1 |
| Booster to Control | Each Booster transports to the Control only |
| Control to Booster | The Control's menu lists all three Boosters |
| Power | Unchanged: the Control needs power to initiate; Boosters do not |
| Limits and safeguards | None (unchanged) |
| Acquisition | Debug spawn only (unchanged) |
| Multiplayer | Not supported (unchanged) |
| Sound and visuals | None (unchanged) |

**Out of scope:** recipes, loot, multiplayer, effects, balance, more than three Boosters, Booster-to-Booster travel.

---

## Tasks

### Phase 1: Research

**Status:** Work Complete

- [ ] Decide how a player tells the three placed Boosters apart in the world (all would share the road-cone look). See Open Question 1.
- [ ] Confirm what the context menu receives for a placed Booster and how its role (#1, #2, #3) can be shown in the menu (for example in the Control's list).
- [ ] Find a safe way to migrate the DevCycle 001 registry key `booster` and the object marker value `"booster"` to `booster1`, or decide to keep both readable.
- [ ] Record findings in the Technical Notes below.

**Implementation notes:**
- Roles are `control`, `booster1`, `booster2`, `booster3`. Items: `TransporterSignalBooster` (#1), `TransporterSignalBooster2`, `TransporterSignalBooster3`, all on sprite `street_decoration_01_26` (Open Question 1: one sprite).
- Legacy migration: `PT.getRegistry()` moves a `booster` entry to `booster1`; `PT.getObjectRole()` maps marker value `"booster"` to `booster1`.
- Duplicates: the newest placement overwrites the registry entry; pick-up of an older duplicate clears the entry only if it still points at that square.
- Menus (`PseudoTransporterMenu.lua`): Booster -> single "Transport" to the Control, no power check. Control -> "Transport" submenu with Signal Booster #1/#2/#3, unplaced ones greyed out with a tooltip; unpowered Control keeps the greyed-out parent with a tooltip.
- Known limit: placement finds the inventory item by sprite, so carrying several Boosters may place a different number than intended; the placed number comes from the item actually placed.
- Not yet run in game.

### Phase 2: Items and roles

**Status:** Work Complete

- [ ] Add item scripts `TransporterSignalBooster2` and `TransporterSignalBooster3`. Keep `TransporterSignalBooster` as #1.
- [ ] Choose each Booster's world sprite (Open Question 1).
- [ ] Add display names: "Signal Booster #1", "Signal Booster #2", "Signal Booster #3" (English).
- [ ] Extend `PT.ITEM_ROLES` with roles `booster1`, `booster2`, `booster3` and keep the marker working through pick-up and re-placement for all three.

**Technical Notes:**
*To be filled in during the phase.*

### Phase 3: Registry for four ends

**Status:** Work Complete

- [ ] Change the registry to hold `control`, `booster1`, `booster2`, `booster3`, each `{x, y, z}`.
- [ ] Migrate an existing `booster` entry (and marked objects with role `booster`) to `booster1` so a DevCycle 001 save keeps working.
- [ ] Register and unregister each role on placement and pick-up, as in DevCycle 001.
- [ ] Decide what happens if a role is placed a second time while one is already registered (Open Question 3).
- [ ] Confirm the registry survives save and load.

**Technical Notes:**
*To be filled in during the phase.*

### Phase 4: Menus

**Status:** Work Complete

- [ ] A Booster's menu: "Transport" to the Control only (no power requirement).
- [ ] The Control's menu: a "Transport" entry that offers Signal Booster #1, #2 and #3, each moving the player to that Booster. Only the Control's own power check applies.
- [ ] Decide how an unplaced Booster appears in the Control's list (Open Question 2).
- [ ] If the chosen destination is missing or stale, nothing happens (the DevCycle 001 rule).
- [ ] Add the new text (menu labels, tooltips) in English.

**Technical Notes:**
*To be filled in during the phase.*

### Phase 5: In-game testing

**Status:** In Progress (not run; requires launching the game)

- [ ] Place the Control and all three Boosters. From each Booster, confirm "Transport" arrives at the Control.
- [ ] From the Control, confirm each of the three entries arrives at the matching Booster.
- [ ] Confirm a Booster never offers a trip to another Booster.
- [ ] Pick up and re-place each Booster and the Control; confirm the registry follows.
- [ ] Place only some of the Boosters and confirm the Control's list behaves as decided.
- [ ] Confirm vanilla road cones and Ham Radio 2s do **not** show "Transport".
- [ ] Save, quit, reload; confirm everything still works.
- [ ] Load a DevCycle 001 save with a placed Booster and confirm it becomes Signal Booster #1.
- [ ] Record the results in the Completion Summary.

**Technical Notes:**
*To be filled in during the phase.* Per `AGENTS.md` and `DevelopmentProcess.md`, work stops at **Work Complete**; only Ed can mark a phase or the cycle **Verified**.

---

## Open Questions

**Decided by Ed (2026-11-06): go with all recommendations below.**

1. **How should the three Boosters look in the world?**
   All three are road-cone look-alikes. If they share one sprite, the player can't tell them apart when placed, only by the Control's menu. Options: (a) keep one sprite for all three; (b) use the vanilla Road Cone, Road Cone 2 and another cone-like sprite; (c) show the booster's number in its own right-click menu. Recommendation: (a) plus (c) for this cycle, since the Control's list names each Booster and changing sprites risks the pick-up problem found in DevCycle 001. Please confirm.

2. **What does the Control's list show for a Booster that isn't placed?**
   Recommendation: show all three entries always, with unplaced ones greyed out and a tooltip saying that Booster isn't placed. (DevCycle 001 said "nothing happens" for a missing end; greying out is clearer but is a change.)

3. **What if a Booster of the same number is placed twice?**
   Debug spawn lets a tester place two #2 Boosters. Recommendation: the most recently placed one becomes the registered #2; the older one stays marked but no longer receives trips.

4. **Should a Booster's trip to the Control also require the Control to be powered?**
   In DevCycle 001 the Booster did not need power, and the Control gated only its own trips. Recommendation: keep it that way (Booster to Control never checks power).

5. **Should the Control's choice be a submenu or three separate entries?**
   Recommendation: one "Transport" entry that opens a submenu listing Signal Booster #1, #2 and #3.

---

## Notes and Risks

- **Placement hooks are the fragile part.** DevCycle 001's hooks into `ISMoveableSpriteProps` broke once on the installed game build. Adding two item types extends the same hooks, so any further surprise there will show up in Phase 5.
- **Save compatibility.** Existing saves hold a `booster` registry key and objects marked `"booster"`. Phase 3 must handle both.
- **Look-alikes.** Three Boosters sharing a sprite is a usability limit, not a bug. Open Question 1 decides whether to accept it.
- **No safeguards** by design (unchanged from DevCycle 001).
- Implementation requested by Ed on 2026-11-06.

---

## Completion Summary

*To be filled in at the end of the cycle.*
