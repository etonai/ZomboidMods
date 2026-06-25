# DevCycle 2026-01: Pseudo Butter Candle

**Status:** Work Complete
**Start Date:** 2026-06-25
**Target Completion:** 2026-06-25
**Focus:** Implement the first version of a craftable butter candle that can be lit, placed on the ground, and burn for eight in-game hours.

---

## Goal

Create the initial implementation for the `PseudoButterCandle` mod. The mod adds a recipe that combines one unit of butter, one twig, and one empty tin can to create a butter candle, then lets that candle behave as a short-lived placeable light source.

The key gameplay target is simple survival utility: butter becomes an emergency candle, using a twig as the wick and an empty tin can as the holder, with an eight-hour burn time. Ground placement follows the `OilLamps` approach rather than vanilla candle placement, because vanilla lit candles are converted back to unlit candles when dropped.

## Desired Outcome

`PseudoButterCandle` now has a working v42 mod structure, script definitions, recipes, translations, and Lua support for a butter candle that:

- is crafted from one `Base.Butter` item, one `Base.Twigs` item, and one `Base.TinCanEmpty` item;
- has unlit and lit item states;
- can be lit from normal fire-starting items or valid nearby fire;
- emits candle-like light while held or placed;
- remains lit when placed on the ground through custom OilLamps-style world light handling;
- drains toward burnout over eight in-game hours while placed;
- removes itself and its world light when depleted.

---

## Tasks

### Phase 1: Mod Structure and Script Items

**Status:** Work Complete

- [x] Confirm the expected Project Zomboid v42 mod folder layout under `mymods/PseudoButterCandle/PseudoButterCandle/`.
- [x] Add `mod.info` files for the mod root and v42 folder.
- [x] Add media folders for scripts, Lua, and translations.
- [x] Define `PseudoButterCandle.ButterCandle` as the unlit item.
- [x] Define `PseudoButterCandle.ButterCandleLit` as the lit drainable light source.
- [x] Use empty tin can model/icon references for the first cycle.

**Technical Notes:**
Implemented in:

- `PseudoButterCandle/mod.info`
- `PseudoButterCandle/42/mod.info`
- `PseudoButterCandle/42/media/registries.lua`
- `PseudoButterCandle/42/media/scripts/items/PseudoButterCandle_Items.txt`

The custom lit item avoids vanilla `Base.CandleLit` drop conversion while representing the butter candle as a tin can with `StaticModel = TinCanEmpty` and `WorldStaticModel = TinCanEmpty`.

### Phase 2: Crafting and Light/Extinguish Recipes

**Status:** Work Complete

- [x] Add a craft recipe to create `PseudoButterCandle.ButterCandle` from one butter item, one twig item, and one empty tin can.
- [x] Confirm the exact base item identifiers for butter, twig, and empty tin can in v42 game scripts.
- [x] Add a light recipe that consumes/replaces the unlit butter candle and a `base:startfire` source.
- [x] Add an extinguish recipe that converts `ButterCandleLit` back to `ButterCandle`, preserving remaining burn uses.
- [x] Add a light-from-fire recipe using `RecipeCodeOnTest.openFire`.

**Technical Notes:**
Implemented in `PseudoButterCandle/42/media/scripts/recipes/PseudoButterCandle_Recipes.txt`.

Confirmed identifiers:

- `Base.Butter` from `media/scripts/generated/items/food.txt`
- `Base.Twigs` from `media/scripts/generated/items/normal.txt`
- `Base.TinCanEmpty` from `media/scripts/generated/items/normal.txt`

### Phase 3: OilLamps-Style Ground Placement

**Status:** Work Complete

- [x] Add a shared Lua utility module for butter candle tag checks, light registration, chunk-aware deferred loading, and item lookup by ID.
- [x] Add a light object wrapper around `IsoLightSource` with candle-like color and radius.
- [x] Hook `ISDropWorldItemAction.complete` for items tagged `pseudobuttercandle:buttercandlelit`.
- [x] Hook inventory transfer to detect lit butter candles moving to and from floor containers.
- [x] Persist placed lit candles in mod data by item ID and world coordinates.
- [x] Restore placed lights on player load/chunk load.
- [x] Remove the world light when the placed candle is picked up, missing, extinguished, or depleted.

**Technical Notes:**
Implemented in:

- `PseudoButterCandle/42/media/lua/shared/PseudoButterCandle_LightObject.lua`
- `PseudoButterCandle/42/media/lua/shared/PseudoButterCandle_Utils.lua`
- `PseudoButterCandle/42/media/lua/shared/PseudoButterCandle_Shared.lua`
- `PseudoButterCandle/42/media/lua/client/PseudoButterCandle_Client.lua`
- `PseudoButterCandle/42/media/lua/server/PseudoButterCandle_Server.lua`

This is self-contained and does not require OilLamps as a dependency.

### Phase 4: Eight-Hour Burn Behavior

**Status:** Work Complete

- [x] Use OilLamps-style periodic placed-world drain for ground-placed butter candles.
- [x] Implement placed-world burn drain from `Events.EveryTenMinutes`.
- [x] Tune `UseDelta` so a full butter candle lasts eight in-game hours under the placed drain formula.
- [x] Preserve remaining burn state across light/extinguish recipes via inherited uses.
- [x] Make the depleted butter candle disappear instead of leaving a spent item.

**Technical Notes:**
The lit and unlit items use `UseDelta = 0.0002083333`.

With the implemented placed drain formula, each ten-minute tick subtracts `UseDelta * 100`. A full candle therefore lasts 48 ten-minute ticks, or eight in-game hours.

### Phase 5: Text, Icons, and Player-Facing Polish

**Status:** Work Complete

- [x] Add English translation entries for item names and recipe names.
- [x] Use custom mod-local icon references for unlit/lit butter candle states.
- [x] Set the item display category to `LightSource`.
- [x] Add double-click recipes for lighting and extinguishing.
- [x] Defer custom tooltips/art because empty tin can visuals are adequate for the first implementation.

**Technical Notes:**
Implemented in:

- `PseudoButterCandle/42/media/lua/shared/Translate/EN/ItemName.json`
- `PseudoButterCandle/42/media/lua/shared/Translate/EN/Recipes.json`


### Phase 7: Custom Lit Icon Source

**Status:** Work Complete

- [x] Copy the base open tin can icon into the mod texture folder as an editable lit butter candle source image.
- [x] Name the copied icon `Item_ButterCandleLit.png` so the item can reference it as `Icon = ButterCandleLit`.
- [x] Update `PseudoButterCandle.ButterCandleLit` to use the mod-local lit icon.
- [ ] Edit `Item_ButterCandleLit.png` in GIMP to add a visible lit wick/flame treatment.

**Technical Notes:**
Copied from the local Project Zomboid install at `C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid/media/textures/CanOpen.png` into `PseudoButterCandle/42/media/textures/Item_ButterCandleLit.png`.

Phase 8 supersedes this: both unlit and lit items now use mod-local custom icon files.

### Phase 8: Final Butter Candle Icons

**Status:** Work Complete

- [x] Add `Item_ButterCandle.png` as the unlit butter candle icon.
- [x] Add `Item_ButterCandleLit.png` as the lit butter candle icon.
- [x] Update `PseudoButterCandle.ButterCandle` to use `Icon = ButterCandle`.
- [x] Update `PseudoButterCandle.ButterCandleLit` to use `Icon = ButterCandleLit`.
- [x] Keep the shared tin-can world/static model behavior; Phase 9 attempted custom FBX wiring but reverted to this fallback.

**Technical Notes:**
The active item icons are now mod-local files in `PseudoButterCandle/42/media/textures/`:

- `Item_ButterCandle.png` for the unlit item.
- `Item_ButterCandleLit.png` for the lit item.

The items use the tin can static/world model references in script, while inventory icons use the custom butter candle artwork.

### Phase 9: Custom FBX World Models

**Status:** Deferred

- [x] Confirm the user-provided `TinCanLamp_Unlit.fbx` and `TinCanLamp_Lit.fbx` files exist in the mod.
- [x] Attempt OilLamps-style model wiring for the custom FBX files.
- [x] Revert active item model references back to the stable `TinCanEmpty` model after in-game testing showed the custom FBX wiring did not work.
- [ ] Revisit custom FBX world models in a later phase after diagnosing the model/export/script issue.

**Technical Notes:**
The custom FBX files remain in `PseudoButterCandle/42/media/models_X/WorldItems/` for future work:

- `TinCanLamp_Unlit.fbx`
- `TinCanLamp_Lit.fbx`

The active item script no longer references `TinCanLamp_Unlit` or `TinCanLamp_Lit`. Both unlit and lit items use `StaticModel = TinCanEmpty` and `WorldStaticModel = TinCanEmpty` again, while inventory icons continue to use the custom PNG artwork from Phase 8.
### Phase 6: Verification

**Status:** Work Complete

- [x] Static check: recipe consumes exactly one `Base.Butter`, one `Base.Twigs`, and one `Base.TinCanEmpty`.
- [x] Static check: unlit/lit items, tags, double-click recipes, and translation entries are present.
- [x] Static check: JSON translation files parse successfully.
- [x] Static check: Lua block counts are balanced in all new Lua files.
- [x] Static check: no accidental literal newline escape tokens remain after file edits.
- [ ] In-game check: recipe appears in the crafting UI and consumes exactly one butter item, one twig item, and one empty tin can.
- [ ] In-game check: crafted butter candle starts with a full eight-hour burn value.
- [ ] In-game check: candle can be lit and extinguished from inventory.
- [ ] In-game check: lit candle emits light while held/equipped.
- [ ] In-game check: lit candle can be placed on the ground and continues emitting light.
- [ ] In-game check: placed candle light is removed when picked up.
- [ ] In-game check: placed candle persists correctly after save/load or player reconnect.
- [ ] In-game check: placed candle depletes after eight in-game hours and cleans up its world light.
- [ ] In-game check: multiplayer command paths if the mod is intended to support servers.

**Technical Notes:**
This DevCycle is marked `Work Complete`, not `Verified`. In-game verification remains pending user approval/testing per `doc/planning/DevelopmentProcess.md`.

---

## Notes and Risks

- Vanilla lit candles are intentionally unlit when dropped, so this implementation uses a custom lit item plus custom floor-light Lua.
- World-light persistence is implemented through mod data keyed by item ID and world coordinates.
- Unloaded squares are skipped during the ten-minute burn loop so saved light records are not removed just because the chunk is inactive.
- Multiplayer behavior follows the OilLamps-style client/server command pattern, but still needs in-game server testing.
- Held/equipped native drain timing should be checked in game; the eight-hour target is explicitly implemented for placed-world drain.

---

## Completion Summary

**Completion Date:** 2026-06-25
**Phases Completed:** Phases 1-8 implementation and static verification; Phase 9 deferred
**Work Deferred:** Custom FBX world models, in-game verification, and multiplayer verification remain pending.

**Accomplishments:**
- Added the v42 mod structure, mod metadata, item definitions, recipes, tag registration, translations, Lua placement/burn handling, and mod-local unlit/lit icon files.
- Implemented self-contained OilLamps-style placed lighting for `PseudoButterCandle.ButterCandleLit`.
- Implemented eight-hour placed burn duration using the planned ten-minute drain formula.

**Metrics:**
- Files modified: 16
- User-provided FBX assets retained but not active: 2
- Static verification: Passed
- In-game verification: Pending

**Lessons / Notes:**
`Base.Butter` is a whole food item, not a drainable portion, so the first cycle consumes one full butter item per butter candle. `Base.Twigs` is the v42 item ID for the requested twig ingredient. `Base.TinCanEmpty` is the v42 item ID for the empty tin can holder.