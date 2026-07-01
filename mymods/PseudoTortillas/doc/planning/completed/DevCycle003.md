# DevCycle 003: Remove Salt and Require Rolling Pin

**Status:** Work Complete
**Start Date:** 2026-06-26
**Target Completion:** TBD
**Focus:** Update the raw tortilla recipe by removing salt and requiring a kept rolling pin.

---

## Goal

Adjust `MakeRawTortillas` so salt is no longer an ingredient and a rolling pin is required to shape the tortillas. The change should follow vanilla Project Zomboid B42 baking patterns for rolling pin requirements while preserving the existing flour/cornflour, baking-fat, water, output, and cooking behavior from prior cycles.

## Desired Outcome

The mod loads without script errors. `MakeRawTortillas` requires a rolling pin that is kept after crafting, accepts 60 units of flour/cornflour, accepts 3 units of `base:bakingfat`, consumes 0.25 liters of water, and outputs 4 raw tortillas. The recipe no longer requires or consumes salt.

---

## Tasks

### Phase 1: Update Recipe Inputs

**Status:** Work Complete

- [x] Remove the salt input line from `MakeRawTortillas`: `item 1 [Base.Salt]`.
- [x] Add a kept rolling pin input to `MakeRawTortillas`.
- [x] Implemented as `item 1 tags[base:rollingpin] mode:keep flags[MayDegrade]`.
- [x] Leave flour/cornflour as `item 60 tags[base:flour]`.
- [x] Leave baking fat as `item 3 tags[base:bakingfat]`.
- [x] Leave water as `-fluid 0.25 [Water]`.
- [x] Leave output as `item 4 Pseudonymous.RawTortilla`.

**Technical Notes:**
Vanilla B42 baking recipes require rolling pins in several forms. `MakeBreadDough` uses `item 1 [Base.RollingPin] mode:keep flags[MayDegrade]` in `media/scripts/generated/recipes/recipes_baking.txt:190`. `MakePieDough` and `MakeBaguetteDough` use the broader `item 1 tags[base:rollingpin] mode:keep flags[MayDegrade]` pattern at `recipes_baking.txt:162` and `recipes_baking.txt:214`. Since vanilla `Base.RollingPin` carries `Tags = base:rollingpin` in `media/scripts/generated/items/weapon.txt:4467`, use the tag-based pattern for compatibility while preserving vanilla's kept-but-may-degrade behavior.

### Phase 2: Static Verification and Deploy

**Status:** Work Complete

- [x] Confirm `PseudoTortillasRecipes.txt` no longer contains `Base.Salt` in `MakeRawTortillas`.
- [x] Confirm `PseudoTortillasRecipes.txt` contains `item 1 tags[base:rollingpin] mode:keep flags[MayDegrade]`.
- [x] Confirm flour/cornflour, baking fat, water, and output lines are unchanged.
- [x] Deploy the mod with `utilities/CopyModToZomboid.bat PseudoTortillas` after implementation.

**Technical Notes:**
The deploy batch mirrors `mymods/PseudoTortillas/PseudoTortillas` into the Project Zomboid mods folder and excludes docs. It may require permission because it writes outside the workspace.

---

## Open Questions

*None at cycle start.*

---

## Notes and Risks

- Do not mark this cycle `Verified` without Ed's explicit approval.
- This cycle intentionally removes salt from the tortilla recipe rather than making it optional.
- The rolling pin should be kept, matching vanilla baking behavior; `flags[MayDegrade]` means it may lose condition but is not consumed.
- Per `mymods/PseudoTortillas/AGENTS.md`, agents should stop after creating this DevCycle document and wait for an explicit implementation request.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:** 2026-06-26
**Phases Completed:** All implementation, static verification, and deployment tasks
**Work Deferred:** In-game verification is not recorded; do not mark Verified without Ed approval.

**Accomplishments:**
- Removed `Base.Salt` from `MakeRawTortillas`.
- Added a kept rolling pin input using `item 1 tags[base:rollingpin] mode:keep flags[MayDegrade]`.
- Deployed the updated mod with `utilities/CopyModToZomboid.bat PseudoTortillas`.

**Metrics:**
- Files modified: 2 (`PseudoTortillasRecipes.txt`, `DevCycle003.md`)
- Deployments: 1 successful robocopy deployment; 1 file copied, 0 failures

**Lessons / Notes:**
Static verification confirmed the recipe no longer contains `Base.Salt`, now requires a kept rolling pin, and still uses 60 flour/cornflour units, 3 baking-fat units, 0.25 water, and outputs 4 raw tortillas.
