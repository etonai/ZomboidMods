# Ideas: A True "Saltwater" Fluid Type That Boils Down Into Salt

**Created:** 2026-06-21
**Game Version:** 42.11.0 (code), 42.19.0 (mod target per sibling mods)
**Mod:** PseudoSaltwater
**Mod ID:** `PseudonymousSaltwater`
**Status:** Investigation / not yet implemented

---

## Goal

This mod is one piece of a planned mod collection:

1. Dig a salt well (`PseudoSaltWell*` mods, already exist as separate mods).
2. Extract saltwater from the well into a container.
3. **Boil the saltwater down until it becomes salt.** (this mod)
4. Use the resulting salt to preserve food (lacto-fermentation mods, `PseudoTestRecipes` / `PseudoSaltRecipes`, already exist as separate mods).

`PseudoSaltwater` should own step 3 only: defining saltwater as a liquid and the mechanic that turns it into salt under heat. It should be small and self-contained so it can be combined with the well-digging mod and the food-preservation mods without depending on either.

---

## What Already Exists, and Why It's Not Reusable As-Is

The `PseudoSaltWell*` family of mods (`PseudoSaltWell`, `PseudoSaltWell42_19`, `PseudoSaltWellB42_Part1..6`) already has a notion of "saltwater," but it is **not** built on Project Zomboid's fluid system. Looking at `PseudoSaltWell/42/media/lua/shared/TimedActions/ISFillPotFromWell.lua` and `ISEmptySaltwaterContainer.lua`:

- Filling a pot from the well doesn't add fluid to the pot — it **deletes the empty pot and adds a wholly different item**, `PseudoSaltWellB42.SaltwaterPot`.
- Emptying does the reverse: delete the full item, add back `Base.Pot` (or `Base.Kettle`).
- There is no fluid amount, no mixing, no partial fill — "saltwater" there is a fixed, single-state item variant, not a liquid.

This was a reasonable approach prior to a proper fluid system, but it means none of that code can be reused to make saltwater behave like a real liquid (partial fills, pouring, mixing with other water, holding in any fluid-capable container). `PseudoSaltwater` should **not** copy this pattern — it should use the real fluid system introduced in Build 42.

---

## Confirmed: Build 42 Has a Real Fluid System

Verified by reading the engine's shared/client fluid code and generated data:

- `media/scripts/generated/fluids.txt` defines fluid types declaratively, e.g.:
  ```
  fluid Water
  {
      ColorReference = LightSkyBlue,
      DisplayName = Fluid_Name_Water,
      Categories { Beverage, Water, }
      Properties { ThirstChange = -50.0, }
  }
  ```
  Other existing fluids (`TaintedWater`, `CarbonatedWater`, `Petrol`, `Bleach`, `Blood`, `CowMilk`, etc.) confirm the available `Properties` fields: thirst/hunger/calorie changes, poison (`maxEffect`, `minAmount`, `diluteRatio`), `alcohol`, `whitelist` (for category restriction), and a `ColorReference` for UI tinting. There is no `Salinity` or similar property already defined — anything salt-specific (e.g. "drinking this makes you thirstier" or "unsafe in large amounts") would need a custom `Properties` block, most likely modeled on `TaintedWater`'s poison-effect fields.
- `media/lua/shared/Fluids/ISFluidContainer.lua` and `ISFluidUtil.lua` are the runtime API: items become fluid containers, fluid is added/removed/mixed in real amounts (not whole-item swaps).
- Client UI for this is already generic (`ISFluidContainerMenu.lua`, `ISFluidTransferUI.lua`, `ISFluidBar.lua`) — any item declared as a fluid container automatically gets pour/transfer/drink UI for whatever fluids it holds, including a custom one.

**Conclusion:** A `Saltwater` fluid is straightforward to define declaratively (new `fluid Saltwater { ... }` block) and will automatically inherit all the generic fill/pour/mix/transfer UI other fluids get. This is a much better foundation than the existing well mods' item-swap hack.

---

## Confirmed Gap: No Native "Boil Fluid Into Solid Item" Mechanic

This is the part that needs real design work, because the engine doesn't do it for us:

- There is no boiling-point / temperature property on fluids in `fluids.txt` — fluids carry no "if heated, becomes X" data.
- There is no existing vanilla recipe that consumes N units of a fluid from a container and outputs a solid item (checked `media/scripts/generated/recipes/recipes_fluids.txt` — the only fluid-adjacent recipes there are bottle/can-opening, which don't touch fluid amounts at all).
- There is no existing "boil water" / "purify water" mechanic left in the current codebase to copy from — searched for any river-water purification or boil-to-purify logic and found none in the current `media/lua/server` or `media/scripts`. (This may have existed in earlier PZ versions and been removed, or never existed in this form.)

**This means the salt-from-saltwater conversion has to be built as new mod logic**, not configured via existing data files. The realistic approach:

1. Saltwater is held in a fluid-container item (e.g. a pot) placed on a working heat source (campfire, stove burner — same heat-source detection vanilla cooking already uses for pots).
2. A periodic check (similar to how cooking food in a pot already polls temperature/time while on a heat source) watches the pot's fluid state while it is heating.
3. Once a "boiled long enough" threshold is reached, the mod's Lua removes the `Saltwater` fluid from the container (proportionally — e.g. 1 unit of salt item per N units of saltwater) and adds `Salt` item(s) to the pot or the player's inventory.
4. The container should end up empty (or partially full, if not all saltwater finished boiling) rather than the old mods' "swap to a different item" approach.

### Open design questions to resolve before implementation

- **Heat detection hook:** find and confirm the exact vanilla hook used for "is this container currently on an active heat source" (likely something in the cooking/`IsoObject` heat-source check or the existing `EveryOneMinute`/`EveryTenMinutes` Lua event combined with a check against the square's heat source). Needs direct verification against the cooking pot code path used for actual food items, not assumed by analogy.
- **Conversion ratio:** how much saltwater (in fluid units) should yield how much salt? Should likely be tuned against `PseudoSaltRecipes`' existing salt consumption rates so the full pipeline (dig well → fill → boil → ferment) feels balanced rather than trivial or grindy.
- **Does a `Salt` item already exist?** Need to check whether `PseudoSaltRecipes`/`PseudoTestRecipes` already define a salt item this mod should target, or whether `PseudoSaltwater` needs to define its own and the recipe mods need to consume it. This should be resolved with whoever owns those mods' item definitions before writing the boil-down code, to avoid duplicate/incompatible `Salt` items across the collection.
- **Disease/safety properties:** should drinking raw `Saltwater` directly be harmful (analogous to `TaintedWater`'s poison-effect properties) to give the player a reason not to just drink it instead of processing it? Optional but thematically consistent with `TaintedWater`'s existing pattern.
- **Partial boil-off vs. all-or-nothing:** does the conversion happen continuously as the pot sits on heat (gradual fluid amount decreasing into accumulating salt), or as a discrete "produces salt" event once a threshold is hit? Gradual is more realistic and reuses the same "tick while heating" hook either way, so it may not cost much extra complexity.

---

## Recommended Scope for This Mod

Keep `PseudoSaltwater` minimal and focused:

- Define the `Saltwater` fluid type (`fluids.txt`-equivalent mod script) with appropriate `Categories`/`Properties`.
- Implement the boil-to-salt mechanic as new Lua (heat-source polling + fluid removal + salt item creation), since no existing data-driven recipe path supports fluid-amount-aware conversion to a solid item.
- Do **not** reimplement well-digging or the salt extraction step — that's `PseudoSaltWell*`'s job, and those mods should be updated separately to fill containers with the new `Saltwater` fluid via `ISFluidContainer`/`ISFluidUtil` instead of their current item-swap hack, once this mod exists. That update is out of scope for this mod's own work.
- Do **not** implement the food-preservation use of salt — that's `PseudoTestRecipes`/`PseudoSaltRecipes`'s job; this mod only needs to produce a salt item they can consume.

---

## Key File References

| File | Why It Matters |
|------|-----------------|
| `media/scripts/generated/fluids.txt` | Declarative fluid type definitions; pattern to follow for `Saltwater` |
| `media/lua/shared/Fluids/ISFluidContainer.lua` | Core fluid container API (add/remove/amount) |
| `media/lua/shared/Fluids/ISFluidUtil.lua` | Helper functions for fluid transfer between items |
| `media/lua/client/Fluids/ISFluidContainerPanel.lua`, `ISFluidTransferUI.lua` | Generic fluid UI — works for any declared fluid with no extra mod UI code needed |
| `media/scripts/generated/recipes/recipes_fluids.txt` | Confirmed: no existing fluid-amount-aware recipe pattern to copy from |
| `mymods/PseudoSaltWell/42/media/lua/shared/TimedActions/ISFillPotFromWell.lua` | Existing item-swap hack — pattern to avoid, not extend |
| `mymods/PseudoSaltWell/42/media/lua/shared/TimedActions/ISEmptySaltwaterContainer.lua` | Same hack, the "empty" side |
| `mymods/PseudoSaltRecipes/`, `mymods/PseudoTestRecipes/` | Downstream consumers of a `Salt` item — coordinate item naming/ratio with these |

---

## Next Steps

1. Decide the open design questions above (especially the heat-source hook and conversion ratio) — likely worth a short investigation into the vanilla cooking pot temperature-check code before committing to an approach.
2. Confirm with the recipe mods whether a `Salt` item already exists to target, or whether this mod should own that definition.
3. Once resolved, write a DevCycle document per `doc/planning/DevelopmentProcess.md` to scope the actual implementation.
