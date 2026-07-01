# DevCycle 001: Rolling Object Tests

**Status:** In Progress
**Start Date:** 2026-06-30
**Target Completion:** Rolling / never closed
**Focus:** Maintain a living record of object and item experiments for the PseudoBlenderTest mod.

---

## Rolling Cycle Policy

This DevCycle is intentionally different from normal closed DevCycles. It is a rolling test document for `PseudoBlenderTest` and should remain active indefinitely.

New experiments should be added as new phases. Completed phases may be marked `Work Complete` after implementation and local verification, but the overall DevCycle should not be moved to `completed/` or treated as closed. As always, no phase should be marked `Verified` unless Ed explicitly approves that status.

## Goal

Use `PseudoBlenderTest` as a small B42 test mod for experimenting with custom Project Zomboid objects, items, models, icons, and related script behavior. The document should track each experiment clearly enough that future work can see what was attempted, which files changed, what worked, and what still needs in-game confirmation.

The first experiment is a simple memento item named `MagicCube`. It should establish the basic item-script path and provide a known object item to build on during later Blender/model tests.

## Desired Outcome

`PseudoBlenderTest` has a living development record. The first planned phase defines a `MagicCube` item with weight `0.5`, classified as a memento item, and ready to be implemented in the mod's B42 script tree.

---

## Phases

### Phase 1: MagicCube Memento Item

**Status:** Work Complete

- [x] Inspect vanilla B42 memento item examples for the minimum item fields and tags.
- [x] Create the mod script folder under `PseudoBlenderTest/42/media/scripts/items/` if it does not already exist.
- [x] Add a B42 item script defining `MagicCube`.
- [x] Set `DisplayName = Magic Cube`.
- [x] Set `DisplayCategory = Memento`.
- [x] Set `Weight = 0.5`.
- [x] Add the memento tag using the vanilla pattern: `Tags = base:ismemento`.
- [x] Add or choose basic icon/model placeholders if required for the first item load test.
- [x] Read back the script file and check brace balance.
- [x] Record implementation notes and any in-game test results in this phase.

**Technical Notes:**
Vanilla memento examples use `DisplayCategory = Memento`, `ItemType = base:normal`, and the `base:ismemento` tag in generated item scripts. Initial implementation follows that minimal pattern before adding custom Blender model references.

Implementation target:

- `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/scripts/items/PseudoBlenderTestItems.txt`

Implemented item shape:

```txt
module Pseudonymous
{

    item MagicCube
    {
        DisplayName = Magic Cube,
        DisplayCategory = Memento,
        Type = Normal,
        ItemType = base:normal,
        Weight = 0.5,
        Tags = base:ismemento,
    }

}
```

Implementation result:

- Added `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/scripts/items/PseudoBlenderTestItems.txt`.
- Used module `Pseudonymous` for consistency with existing PseudonymousEd mods.
- Defined `MagicCube` with `DisplayName = Magic Cube`, `DisplayCategory = Memento`, `Type = Normal`, `ItemType = base:normal`, `Weight = 0.5`, and `Tags = base:ismemento`.
- Did not add icon, static model, or world model fields in Phase 1. This keeps the first test focused on item-script loading and leaves asset/model behavior for later Blender phases.

**Verification Notes:**

- Local script read-back completed.
- Brace count checked locally: opening and closing braces match.
- In-game load/spawn verification has not been performed yet, so the phase is `Work Complete`, not `Verified`.

---

## Phase Log

Add future phases below this line. Each phase should include status, tasks, implementation notes, verification notes, and any follow-up ideas.

---

## Open Questions

1. **Should `MagicCube` use a placeholder vanilla icon/model in Phase 1?**
   Resolved for Phase 1: no placeholder icon/model was added. Custom or placeholder asset tests should be added as a later phase.

2. **Should the item module be `Pseudonymous` or `PseudoBlenderTest`?**
   Resolved for Phase 1: use `Pseudonymous` for consistency with existing PseudonymousEd mods.

---

## Notes and Risks

- This is a rolling DevCycle and should remain active indefinitely.
- The mod's `AGENTS.md` says agents must stop after creating a DevCycle document and wait for explicit user approval before implementation.
- `MagicCube` item script has been added.
- In-game verification will be needed to confirm the item loads, appears in debug/spawn flows, and behaves as a memento.

---

## Rolling Summary

**Cycle Status:** In Progress
**Closure:** This cycle is intentionally never closed.

**Current Phase:** Phase 1 - MagicCube Memento Item
**Current Phase Status:** Work Complete

**Completed Experiments:**
- Phase 1 - `MagicCube` memento item script.

**Active / Pending Experiments:**
- In-game verification for `MagicCube`.

**Deferred Ideas:**
- Custom icon test.
- Custom static/world model test from Blender assets.
- Inventory rendering test.
- World placement or object behavior test.
