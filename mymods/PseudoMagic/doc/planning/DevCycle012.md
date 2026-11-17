# DevCycle 012: Magic Light Ball Texture

**Status:** VERIFIED (Phases 1-2 Work Complete and deployed; Phase 3 in-game testing pending; the user has seen the world texture working)
**Start Date:** 2026-11-14
**Target Completion:** TBD
**Focus:** Give the Magic Light Ball its own look by painting the user's `LightBall.png` onto the tennis ball's 3D model, in place of the vanilla tennis ball texture.

**Source documents:** none (request from the user in conversation). Related: `doc/planning/DevCycle011.md` (previous cycle); the light-ball behaviour itself is in the existing `PseudoMagicLightBall*.lua` files and is not changed.
**Engine checks against:** v42.20.4 (`media42_20_4/`, `zombie42_20_4/`)

---

## Goal

The Magic Light Ball currently looks exactly like a vanilla tennis ball. The user has added `LightBall.png` to the mod and wants the ball to use it. The ball keeps the tennis ball's 3D mesh; only the texture changes.

## Desired Outcome

In game:

- the Magic Light Ball, lying on the ground and held in the hand, shows the `LightBall.png` texture on the tennis ball shape;
- the inventory icon is the user's own `Item_MagicLightBall.png` (Phase 2);
- vanilla tennis balls are not affected;
- everything the light ball already does (light, drain, drop and summon behaviour) is unchanged.

---

## Research Summary

- **Current item** (`PseudoMagic/42/media/scripts/items/PseudoMagic_Items.txt`, item `MagicLightBall`): `Icon = TennisBall`, `StaticModel = TennisBall`, `WorldStaticModel = TennisBall`. It points straight at the vanilla ball.
- **Vanilla model** (`media42_20_4/scripts/generated/models_items.txt:1452`): `model TennisBall { mesh = WorldItems/TennisBall, texture = WorldItems/TennisBall, scale = 0.4 }`. The mesh `.fbx` is a packed game asset and is not in this repo.
- **The user's texture:** `PseudoMagic/42/media/textures/WorldItems/LightBall.png`. It is 64 x 64 pixels, RGB (no transparency): a blue disc on a yellow-green background. It is not referenced anywhere in the mod yet.
- **Precedent in the user's other mods:** `PseudoButterCandle` already defines a model that reuses a vanilla mesh with its own texture (`PseudoButterCandle/42/media/scripts/PseudoButterCandleTestModels.txt`: `mesh = WorldItems/CanOpen`, `texture = WorldItems/CANdleLit`, `scale = 0.12`). The mod's own textures sit in `media/textures/WorldItems/`.
- **Plan:** add a model script in the mod, `MagicLightBall`, that uses the vanilla tennis ball mesh and `LightBall` texture, and point the item's `StaticModel` and `WorldStaticModel` at it. No Lua change is expected.

---

## Tasks

### Phase 1: Model script and item change

**Status:** Work Complete (deployed; in-game check pending)

- [x] Confirm `LightBall.png` is the texture the user wants (64 x 64, blue disc on a yellow-green background) and is final.
- [x] Add `PseudoMagic/42/media/scripts/PseudoMagic_Models.txt` with a `model MagicLightBall` that uses `mesh = WorldItems/TennisBall`, `texture = WorldItems/LightBall` and `scale = 0.4` (the vanilla ball's scale).
- [x] In the `MagicLightBall` item, change `StaticModel` and `WorldStaticModel` from `TennisBall` to `MagicLightBall`.
- [x] Leave `Icon = TennisBall` for now (see Open Questions).
- [x] Redeploy via `CopyModToZomboid.bat PseudoMagic`.

**Technical Notes:**
Implemented 2026-11-14: `PseudoMagic/42/media/scripts/PseudoMagic_Models.txt` (model `MagicLightBall`, mesh `WorldItems/TennisBall`, texture `WorldItems/LightBall`, scale 0.4) and `StaticModel`/`WorldStaticModel = MagicLightBall` on the item. Per the user ("Test as is"), the PNG was used unchanged; `Icon` is still `TennisBall`. Deployed with `CopyModToZomboid.bat PseudoMagic`; the deployed copy contains the model script and the texture. The model name `MagicLightBall` follows the mod's item naming; if it clashes with another model name, use a unique name such as `PseudoMagicLightBall`. The texture path is relative to `media/textures/`, without the file extension.

### Phase 2: Inventory icon

**Status:** Work Complete (deployed; in-game check pending)

**Request (the user):** the light ball's 3D look in the world is as wanted; now give it its own inventory icon. The user created `Item_MagicLightBall.png`.

**Findings:** the item's `Icon = TennisBall` points at the vanilla icon texture `Item_TennisBall` (a packed game asset, not in this repo). An icon is a separate flat image from the 3D model texture, named `Item_<Icon>.png` under `media/textures/`. The user's file is 32 x 32 pixels, RGBA (with transparency), the same size as the icons in the user's other mods.

- [x] Confirm `PseudoMagic/42/media/textures/Item_MagicLightBall.png` exists (32 x 32, RGBA).
- [x] Change the `MagicLightBall` item to `Icon = MagicLightBall` in `PseudoMagic_Items.txt`.
- [x] Confirm nothing else in the item script still refers to the tennis ball (no `TennisBall` text remains).
- [x] Redeploy via `CopyModToZomboid.bat PseudoMagic`; the deployed copy contains the icon and the changed item script.
- [ ] In game: confirm the icon shows in the inventory, in the hand/equipped slot and in the summon result, and that no log errors appear.

**Technical Notes:**
Implemented 2026-11-14. Resolves Open Question 1 below: the light ball gets its own icon.

### Phase 3: In-Game Testing

**Status:** Planning

- [ ] Deploy and load a B42 test save; enable the mod.
- [ ] Spawn a Magic Light Ball (debug item list or the Ring of the Mage Summon menu).
- [ ] Drop it and confirm the ball on the ground shows the new texture.
- [ ] Hold it in the hand (the summon menu equips it in the secondary hand) and confirm the held model shows the new texture.
- [x] Look at how the pattern lands on the ball (the user: the PNG "looks the way I want in the world"): the PNG's blue disc and background may map unexpectedly onto the tennis ball's surface (see Notes and Risks).
- [ ] Confirm a vanilla tennis ball still looks like a tennis ball.
- [ ] Confirm the light, battery drain, drop and summon behaviour are unchanged.
- [ ] Check the game console/log for errors (missing model, missing texture).

**Technical Notes:**
Record results here. Final status of this phase is set by the user.

---

## Open Questions

1. **Inventory icon:** *(Resolved: the user made `Item_MagicLightBall.png`; see Phase 2.)* the icon in the inventory is a separate flat image (`Item_<name>.png`) and is not changed by `LightBall.png`. Should the light ball keep the tennis ball icon, or get its own?
   **Recommendation:** keep the tennis ball icon in this cycle, and make an icon in a later cycle if the 3D look is liked. It needs a separate image and one `Icon =` line.

2. **Does the texture fit the mesh?** *(the user: test as is.)* The tennis ball's UV layout (how the flat image wraps on the ball) is not available in this repo, so it is not known where a blue disc on a yellow-green background will land.
   **Recommendation:** test as is. If it looks wrong, the user adjusts the PNG (the mesh is a packed asset and is left alone).

3. **Model name:** `MagicLightBall` or a more specific `PseudoMagicLightBall`?
   **Recommendation:** `MagicLightBall`, matching the item, unless the game reports a clash.

4. **Glow or lighting:** should the ball look lit or glowing?
   **Recommendation:** no, out of scope; the texture is a plain colour map and the game's light comes from the item's light settings.

---

## Notes and Risks

- Nothing has been run in game. The plan is based on the vanilla model script and on the `PseudoButterCandle` mod's use of the same pattern.
- **Texture layout risk:** the tennis ball mesh expects a texture laid out for its UV map. A 64 x 64 image with a centred disc may not wrap as a clean disc; this is the main unknown and is tested in Phase 2.
- **Texture size and format:** the PNG has no transparency (RGB). The game does not need it for an opaque ball.
- Per `AGENTS.md`, no git commands without user permission, and phases may not be set to `Verified` without explicit user approval.
- Per `AGENTS.md`, work stops after this document is created; implementation starts only when the user asks.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:** [YYYY-MM-DD]
**Phases Completed:** [List or "All"]
**Work Deferred:** [What was not done and why, or "None"]

**Accomplishments:**
- [What was built or changed]

**Metrics:**
- Files modified: [N]

**Lessons / Notes:**
[Anything worth remembering for future cycles.]
