# DevCycle 003: Placeholder Churning Machine Object

**Status:** Planning
**Start Date:** 2026-09-12
**Target Completion:** TBD
**Focus:** Build a placeholder PseudoChurningMachine object with no functionality yet.

---

## Goal

Implement Step 3 of `PseudoChurningMachinePlan.md`: give the player a way to construct a Churning Machine object in the world, using a placeholder recipe. At the end of this cycle the object exists, looks correct, and blocks movement — nothing more.

## Desired Outcome

- The player can craft/place a Churning Machine using a placeholder recipe: 1 plank + 1 nail.
- The placed object visually looks like the Blue Combo Washer/Dryer.
- The object has no functionality: no menu items, no container, no liquid capacity — it is inert.
- The object is solid (cannot be walked through), same as the real washer/dryer.

---

## Tasks

### Phase 1: Research placement/construction approach

**Status:** Planning

- [ ] Confirm how the Blue Combo Washer/Dryer's sprite/graphic is referenced, per `claude_washingMachineAnalysis.md`.
- [ ] Review how `PseudoSaltWell` (in `mymods/PseudoSaltWell`) implements a simple tool-driven construction of a custom-graphic object, as a reference pattern if a comparable approach fits here.
- [ ] Decide whether the Churning Machine should be a new custom entity/sprite or reuse the Blue Combo Washer/Dryer's existing sprite directly.

**Technical Notes:**


### Phase 2: Placeholder recipe and object

**Status:** Planning

- [ ] Add a placeholder build recipe: 1 `Base.Plank` + 1 `Base.Nails`.
- [ ] Define the Churning Machine object/entity so it renders using the Blue Combo Washer/Dryer appearance.
- [ ] Ensure the built object is solid (not walkable).
- [ ] Confirm the object has zero functionality at this stage (no context menu actions, no container).

**Technical Notes:**


### Phase 3: In-game verification

**Status:** Planning

- [ ] Build the Churning Machine in-game using the placeholder recipe.
- [ ] Confirm appearance matches the Blue Combo Washer/Dryer.
- [ ] Confirm the player cannot walk through the placed object.
- [ ] Confirm no menu items or interactions are present beyond default object behavior.

**Technical Notes:**


---

## Notes and Risks

- This is a placeholder recipe only — the real build materials/recipe are deferred to Step 11 planning, per `PseudoChurningMachinePlan.md`.
- No liquid container, Turn On action, or fullness/butter logic belongs in this cycle — those are Steps 4-9, each getting their own DevCycle.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**

**Lessons / Notes:**
