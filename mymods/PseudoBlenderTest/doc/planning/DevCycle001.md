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

**Status:** VERIFIED

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
- Did not add icon, static model, or world model fields during the initial Phase 1 implementation. This kept the first test focused on item-script loading and left asset/model behavior for later Blender phases.


**Verification Notes:**

- Local script read-back completed.
- Brace count checked locally: opening and closing braces match.
- In-game load/spawn verification has not been performed yet, so the phase is `Work Complete`, not `Verified`.

---

### Phase 2: MagicCube Inventory Icon

**Status:** VERIFIED

- [x] Place `magiccube.png` into the mod's B42 texture load path.
- [x] Rename the deployed texture to the Project Zomboid item icon convention: `Item_MagicCube.png`.
- [x] Attach the icon to the `MagicCube` item script with `Icon = MagicCube`.
- [x] Read back the script file and check brace balance.
- [x] Record implementation notes and any in-game test results in this phase.

**Technical Notes:**
Project Zomboid item icons are loaded from `media/textures` using the `Item_` filename prefix while item scripts reference the icon name without that prefix. Phase 2 therefore deploys the source image as:

- Source image: `mymods/PseudoBlenderTest/img/magiccube.png`
- Runtime texture: `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/textures/Item_MagicCube.png`
- Item field: `Icon = MagicCube`

Implementation result:

- Created `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/textures/`.
- Copied `mymods/PseudoBlenderTest/img/magiccube.png` to `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/textures/Item_MagicCube.png`.
- Updated `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/scripts/items/PseudoBlenderTestItems.txt` so `MagicCube` uses `Icon = MagicCube`.


**Verification Notes:**

- Local script read-back completed.
- Brace count checked locally: opening and closing braces match.
- In-game icon verification has not been performed yet, so the phase is `Work Complete`, not `Verified`.

---
### Phase 3: MagicCube Cube FBX Static and World Model

**Status:** Work Complete

- [x] Wait for Ed to create/export a cube `.fbx` in Blender and provide the source file path.
- [x] Inspect the provided `.fbx` path and choose the mod runtime asset location under `PseudoBlenderTest/42/media/models_x/`.
- [x] Copy the `.fbx` into the chosen mod model folder using a stable MagicCube-oriented runtime filename.
- [x] Add or update a model script entry that gives the cube a script model name usable by item fields.
- [x] Point the `MagicCube` item at that model with `StaticModel = MagicCube` and `WorldStaticModel = MagicCube`.
- [x] Try a larger cube export after the first cube model does not work in-game.
- [x] Read back changed scripts and check brace balance.
- [x] Record implementation notes and in-game test results in this phase.

**Technical Notes:**
Existing B42 item scripts use `StaticModel` for the carried/preview item model and `WorldStaticModel` for the dropped world item model. Existing custom-model mods in this workspace place model assets under `media/models_x/` and define named model entries in script files with `mesh = ...` and, when needed, `texture = ...`.

Implemented item fields:

```txt
item MagicCube
{
    ...
    StaticModel = MagicCube,
    WorldStaticModel = MagicCube,
}
```

Implementation targets:

- First source model from Ed: `mymods/PseudoBlenderTest/img/cube01.fbx`.
- Second source model from Ed: `mymods/PseudoBlenderTest/img/cube02.fbx`.
- Runtime model asset: `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/models_x/WorldItems/MagicCube.fbx`.
- Model script: `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/scripts/PseudoBlenderTestModels.txt`.
- Item script: `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/scripts/items/PseudoBlenderTestItems.txt`.

Implementation result:

- Copied `mymods/PseudoBlenderTest/img/cube01.fbx` to `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/models_x/WorldItems/MagicCube.fbx` for the initial Phase 3 attempt.
- Added `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/scripts/PseudoBlenderTestModels.txt` with `model MagicCube` in `module Base` and `mesh = WorldItems/MagicCube`.
- Updated `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/scripts/items/PseudoBlenderTestItems.txt` with `imports { Base }`, `StaticModel = MagicCube`, and `WorldStaticModel = MagicCube`.
- Replaced the runtime model with `mymods/PseudoBlenderTest/img/cube02.fbx` after `cube01.fbx` did not work in-game.

**Verification Notes:**

- Local script read-back completed.
- Brace count checked locally: opening and closing braces match in the item and model scripts.
- `cube01.fbx` did not work in-game.
- `cube02.fbx` did not work in-game.
- Phase 3 is complete as a failed cube-model experiment, not `Verified`.

---

### Phase 4: MagicCube Known-Working SurvivalLamp FBX Test

**Status:** Work Complete

- [x] Accept `SurvivalLamp.fbx` from a working mod as a known-working model control test.
- [x] Copy `SurvivalLamp.fbx` into the existing MagicCube runtime model path.
- [x] Keep the same script model name and item fields so only the FBX payload changes.
- [x] Read back existing scripts and check brace balance.
- [x] Record implementation notes and pending in-game verification.

**Technical Notes:**
This phase isolates whether the issue is the cube FBX exports or the mod's script/model wiring. The model script still resolves `model MagicCube` to `mesh = WorldItems/MagicCube`, and the item still uses `StaticModel = MagicCube` and `WorldStaticModel = MagicCube`. Only the file at the runtime FBX path changed.

Implementation targets:

- Source model from Ed: `mymods/PseudoBlenderTest/img/SurvivalLamp.fbx`.
- Runtime model asset: `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/models_x/WorldItems/MagicCube.fbx`.
- Model script: `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/scripts/PseudoBlenderTestModels.txt`.
- Item script: `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/scripts/items/PseudoBlenderTestItems.txt`.

Implementation result:

- Replaced the runtime `MagicCube.fbx` payload with `mymods/PseudoBlenderTest/img/SurvivalLamp.fbx`.
- Left `PseudoBlenderTestModels.txt` unchanged: `model MagicCube` still uses `mesh = WorldItems/MagicCube`.
- Left `PseudoBlenderTestItems.txt` unchanged: `MagicCube` still uses `StaticModel = MagicCube` and `WorldStaticModel = MagicCube`.

**Verification Notes:**

- Local file hash check confirmed the runtime `MagicCube.fbx` matches `mymods/PseudoBlenderTest/img/SurvivalLamp.fbx`.
- Script brace balance remained valid for the item and model scripts.
- In-game verification: `SurvivalLamp.fbx` worked as the MagicCube runtime model.
- Caveat: the SurvivalLamp FBX is large and sometimes does not appear immediately or consistently, so visibility/scale can make a working model look absent.
- Follow-up caution: to be certain `cube01.fbx` and `cube02.fbx` truly failed, restore each cube FBX to the same runtime path and retest in-game while walking around/checking nearby views, in case the models were hidden, offset, too large, or otherwise difficult to see.

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
- `MagicCube` now has a custom inventory icon texture attached.
- In-game verification will be needed to confirm the item loads, appears in debug/spawn flows, behaves as a memento, and displays the custom icon.
- Phase 3 tried Ed's cube FBX exports as the `MagicCube` static/world model; both `cube01.fbx` and `cube02.fbx` did not work in-game.
- Phase 4 replaced the runtime model payload with known-working `SurvivalLamp.fbx` while keeping the MagicCube script wiring unchanged. It worked in-game, but its large/intermittent visibility means the earlier cube FBX failures should be retested before treating them as conclusive.

---

## Rolling Summary

**Cycle Status:** In Progress
**Closure:** This cycle is intentionally never closed.

**Current Phase:** Phase 4 - MagicCube Known-Working SurvivalLamp FBX Test
**Current Phase Status:** Work Complete

**Completed Experiments:**
- Phase 1 - `MagicCube` memento item script.
- Phase 2 - `MagicCube` inventory icon attachment.
- Phase 3 - `MagicCube` cube FBX static/world model attempts.
- Phase 4 - `MagicCube` SurvivalLamp FBX control model swap.

**Active / Pending Experiments:**
- Optional retest of `cube01.fbx` and `cube02.fbx` while moving/checking views, to rule out hidden or oversized model visibility issues.
- In-game verification for `MagicCube` item loading, custom icon rendering, and custom model rendering.

**Deferred Ideas:**
- Inventory rendering test.
- World placement or object behavior test.
