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
### Phase 5: Match OilLamps SurvivalLamp Model Parameters

**Status:** Work Complete

- [x] Compare the OilLamps `SurvivalLamp` item/model script against PseudoBlenderTest's `MagicCube` item/model script.
- [x] Identify model-definition differences beyond the shared FBX payload.
- [x] Add the OilLamps texture reference to `model MagicCube`: `texture = WorldItems/TinCanEmpty`.
- [x] Add the OilLamps scale reference to `model MagicCube`: `scale = 0.05`.
- [x] Read back the model script and check brace balance.
- [x] Record implementation notes and pending in-game verification.

**Technical Notes:**
The same FBX can render differently depending on its Project Zomboid model script definition. OilLamps does not use `SurvivalLamp.fbx` by itself; it wraps the mesh with an explicit texture and scale:

```txt
model SurvivalLamp
{
    mesh = WorldItems/SurvivalLamp,
    texture = WorldItems/TinCanEmpty,
    scale = 0.05,
}
```

Before Phase 5, PseudoBlenderTest only defined:

```txt
model MagicCube
{
    mesh = WorldItems/MagicCube,
}
```

This explains the Phase 4 result: the model wiring worked, but the lamp was huge and colored oddly because PseudoBlenderTest was missing OilLamps' `scale` and `texture` model parameters.

Implementation target:

- Model script: `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/scripts/PseudoBlenderTestModels.txt`.

Implementation result:

- Updated `model MagicCube` to keep `mesh = WorldItems/MagicCube`.
- Added `texture = WorldItems/TinCanEmpty` to match the OilLamps `SurvivalLamp` model definition.
- Added `scale = 0.05` to match the OilLamps `SurvivalLamp` model definition.
- Left the runtime FBX path unchanged: `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/models_x/WorldItems/MagicCube.fbx` still currently contains the `SurvivalLamp.fbx` payload.
- Left the item script unchanged: `MagicCube` still uses `StaticModel = MagicCube` and `WorldStaticModel = MagicCube`.

**Verification Notes:**

- Local model script read-back completed.
- Brace count checked locally: opening and closing braces match.
- In-game verification: Phase 5 was successful; adding the OilLamps texture and scale parameters made the SurvivalLamp payload render at the expected size/color behavior compared with the previous Phase 4 result.
- Phase remains `Work Complete`, not `Verified`, until Ed explicitly approves `Verified` status.

---
### Phase 6: MagicCube CANdleLit Texture Test

**Status:** Work Complete

- [x] Accept `CANdleLit.png` as the next MagicCube texture test asset.
- [x] Copy `CANdleLit.png` into the mod's B42 WorldItems texture path.
- [x] Update `model MagicCube` to use `texture = WorldItems/CANdleLit`.
- [x] Keep the Phase 5 scale value, `scale = 0.05`.
- [x] Read back the model script and check brace balance.
- [x] Record implementation notes and pending in-game verification.

**Technical Notes:**
Phase 5 showed that the model script texture and scale parameters are important. Phase 6 keeps the working SurvivalLamp FBX payload and the OilLamps scale value, but changes the texture from vanilla `WorldItems/TinCanEmpty` to the custom `CANdleLit` texture.

Implementation targets:

- Source texture: `mymods/PseudoBlenderTest/img/CANdleLit.png`.
- Runtime texture: `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/textures/WorldItems/CANdleLit.png`.
- Model script: `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/scripts/PseudoBlenderTestModels.txt`.

Implementation result:

- Copied `mymods/PseudoBlenderTest/img/CANdleLit.png` to `mymods/PseudoBlenderTest/PseudoBlenderTest/42/media/textures/WorldItems/CANdleLit.png`.
- Updated `model MagicCube` from `texture = WorldItems/TinCanEmpty` to `texture = WorldItems/CANdleLit`.
- Left `mesh = WorldItems/MagicCube` and `scale = 0.05` unchanged.
- Left the item script unchanged: `MagicCube` still uses `StaticModel = MagicCube` and `WorldStaticModel = MagicCube`.

**Verification Notes:**

- Local model script read-back completed.
- Brace count checked locally: opening and closing braces match.
- Local hash check confirmed the runtime `CANdleLit.png` matches the source image.
- In-game verification has not been performed yet, so the phase is `Work Complete`, not `Verified`.

---
### Phase 7: Stop Texture and Mesh Work For Now

**Status:** Work Complete

- [x] Record Ed's decision that further texture and mesh work is not worth pursuing for now.
- [x] Treat the earlier FBX and texture experiments as useful research rather than active implementation targets.
- [x] Defer future custom world-model texture/mesh work unless a later DevCycle explicitly reopens it.
- [x] Update the rolling summary so there is no active texture/mesh follow-up implied.

**Technical Notes:**
After experimenting with custom cube FBXs, a known-working SurvivalLamp FBX, OilLamps model parameters, and custom texture references, the current practical conclusion is that texture and mesh work is not worth continuing in this mod for now. The experiments remain valuable because they showed how Project Zomboid model definitions depend on mesh, texture, and scale fields, but they are no longer an active development direction.

For now, `PseudoBlenderTest` should preserve the findings and avoid spending more time on custom MagicCube world-model texture or mesh behavior unless a future DevCycle deliberately reopens that question.

**Verification Notes:**

- Planning document updated only.
- No item scripts, model scripts, textures, or FBX files were changed for this phase.
- Phase is `Work Complete`, not `Verified`, because this records a planning decision rather than an in-game implementation result.
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
- Phase 5 matched OilLamps model-script parameters by adding `texture = WorldItems/TinCanEmpty` and `scale = 0.05` to `model MagicCube`.
- Phase 6 swapped the MagicCube model texture to custom `texture = WorldItems/CANdleLit` while keeping `scale = 0.05`.
- Phase 7 records that, after experimentation, texture and mesh work is not worth continuing for now.
- TinCanEmpty texture copied to `mymods/PseudoBlenderTest/img/TinCanEmpty.png` for inspection/reference.

---

## Rolling Summary

**Cycle Status:** In Progress
**Closure:** This cycle is intentionally never closed.

**Current Phase:** Phase 7 - Stop Texture and Mesh Work For Now
**Current Phase Status:** Work Complete

**Completed Experiments:**
- Phase 1 - `MagicCube` memento item script.
- Phase 2 - `MagicCube` inventory icon attachment.
- Phase 3 - `MagicCube` cube FBX static/world model attempts.
- Phase 4 - `MagicCube` SurvivalLamp FBX control model swap.
- Phase 5 - `MagicCube` OilLamps texture/scale model-parameter match.
- Phase 6 - `MagicCube` CANdleLit custom model texture test.
- Phase 7 - stop texture and mesh work for now after experimentation.

**Active / Pending Experiments:**
- In-game verification for `MagicCube` item loading, custom icon rendering, and custom model rendering.

**Deferred Ideas:**
- Further custom texture or mesh work for MagicCube, including cube FBX retests and CANdleLit world-model texture verification, unless a future DevCycle explicitly reopens the topic.
- Inventory rendering test.
- World placement or object behavior test.
