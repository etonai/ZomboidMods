# DevCycle 003: Placeholder Churning Machine Object

**Status:** Verified
**Start Date:** 2026-09-12
**Target Completion:** 2026-09-12
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

**Status:** Work Complete

- [x] Confirm how the Blue Combo Washer/Dryer's sprite/graphic is referenced, per `claude_washingMachineAnalysis.md`.
- [x] Review how `PseudoSaltWell` (`mymods/PseudoSaltWell42_19`) implements a simple tool-driven construction of a custom-graphic object, as a reference pattern if a comparable approach fits here.
- [x] Decide whether the Churning Machine should be a new custom entity/sprite or reuse the Blue Combo Washer/Dryer's existing sprite directly.

**Technical Notes:**

**Blue Combo Washer/Dryer sprite.** The real washer/dryer (`IsoCombinationWasherDryer`, a hard-coded Java `IsoObject`, per `claude_washingMachineAnalysis.md`) is never player-crafted in vanilla — it's placed as furniture via the Moveables system from the item `Mov_BlueComboWasherDryer` (`media42_20_4/scripts/generated/items/moveable.txt:3062-3069`), whose world sprite is:
```
item Mov_BlueComboWasherDryer
{
    DisplayCategory = Furniture,
    ItemType = base:moveable,
    WorldObjectSprite = appliances_laundry_01_0,
}
```
`appliances_laundry_01_0` is a single-tile sprite (only one overlay/tile reference found anywhere in scripts — `media42_20_4/lua/server/Items/ApplianceOverlays.lua:14`); no multi-tile footprint or extra placement script was found for it. Solidity comes from the tileset image's own baked-in tile properties, not from any script flag — so reusing this sprite row should make the placeholder object solid "for free," the same way `ChurnBucket` inherits solidity from its `crafted_05_72` sprite without declaring it explicitly.

**PseudoSaltWell's pattern does not fit this step.** `ISLocationBasedHole.lua` (`mymods/PseudoSaltWell42_19/PseudoSaltWell/42/media/lua/server/BuildingObjects/ISLocationBasedHole.lua`) is a custom `ISBuildingObject` subclass wired to a **shovel-and-use, no-recipe** interaction: `noNeedHammer = true`, no `inputs`/materials at all, an `IsoThumpable` created directly in Lua, with a hand-rolled `render()`/`isValid()` for the placement ghost. That pattern exists because digging a hole consumes no items — it's a tool+skill action, not a recipe. Step 3 explicitly wants a **materials recipe** (1 plank + 1 nail), which this pattern doesn't model at all (it would require reimplementing craft-input consumption, skill-scaled build time, and the ghost/validity logic that the entity system already provides for free).

**Decision: use the entity + `CraftRecipe` pattern, matching `ChurnBucket` and `Amphora`, not the PseudoSaltWell shovel-dig pattern.** Both existing player-built objects analyzed in Step 1 (`ChurnBucket` in `claude_butterChurn.md`, `Amphora` in `claude_amphoraAnalysis.md`) are ordinary `entity` blocks with a `component CraftRecipe` describing build inputs, category, and a `timedAction`, plus a `component SpriteConfig` describing the placed appearance — this is the generic, already-proven "player builds a workstation-shaped object from materials" system (`media42_20_4/lua/server/BuildingObjects/ISBuildIsoEntity.lua` handles the generic build timed-action, ghost placement, and solidity/collision from the sprite). Concretely, for the PseudoChurningMachine placeholder:

```
entity ChurningMachine
{
    component UiConfig { xuiSkin = default, uiEnabled = true }
    component SpriteConfig
    {
        isThumpable = false,
        face S { layer { row = appliances_laundry_01_0 } }
    }
    component CraftRecipe
    {
        timedAction = BuildWoodenStructureMedium,
        time = 50,
        category = Farming,
        inputs
        {
            item 1 [Base.Plank],
            item 1 [Base.Nails],
        }
    }
}
```

No `CraftBench`/`Recipes` component is needed yet — that's what hosts a *passive* recipe like `churn_butter`, and Step 3 explicitly wants zero functionality. `face S` (single-facing) is assumed for the placeholder rather than the washer/dryer's likely multi-face rendering, since correctness of directional facing isn't a Step 3 requirement (no functionality yet) — this can be revisited in a later step if the placeholder looks wrong from other approach angles in-game testing (Phase 3).

**Risk carried into Phase 2/3:** whether `SpriteConfig.row` can reference an appliance-tilesheet sprite (`appliances_laundry_01_0`) the same way `ChurnBucket` references a crafted-tilesheet sprite (`crafted_05_72`) hasn't been proven in-game — both are tile rows in a `.pack` texture sheet, so it's expected to work the same way, but this needs to be confirmed by an actual build-and-render test in Phase 3.


### Phase 2: Placeholder recipe and object

**Status:** Work Complete — implemented, in-game verification pending (Phase 3)

- [x] Add a placeholder build recipe: 1 `Base.Plank` + 1 `Base.Nails`.
- [x] Define the Churning Machine object/entity so it renders using the Blue Combo Washer/Dryer appearance.
- [x] Ensure the built object is solid (not walkable).
- [x] Confirm the object has zero functionality at this stage (no context menu actions, no container).

**Technical Notes:**

Implemented per Phase 1's decision, following the `ChurnBucket`/`Amphora` entity pattern rather than PseudoSaltWell's shovel-dig pattern. New files:

- `PseudoChurningMachine/42/media/scripts/entities/workstations/entity_ChurningMachine.txt` — `module Pseudonymous`, entity `ChurningMachine`:
  - `component SpriteConfig`: `row = appliances_laundry_01_0` (the real Blue Combo Washer/Dryer sprite, confirmed in Phase 1 not declared by any other entity — no duplicate-row risk, unlike the collision `PseudoButterChurner` DevCycle 2 hit reusing `crafted_05_72`). `isThumpable = false`, matching `ChurnBucket`'s own convention.
  - `component CraftRecipe`: `timedAction = BuildWoodenStructureMedium`, `time = 50`, `category = Farming`, inputs `1x Base.Plank` + `1x Base.Nails` (both consumed, no tool required) — the placeholder recipe from the idea doc. No `xpAward` (not specified by the idea doc for this placeholder).
  - `component UiConfig`: `uiEnabled = false` — deliberately no crafting window or interaction, since this step wants zero functionality. No `CraftBench`/`Resources`/`DryingCraftLogic` component at all (that's what would host a passive recipe or crafting UI — explicitly out of scope until later steps).
- `PseudoChurningMachine/42/media/scripts/entities/workstations/entity_ChurningMachine_xuiSkin.txt` — `module Base` (required regardless of the entity's own module — `PseudoButterChurner` DevCycle 2 Phase 5 found this the hard way). No `LuaWindowClass`, matching `uiEnabled = false`. `DisplayName = Churning Machine`; `Icon = Build_ButterChurn` used as a placeholder BUILD-menu icon (same accepted-placeholder convention `PseudoButterChurner` used for its own build icon).
- `PseudoChurningMachine/42/media/lua/shared/Translate/EN/Tooltip.json` — added `Tooltip_craft_churningMachineDesc`, referenced by the recipe's `Tooltip` field.

No Lua/logic code was needed for this step — a bare `entity` + `SpriteConfig` + `CraftRecipe` is sufficient for a solid, buildable, appearance-only placeholder, the same as vanilla `Amphora`. This deliberately avoids the failure modes documented in `PseudoButterChurner`'s DevCycle 2 (19 phases of fixes for sprite-hook wiring, `Resources`/`DryingCraftLogic` fluid-accounting bugs, and interaction-menu gating) — none of that machinery exists yet in this entity, so none of those bug classes apply here. That complexity will only become relevant starting around Step 5-9 of the mod plan, once functionality is actually added.

**Known unverified risk (carried from Phase 1, to check in Phase 3):** whether `SpriteConfig.row` renders an appliance-tilesheet sprite (`appliances_laundry_01_0`) correctly via a `face S { layer { row = ... } }` block, the same way it renders a crafted-tilesheet sprite for `ChurnBucket`. Not proven until an actual build-and-look test.


### Phase 3: In-game verification

**Status:** Verified

- [x] Build the Churning Machine in-game using the placeholder recipe.
- [x] Confirm appearance matches the Blue Combo Washer/Dryer.
- [x] Confirm the player cannot walk through the placed object.
- [x] Confirm no menu items or interactions are present beyond default object behavior.

**Technical Notes:**

Confirmed in-game by the user on 2026-09-12, after copying the mod via `utilities\CopyModToZomboid.bat PseudoChurningMachine` (see `PseudoChurningMachinePlan.md`'s "Build Approach" note, added specifically for this verification step). This resolves the risk flagged in Phase 1/2: `SpriteConfig.row` referencing an appliance-tilesheet sprite (`appliances_laundry_01_0`) via a `face S { layer { row = ... } }` block does render correctly, the same as a crafted-tilesheet sprite.


---

## Notes and Risks

- This is a placeholder recipe only — the real build materials/recipe are deferred to Step 11 planning, per `PseudoChurningMachinePlan.md`.
- No liquid container, Turn On action, or fullness/butter logic belongs in this cycle — those are Steps 4-9, each getting their own DevCycle.

---

## Completion Summary

**Completion Date:** 2026-09-12
**Phases Completed:** All (1, 2, 3)
**Work Deferred:** None — this cycle's scope (Step 3 of `PseudoChurningMachinePlan.md`) is fully done.

**Accomplishments:**
- Researched the real Blue Combo Washer/Dryer sprite reference and PseudoSaltWell's construction pattern; decided to use the `entity` + `CraftRecipe` + `SpriteConfig` pattern (matching `ChurnBucket`/`Amphora`) instead.
- Implemented `Pseudonymous.ChurningMachine`: buildable with 1 plank + 1 nail, renders using the real `appliances_laundry_01_0` sprite, `uiEnabled = false` (zero functionality), no `CraftBench`/`Resources` component.
- Confirmed in-game: builds correctly, looks like the Blue Combo Washer/Dryer, is solid, and offers no menu/interaction.

**Metrics:**
- Files added: `entity_ChurningMachine.txt`, `entity_ChurningMachine_xuiSkin.txt`, `Tooltip.json`.
- No Lua code needed.

**Lessons / Notes:**
- A bare `entity` + `SpriteConfig` + `CraftRecipe` (no `CraftBench`/`Resources`/`DryingCraftLogic`) was sufficient for a solid, correctly-rendered, appearance-only placeholder — none of `PseudoButterChurner` DevCycle 2's sprite-hook or fluid-accounting bug classes applied, because that machinery doesn't exist yet on this entity.
- Reusing a real vanilla sprite row not already declared by another entity (`appliances_laundry_01_0`) avoided the duplicate-row collision `PseudoButterChurner` hit reusing `crafted_05_72`.
- `PseudoChurningMachinePlan.md` now documents that `utilities\CopyModToZomboid.bat PseudoChurningMachine` must be run before every in-game verification phase — added during this cycle after the user asked whether it had been run.
