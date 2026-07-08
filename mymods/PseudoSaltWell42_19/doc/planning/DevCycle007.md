# DevCycle 007: Minor Recipe Tuning

**Status:** In Progress
**Start Date:** 2026-07-07
**Target Completion:** TBD
**Focus:** Small, incremental balance/quality-of-life changes to PseudoSaltWell42_19, done in phases.

---

## Goal

PseudoSaltWell42_19 is a released mod. This cycle covers a series of minor, low-risk changes to it, worked through one phase at a time rather than as a single large change. Phase 1 addresses craft times on the two salt-extraction recipes, which currently take longer than intended.

## Desired Outcome

Each phase leaves the mod in a working, loadable state with the specific change verified in-game. Phase 1: extracting salt from a pot or a kettle both take 60 (in recipe time units) instead of 200.

---

## Tasks

### Phase 1: Reduce Salt-Extraction Craft Times to 60

**Status:** Work Complete

- [X] In `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/scripts/recipes/PseudoSaltWellRecipes.txt`, change `time = 200` to `time = 60` for the `Get Salt From Pot` recipe
- [X] Change `time = 200` to `time = 60` for the `Get Salt From Kettle` recipe

**Technical Notes:**
Found both recipes in `PseudoSaltWellRecipes.txt` (module `PseudoSaltWellB42`):
- `Get Salt From Pot` (line 3) — `timedAction = OpenTinCan`, `time = 200`, input `PseudoSaltWellB42.SaltPot` → outputs `2x Base.Salt` + `Base.Pot`
- `Get Salt From Kettle` (line 20) — same shape, input `PseudoSaltWellB42.SaltKettle` → outputs `2x Base.Salt` + `Base.Kettle`

These are the only two `time =` values in the mod's recipe scripts. The user referred to the first one as "Set Salt from pot" — read as "Get Salt From Pot" (the only matching recipe in the mod); flagged here in case that reading is wrong.

Note: `mymods/PseudoSaltWell/` (a separate, similarly-named mod directory without the `42_19` suffix) contains the same two recipes at the same `time = 200` value. This cycle targets `PseudoSaltWell42_19/` only, per user direction — `mymods/PseudoSaltWell/` is intentionally left untouched.

### Phase 2: Match Vanilla's Natural-Water-Source Fill Sound

**Status:** Work Complete

- [x] In `ISFillPotFromWell:perform()`, change `self.character:getEmitter():playSound("GetWaterFromTap")` to play `"GetWaterFromLake"` instead
- [x] Make the same change in `ISFillKettleFromWell:perform()`

**Technical Notes:**
Both timed actions currently play `"GetWaterFromTap"` on a successful fill:
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/shared/TimedActions/ISFillPotFromWell.lua:56`
- `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/shared/TimedActions/ISFillKettleFromWell.lua:56`

Vanilla's own water-fill action (`media/lua/shared/TimedActions/ISTakeWaterAction.lua:50-71`) branches by source type: dispenser → `GetWaterFromDispenser`, toilet → `GetWaterFromToilet`, tap → `GetWaterFromTap`, and lake/river/rain-barrel (`isLakeOrRiver`, detected via `IsoFlagType.water` or the `blends_natural_02` sprite prefix, or `IsoThumpable` for rain barrels) → `"GetWaterFromLake"` (`ISTakeWaterAction.lua:66,68`). That's the sound to match — a PseudoSaltWell well is a natural water source, not a tap, so it should use the same sound vanilla uses for lake/river fills, not the tap sound it currently has.

### Phase 3: Full-Looking Model for SaltwaterPot

**Status:** Work Complete

- [x] In `PseudoSaltWellItems.txt`, change the `SaltwaterPot` item's `StaticModel` from `CookingPot` to `CookingPotGround_Fluid`
- [x] Change `SaltwaterPot`'s `WorldStaticModel` from `CookingPotGround` to `CookingPotGround_Fluid`

**Technical Notes:**
`SaltwaterPot` (`mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/scripts/items/PseudoSaltWellItems.txt:23-24`) currently uses `StaticModel = CookingPot` / `WorldStaticModel = CookingPotGround` — the same empty-pot model as `SaltPot` (the post-boil, salt-only state). So a pot full of saltwater currently looks identical to an empty pot.

Vanilla already has a full-looking pot model: `CookingPotGround_Fluid` (`media/scripts/generated/models_items.txt:5345-5356`) uses mesh `WorldItems/CookingPotFull` with texture `WorldItems/CookingPotWater` — a pot mesh that visibly holds liquid. Vanilla uses this exact model for its own liquid-filled pot items (e.g. `SugarBeetSyrupPot`, `media/scripts/generated/items/food.txt:576-600`, sets both `StaticModel` and `WorldStaticModel` to `CookingPotGround_Fluid`). `SaltwaterPot` should do the same.

No equivalent "kettle full of liquid" model exists in vanilla — `Kettle`/`KettleGround` are the only kettle models found, used regardless of contents, so `SaltwaterKettle`'s models are left unchanged in this phase. The user's request was specifically about the pot.

### Phase 4: Darker Water Texture for the Full Pot Model

**Status:** In Progress

- [x] Locate the vanilla `WorldItems/CookingPotWater` texture (the texture Phase 3's `CookingPotGround_Fluid` model uses) in the actual Project Zomboid game install
- [x] Copy that texture into `mymods/PseudoSaltWell42_19/images/`
- [x] Darken the water in the copied texture
- [x] Wire the darkened texture into `SaltwaterPot`'s model so it renders instead of the stock `CookingPotWater` texture

**Technical Notes:**
This repo does not contain game texture assets (`media/` here only has `lua/` and `scripts/`; no `media/textures/` or `.pack` files) — the source PNG came from the actual installed game.

- Source: `C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\media\textures\WorldItems\CookingPotWater.png`
- Copied to: `mymods/PseudoSaltWell42_19/images/CookingPotWater.png`
- User darkened the water and supplied the result as `mymods/PseudoSaltWell42_19/images/SaltwaterPot.png`, also placed at `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/textures/WorldItems/SaltwaterPot.png` (the in-mod texture path, per-mod `42/media/textures/` convention — matches how `PseudoButterCandle` places `CANdleLIT.png` under its own `42/media/textures/WorldItems/`).

Wired in following `PseudoButterCandle`'s pattern (`doc/planning/../PseudoButterCandleTestModels.txt`, model `ButterCandleLit` in module `Base`, reusing a vanilla mesh with a modded texture):

- Added `mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/scripts/PseudoSaltWellModels.txt` — module `Base`, model `SaltwaterPotFull`: same mesh (`WorldItems/CookingPotFull`), scale, and `Bip01_Prop1` attachment as vanilla's `CookingPotGround_Fluid` (`media/scripts/generated/models_items.txt:5345-5356`), but `texture = WorldItems/SaltwaterPot` instead of vanilla's `WorldItems/CookingPotWater`.
- Repointed `SaltwaterPot`'s `StaticModel`/`WorldStaticModel` in `PseudoSaltWellItems.txt` from `CookingPotGround_Fluid` to `SaltwaterPotFull` (no module prefix needed — `Base` is the default module, same as `ButterCandleLit`'s usage).

Not yet verified in-game — needs a load test to confirm the darker texture actually renders on the pot model.

---

## Notes and Risks

- Small, mechanical change — low risk. Confirm in-game that both recipes still complete correctly and that the reduced time doesn't trivialize the salt-extraction gameplay loop from the player's perspective (a balance judgment call for the user, not something to infer from code).
- `DevCycle006.md` (also currently open, in this same `doc/planning/` folder) is an unrelated, user-led map-location cycle with no AI implementation work — this cycle does not touch it.
- Future phases for this mod TBD — to be added to this same document as they're defined, per the project's DevCycle working agreement, unless this phase is closed out first.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**

**Lessons / Notes:**
