# DevCycle 2026-04: Lit World Item Texture Hookup

**Status:** Work Complete
**Start Date:** 2026-07-01
**Target Completion:** 2026-07-01
**Focus:** Record the lit butter candle world-model texture/mesh experiments and the decision to stop pursuing texture or mesh work for this mod.

---

## Goal

Record the texture and mesh experiments for `PseudoButterCandle.ButterCandleLit`, then stop pursuing custom world-model texture or mesh work for this mod. After testing, the payoff does not appear worth the added complexity and churn. Existing lighting, extinguish behavior, recipes, item icons, and burn duration should remain the priority.

## Desired Outcome

The cycle should preserve what was learned from the texture/mesh experiments, but no further texture or mesh work should be planned for `PseudoButterCandle`. The mod should favor stable item behavior over custom world-model appearance work.

---

## Tasks

### Phase 1: Reference and Wiring Review

**Status:** Work Complete

- [x] Inspect `PseudoBlenderTest` model and item script wiring.
- [x] Inspect the current `PseudoButterCandle` model script, item script, texture path, and FBX paths.
- [x] Identify mismatches between the working reference and the current butter candle hookup.

**Technical Notes:**
`PseudoBlenderTest` uses `media/models_x/WorldItems/MagicCube.fbx`, `media/textures/WorldItems/CANdleLit.png`, a `Base` model entry with `mesh = WorldItems/MagicCube`, `texture = WorldItems/CANdleLit`, and item properties `StaticModel = MagicCube` plus `WorldStaticModel = MagicCube`.

Current `PseudoButterCandle` has the custom texture in the expected texture path and a model script entry named `ButterCandle`, but only the lit item points at that model. The model script currently references `mesh = WorldItems/TinCanEmpty`, which keeps the mesh vanilla while applying the new texture. The mod also has custom FBX files under `media/models_X/WorldItems/`, whose uppercase `models_X` differs from the working `models_x` folder convention.

### Phase 2: Lit Model Hookup

**Status:** Superseded by Phase 4

- [x] Keep `CANdleLit.png` in `PseudoButterCandle/42/media/textures/WorldItems/`.
- [x] Define a dedicated lit model name so the item script clearly maps lit state to the custom textured model.
- [x] Point `PseudoButterCandle.ButterCandleLit` at the dedicated lit model via `StaticModel` and `WorldStaticModel` for the first test.
- [x] Leave `PseudoButterCandle.ButterCandle` on the vanilla `TinCanEmpty` model.
- [x] Supersede this hookup after in-game testing showed this model/texture combination produced a picture-like result rather than the intended 3D object.

**Technical Notes:**
The dedicated model continues to live in a script under `media/scripts/`, matching the `PseudoBlenderTest` model-script pattern. The active mesh remains vanilla `WorldItems/TinCanEmpty`, so no custom FBX path is required for this fix.

Implemented changes:

```text
model ButterCandleLit
{
    mesh = WorldItems/TinCanEmpty,
    texture = WorldItems/CANdleLit,
    scale = 0.05,
}
```

This was the first attempted hookup. It has been superseded: `PseudoButterCandle.ButterCandleLit` is back on `StaticModel = TinCanEmpty` and `WorldStaticModel = TinCanEmpty` after this model/texture combination produced a picture-like result.

### Phase 3: Static Verification

**Status:** Work Complete

- [x] Confirm every referenced model name has a matching `model` definition or vanilla model.
- [x] Confirm `texture = WorldItems/CANdleLit` resolves to the runtime texture path.
- [x] Confirm no recipe, translation, icon, or Lua lighting behavior changed.
- [x] Document that in-game rendering still requires playtest verification.

**Technical Notes:**
Static review at this point confirmed the rollback state after Phase 4. Phase 6 supersedes that rollback with the no-FBX vanilla mesh path correction. `CANdleLit.png` still exists at `PseudoButterCandle/42/media/textures/WorldItems/CANdleLit.png`, and its SHA-256 hash matches the working `PseudoBlenderTest` copy. Recipes, translations, icons, and Lua files were not modified in this cycle. Do not mark this cycle `Verified` until the restored textured model behavior is checked in-game.


### Phase 4: Revert Incorrect Model Hookup

**Status:** Work Complete

- [x] Record the in-game result: the current hookup showed a picture-like presentation instead of the intended 3D object using the updated `CANdleLit.png` artwork.
- [x] Do not use `TinCanLamp_Lit.fbx`, `TinCanLamp_Unlit.fbx`, or any other untested FBX asset in this fix.
- [x] Restore `PseudoButterCandle.ButterCandleLit` to the known vanilla `TinCanEmpty` static/world model.
- [x] Stop using the current `WorldItems/CANdleLit` + `WorldItems/TinCanEmpty` hookup for the lit item, while preserving `CANdleLit.png` as intentional artwork for a future correct hookup.

**Technical Notes:**
The failure indicates this specific hookup is wrong, not that Ed's updated `CANdleLit.png` asset is wrong. The texture was intentionally changed and should be preserved. Applying it to the vanilla `TinCanEmpty` mesh did not produce the desired 3D result, so the corrected script keeps the lit item on `StaticModel = TinCanEmpty` and `WorldStaticModel = TinCanEmpty` for now, matching the last known 3D model behavior and avoiding all untested FBX assets.

This rollback was temporary and is superseded by Phase 6. `PseudoButterCandleTestModels.txt` is active again and now points `model ButterCandleLit` at the vanilla `WorldItems/CanOpen` mesh with `texture = WorldItems/CANdleLit`.


### Phase 5: Restore Working PseudoBlenderTest Pattern

**Status:** Superseded by Phase 6

- [x] Preserve `CANdleLit.png` as the intended model texture.
- [x] Avoid `TinCanLamp_Lit.fbx`, `TinCanLamp_Unlit.fbx`, and the other untested butter-candle FBX assets.
- [x] Copy the tested `PseudoBlenderTest` runtime model payload into the butter candle mod as `models_x/WorldItems/ButterCandleLit.fbx`.
- [x] Point `model ButterCandleLit` at `mesh = WorldItems/ButterCandleLit` and `texture = WorldItems/CANdleLit`.
- [x] Import `Base` in the butter candle item script and point only `PseudoButterCandle.ButterCandleLit` at `StaticModel = ButterCandleLit` and `WorldStaticModel = ButterCandleLit`.
- [x] Normalize the model folder casing to `media/models_x/`, matching `PseudoBlenderTest` and the Java loader path.

**Technical Notes:**
`PseudoBlenderTest` works because the item, model script, texture, and model payload are all connected:

```text
StaticModel = MagicCube
WorldStaticModel = MagicCube
model MagicCube -> mesh = WorldItems/MagicCube, texture = WorldItems/CANdleLit
media/models_x/WorldItems/MagicCube.fbx
```

The corrected butter candle hookup mirrors that structure under butter-candle-specific names:

```text
StaticModel = ButterCandleLit
WorldStaticModel = ButterCandleLit
model ButterCandleLit -> mesh = WorldItems/ButterCandleLit, texture = WorldItems/CANdleLit
media/models_x/WorldItems/ButterCandleLit.fbx
```

This copied-FBX approach was superseded after all FBX assets were removed from the butter candle mod for separate testing. Phase 6 keeps the useful lesson from this phase: the item, model script, texture, and actual mesh path must all resolve together.


### Phase 6: Vanilla Mesh Path Correction

**Status:** Work Complete

- [x] Record that all FBX files were removed from the butter candle mod for independent testing.
- [x] Preserve `CANdleLit.png` as the intended lit world-model texture.
- [x] Identify why `mesh = WorldItems/TinCanEmpty` fell back to the item icon: `TinCanEmpty` is a vanilla model name, not the underlying mesh path.
- [x] Update `model ButterCandleLit` to use the vanilla can mesh path `mesh = WorldItems/CanOpen`.
- [x] Keep the custom texture reference `texture = WorldItems/CANdleLit`.
- [x] Match the vanilla `TinCanEmpty` model scale with `scale = 0.12`.

**Technical Notes:**
Vanilla defines `model TinCanEmpty` in `media/scripts/generated/models_items.txt` as:

```text
model TinCanEmpty
{
    mesh = WorldItems/CanOpen,
    texture = WorldItems/TinCanEmpty,
    scale = 0.12,
}
```

The manual test used `mesh = WorldItems/TinCanEmpty`, but that path does not point at the actual mesh. When the model could not resolve, the game displayed the lit item icon `Item_ButterCandleLit.png` as a fallback. The corrected butter candle model now mirrors the vanilla mesh path while swapping only the texture:

```text
model ButterCandleLit
{
    mesh = WorldItems/CanOpen,
    texture = WorldItems/CANdleLit,
    scale = 0.12,
}
```

The active item script still points `PseudoButterCandle.ButterCandleLit` at `StaticModel = ButterCandleLit` and `WorldStaticModel = ButterCandleLit`. No FBX asset is required for this fix.


### Phase 7: Stop Texture and Mesh Work

**Status:** Work Complete

- [x] Record Ed's decision that further texture/mesh work is not worth pursuing for this mod.
- [x] Treat the previous texture and mesh experiments as useful research rather than an active implementation path.
- [x] Defer or abandon future custom world-model texture/mesh work unless a later DevCycle explicitly reopens it.

**Technical Notes:**
After experimentation, custom texture and mesh work for `PseudoButterCandle` does not appear worth the complexity. The cycle's useful outcome is the understanding that vanilla model names, mesh paths, texture paths, and scale values must line up exactly, but this mod should not keep spending effort on that rendering path.

The practical direction is to keep `PseudoButterCandle` focused on stable gameplay behavior: crafting, lighting, extinguishing, depletion behavior, icons, and item identity.

**Verification Notes:**

- Decision recorded per Ed's direction.
- No code changes are required for this phase.
- This phase is `Work Complete`, not `Verified`.
---

## Notes and Risks

- Static review can confirm script references and file locations, but only an in-game test can confirm the exact material/UV behavior on the chosen mesh.
- The manual `mesh = WorldItems/TinCanEmpty` test did not resolve because `TinCanEmpty` is a model name, not the underlying mesh path. All FBX assets have been removed from this mod for separate testing, so this cycle now uses the vanilla `WorldItems/CanOpen` mesh path with the custom `WorldItems/CANdleLit` texture.
- Ed manually added `ReplaceOnDeplete = Base.TinCanEmpty,` to `mymods/PseudoButterCandle/PseudoButterCandle/42/media/scripts/items/PseudoButterCandle_Items.txt` for `PseudoButterCandle.ButterCandleLit`, so a depleted lit butter candle returns an empty tin can.
- Further texture or mesh work is intentionally stopped for this mod after experimentation; it does not appear worth the added effort.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:** 2026-07-01
**Phases Completed:** Phase 1, Phase 2, Phase 3, Phase 4, Phase 5, Phase 6, and Phase 7
**Work Deferred:** No further texture or mesh work is planned for this mod unless a future DevCycle explicitly reopens it.

**Accomplishments:**
- Created and tested multiple `ButterCandleLit` model/texture hookup approaches, then decided to stop pursuing custom texture or mesh work because it is not worth the complexity for this mod.

**Metrics:**
- Files modified: 3
- Static verification: Passed
- In-game verification: Texture/mesh path intentionally abandoned

**Lessons / Notes:**
Key lesson: `TinCanEmpty` is a model name; `WorldItems/CanOpen` is the mesh used by that vanilla model, and texture/scale values matter. However, the practical decision for `PseudoButterCandle` is to stop working on custom texture/mesh rendering and keep the mod focused on stable gameplay behavior.
