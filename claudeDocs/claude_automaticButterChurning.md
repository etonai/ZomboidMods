# Mod Design: Automatic Butter Churning Machine

**Created:** 2026-08-30
**Game Version target:** Project Zomboid 42.19 (build 42 entity-component system)
**Related analyses:** [claude_butterChurn.md](claude_butterChurn.md), [claude_amphoraAnalysis.md](claude_amphoraAnalysis.md), [claude_washingMachineAnalysis.md](claude_washingMachineAnalysis.md)

## 1. Concept (as specified)

A powered, washing-machine-like appliance:

- Visually resembles a washing machine.
- Requires electricity to run.
- Is a **fluid container**, capacity 20 L, filled by the player transferring milk into it
  (Cow Milk and/or Sheep Milk, matching what the vanilla `churn_butter` recipe accepts).
- Is also a **storage container** (holds items), capacity 2 units of encumbrance, for the
  butter it produces.
- Has a **Start** button/context-menu action, like the washing machine's Turn On/Off.
- While running, makes the same sound as the manual Butter Churn.
- **Conversion rule:** every 500 seconds, if at least 5 L of milk is present, 5 L is removed
  from the tank and 1 Butter is added to the storage compartment. This repeats
  automatically, batch after batch, for as long as the machine is running, powered, has
  ≥5 L of milk, and has room in its output storage — so a full 20 L tank yields 4 Butter
  total after four consecutive 500 s batches (2000 s), not all at once.

This is a **fixed single-batch, repeating** conversion rule — mechanically identical, batch
for batch, to the vanilla Butter Churn's own `churn_butter` recipe (5 L milk → 1 Butter,
`time = 500`). The whole design challenge is making that existing batch repeat
*automatically in the background* (no crafting-window babysitting) and *gated behind
power*, rather than needing to reinvent the batch math itself — see §3.

## 2. Why this can't be a straight copy of either reference object

From the prior analyses in this folder:

- **Butter Churn (`ChurnBucket`)** uses the scripted-entity `CraftBench` component plus a
  `craftRecipe` (`churn_butter`) run through the same "hand craft" menu/UI system as ordinary
  player crafting recipes (`ISCraftBenchPanel` → `ISHandCraftPanel`). Its recipe shape (5 L
  milk → 1 Butter, `time = 500`) is exactly the batch this design wants to reuse, but
  `CraftBench` has no independent background ticking outside that UI-driven craft flow, and
  no power-requirement concept, so it can't repeat unattended or be power-gated as-is.
- **Washing Machine (`IsoClothingWasher`)** gets its power check, fluid check, Start/Stop
  toggle, and 90-in-game-minute background cycle from a **hard-coded Java class**
  (`ClothingWasherLogic`) ticking every frame via `IsoObject.update()`. A content mod (no
  compiled Java) cannot add a new class like this — mods can't introduce new native
  `IsoObject` subclasses, only reuse/configure existing ones or build on the **scripted
  entity system** (data + Lua hooks), which is what `ChurnBucket`/`Amphora` use.

So the two closest vanilla precedents split the very features this design needs: the
Butter Churn's *recipe/output* shape (milk → butter, 5 L → 1 unit) and the Washing
Machine's *power-gated, background-ticking, Start/Stop, looping-sound appliance* shape. A
mod has to build a new scripted entity and reassemble those pieces itself — some of them
(power-gating, "convert all complete multiples in one shot") aren't offered out of the box
by the entity-crafting system as observed in this codebase.

## 3. Recommended architecture

Because the conversion rule is now a flat, fixed batch (5 L → 1 Butter every 500 s,
repeating) — mechanically identical to the vanilla `churn_butter` recipe — this can lean on
the **existing entity-crafting engine** far more than a fully custom tick handler would,
rather than reinventing the batch math in Lua. Specifically:

- Use `component CraftLogic` (not `CraftBench`) on the new entity, with `StartMode =
  Automatic`, hosting a recipe shaped exactly like `churn_butter` (5.0 fluid milk
  `[CowMilk;SheepMilk] mode:mixture` → 1 `Base.Butter`, `time = 500`) but tagged for this
  entity instead of `ChurnBucket`.
- `CraftLogic` (unlike `CraftBench`) *is* watched by a background system —
  `CraftLogicSystem.updateSimulation()` (`zombie42_19/entity/components/crafting/CraftLogicSystem.java:31`)
  — which ticks any entity with `ComponentType.CraftLogic` every simulation step regardless
  of whether its crafting UI window is open. No vanilla entity in the files surveyed
  actually uses plain `CraftLogic` (only its specialized siblings `DryingCraftLogic`,
  `MashingLogic`, `FurnaceLogic` appear in shipped content), so this exact combination is
  unproven in live vanilla data, but the class support is present and used the same way by
  those siblings — see Q1 below.
- `StartMode = Automatic` is exactly what gives the "press Start once, then it keeps
  producing batches on its own" behavior for free: `CraftLogicSystem` auto-restarts the
  recipe (`logic.getStartMode() == StartMode.Automatic && (logic.isDoAutomaticCraftCheck()
  || inputResources.isDirty())`, line 102) every time a batch finishes and ingredients are
  still available — no custom repeat-loop needed. A context-menu "Start" option (mirroring
  `toggleClothingWasher`) would call the entity's existing start-request API
  (`logic.isStartRequested()`/`setRequestingPlayer()`) to kick off the first batch; the
  machine then keeps going through as many 5 L batches as the tank and the output storage
  space allow, matching the 20 L → four 500 s batches example above.
- **Power gating** still needs custom Lua, since (as before) no entity-component script
  surveyed has a `Powered`/`RequiresElectricity`-style flag — only the legacy hard-coded
  appliances and their Lua UI handlers check `haveElectricity()`. The good news is
  `CraftLogicSystem` already calls a Lua hook on *every tick* of a running craft —
  `craftData.luaCallOnUpdate()` (`CraftLogicSystem.java:83`, wired to
  `CraftRecipeData.luaCallOnUpdate()`) — which a custom `OnUpdate` Lua function on this
  recipe could use to check the entity's square for power each tick and force-stop the
  logic if power is lost, mirroring `ClothingWasherLogic`'s own mid-cycle power-loss
  shutoff. An `OnTest`-style check (recipes already support `OnCreate`/`OnStart`/`OnFailed`
  Lua calls per `CraftRecipe.LuaCall`, seen in `CraftRecipeData.java`) would similarly gate
  whether a *new* batch is even allowed to start while unpowered.

This is a substantially thinner custom-code footprint than a from-scratch Lua tick system:
the repeating 5 L/1 Butter batch itself is standard recipe data, and only the power check is
bespoke.

## 4. Proposed entity script

Sketch, following the shape of `entity_amphora.txt` / `entity_butter_churn.txt`:

```
module Base
{
    entity AutoButterChurn
    {
        component UiConfig
        {
            xuiSkin = default,
            entityStyle = ES_AutoButterChurn,
            uiEnabled = true,
        }
        component FluidContainer
        {
            ContainerName = AutoButterChurn,
            Capacity = 20.0,           -- see Q3: unit-to-liter mapping unverified
            InitialPercentMin = 0.0,
            InitialPercentMax = 0.0,
            InputLocked = false,
            whitelist
            {
                Fluid CowMilk,
                Fluid SheepMilk,
            }
        }
        component Resources           -- wires the FluidContainer + item storage into CraftLogic's input/output groups
        {
            -- exact block shape modeled on entity_Drying_Rack.txt's Resources component;
            -- needs confirming against a working entity example with BOTH a FluidContainer
            -- and an item-storage container (2 encumbrance capacity) on the same entity
            -- (not seen in the vanilla entities surveyed for this doc -- see Q2)
        }
        component CraftLogic
        {
            Recipes = AutoButterChurn,   -- new recipe tag, same shape as churn_butter
            StartMode = Automatic,
            inputGroup = churn_inputs,   -- the FluidContainer's resource group
            outputGroup = churn_outputs, -- the item container's resource group
        }
        component SpriteConfig
        {
            face S { layer { row = <washing-machine-like sprite row> } }
        }
        component CraftBenchSounds
        {
            -- reuse whatever sound-id the manual Butter Churn's craft flow plays;
            -- CraftBenchSoundsScript just maps an id -> a gameSound name
            -- (zombie42_19/scripting/entity/components/sound/CraftBenchSoundsScript.java),
            -- so this would need the manual churn's actual sound name, which wasn't
          -- identified in the Butter Churn analysis pass
        }
    }
}
```

Note there is deliberately **no `component CraftRecipe` build-from-materials block** here —
per the updated goal, this machine isn't built from raw materials at all. Instead it's
produced by *converting* an existing, already-placed Washing Machine (`IsoClothingWasher`)
in the world. See §4a.

## 4a. The Washing-Machine-Conversion Recipe

This is a different shape from every other recipe discussed in this doc: the *input* is an
existing world object (`IsoClothingWasher`, a legacy hard-coded appliance), and the
*output* is a new scripted entity (`AutoButterChurn`) placed in its spot — not an
inventory-item recipe at all. That rules out an ordinary `craftRecipe` block (which
consumes/produces inventory items), and instead points at the same mechanism the vanilla
Amphora lid toggle uses: a **context-menu action + custom timed action** that removes the
old world object and calls `square:addWorkstationEntity(...)` to place the new one — the
exact pattern already traced in `ISOpenCloseLid.lua`'s `:complete()` method in the Amphora
analysis (`media/lua/shared/TimedActions/ISOpenCloseLid.lua`).

Proposed shape, mirroring `toggleClothingWasher`/`ISOpenCloseLid`:

- A custom Lua context-menu hook adds a **"Convert to Automatic Butter Churner"** option
  whenever the player right-clicks an `IsoClothingWasher` (in-world washing machine or
  combo unit — see Q9), gated on:
  - Player has a **screwdriver** in inventory (kept, not consumed — `mode:keep`, the same
    pattern used by the manual Butter Churn's and Amphora's own build recipes for their
    tool inputs).
  - Player's **Electrical skill ≥ 5**.
  - The learnable-recipe requirement is satisfied — see Q8 (whether this needs a
    schematic/magazine to unlock, or is simply available once Electrical 5 is reached).
- Selecting it queues a custom timed action (new file, e.g. `ISConvertToAutoButterChurn.lua`,
  structurally modeled on `ISOpenCloseLid`) that, on `:complete()`:
  1. Removes the `IsoClothingWasher` from the square (`square:RemoveTileObject(...)`).
  2. Adds the new `AutoButterChurn` entity in its place
     (`square:addWorkstationEntity("AutoButterChurn", sprite)`), copying over
     health/max-health the same way `ISOpenCloseLid` does.
  3. Does **not** attempt to carry over the washing machine's own container contents
     (clothes) — see Q10 for what should happen if the washing machine being converted
     isn't empty.

## 5a. Comparison of the Conversion Recipe to Existing Patterns

| | Amphora lid toggle | Proposed washing-machine conversion |
|---|---|---|
| Trigger | Context-menu action | Context-menu action |
| Gate | None (always available) | Screwdriver (kept) + Electrical 5 (+ learnable? — Q8) |
| Mechanism | `ISOpenCloseLid` timed action, `square:addWorkstationEntity` | Same `addWorkstationEntity` mechanism, new custom timed action |
| Source object type | Scripted entity (`Amphora`/`AmphoraClosed`) | Legacy hard-coded `IsoObject` (`IsoClothingWasher`) |
| Target object type | Scripted entity | Scripted entity (`AutoButterChurn`) |
| Carries over contents? | Yes (fluid, via `copyFluidsFrom`) | Not planned (see Q10) — washing machine holds clothes, not milk |

The recipe itself (new tag `AutoButterChurn`, mirrors `churn_butter` almost exactly):

```
craftRecipe auto_churn_butter
{
    time = 500,
    Tags = AutoButterChurn,
    category = Farming,
    OnUpdate = AutoButterChurnCode.checkPower,   -- custom Lua hook, see below
    inputs
    {
        -fluid 5.0 [CowMilk;SheepMilk] mode:mixture,
    }
    outputs
    {
        item 1 Base.Butter,
    }
}
```

Custom Lua (new file, e.g. `AutoButterChurnCode.lua`) only needs to cover the power check,
since the repeating 5 L/1 Butter batch itself is handled by `CraftLogicSystem`:

```lua
-- pseudocode outline, not final API names
AutoButterChurnCode = {}

function AutoButterChurnCode.checkPower(craftRecipeData)
    local entity = craftRecipeData:getCharacter() -- or however the hosting entity/square is reached
    if not entity:getSquare():haveElectricity() then
        -- force-stop the in-progress craft, mirroring ClothingWasherLogic's
        -- mid-cycle power-loss shutoff (object.getContainer():isPowered() check)
    end
end
```

Start/Stop would be a context-menu option analogous to
`ISWorldObjectContextMenuLogic.toggleClothingWasher` (`zombie42_19/iso/ISWorldObjectContextMenuLogic.java:4961`),
greyed out with a tooltip when unpowered or empty, exactly like the vanilla washing
machine's Turn On option.

## 5. Sound while running

The vanilla Washing Machine loops `ClothingWasherRunning` via a sound emitter
(`ClothingWasherLogic.updateSound()`), playing `ClothingWasherFinished` once when the cycle
completes. The equivalent here would loop whatever sound name the manual Butter Churn's
craft action uses. That sound name was not identified during the Butter Churn analysis (it
wasn't traced past the recipe's category/timedAction), so it needs to be found before this
can be wired up — see Q7.

## 6. Comparison Table

| | Manual Butter Churn | Washing Machine | Automatic Butter Churn (proposed) |
|---|---|---|---|
| Implementation | Scripted entity + `CraftBench` recipe | Hard-coded Java `IsoObject` | Scripted entity + `CraftLogic` (Automatic) + custom power-check Lua |
| Needs power? | No | Yes | Yes (custom check via `OnUpdate` Lua hook) |
| Fluid container? | No (bucket held as an input item) | Yes (300, unrestricted) | Yes (20 L, milk-only whitelist) |
| Item storage? | No | Yes (clothes) | Yes (2 encumbrance, butter) |
| Conversion trigger | Player-run hand-craft menu | Background tick, fixed 90 min | Background tick (`CraftLogicSystem`), fixed 500 s |
| Conversion granularity | 1 fixed batch (5 L → 1 Butter) per craft | N/A (per-item wetness/dirt %) | Same 1 fixed batch (5 L → 1 Butter), auto-repeating |
| Runs unattended? | No (needs the crafting window flow) | Yes | Yes, via `StartMode = Automatic` |
| How it's obtained | Built from planks/nails | Found in the world / owned appliance | Converted from an existing Washing Machine (screwdriver + Electrical 5) |

## 7. Questions

1. **Combined fluid + item container on one entity.** No vanilla entity examined in this
   pass combines a `FluidContainer` with a separate item-storage container in the same
   entity (the Amphora is fluid-only; item-storage entities in the sample set didn't carry
   fluids). Is that combination confirmed to work in the b42 entity system, or should the
   butter output instead be modeled as, e.g., a "collect butter" context-menu action that
   spawns loose Butter items on the square/into the player's hands instead of a true
   2-encumbrance internal container?
   **Recommended:** attempt the combined-component entity first (closest to your spec);
   fall back to a "collect" action only if testing shows the entity system rejects a
   `FluidContainer` + item container on the same entity.

2. **`CraftLogic` on a plain (non-Drying/Mashing/Furnace) entity.** No shipped entity uses
   bare `component CraftLogic` — every example found (`DryingCraftLogic`, `MashingLogic`,
   `FurnaceLogic`) is one of its specialized subtypes. `CraftLogicSystem.java` explicitly
   watches for `ComponentType.CraftLogic` alongside `DryingCraftLogic`, so this should work,
   but it's untested territory. Is it acceptable to prototype with plain `CraftLogic` first
   and fall back to piggybacking on one of the specialized variants (e.g. treating this as a
   `MashingLogic`-style fluid-to-item conversion) if testing shows gaps?
   **Recommended:** yes, prototype with plain `CraftLogic` first — it's the closest
   conceptual match (a generic item/fluid recipe running in the background) and doesn't
   carry `MashingLogic`'s baked-in fermentation-temperature mechanics, which don't apply
   here.

3. **Fluid unit-to-liter mapping.** The Amphora's `FluidContainer.Capacity = 300` was
   interpreted as ~300 L in the Amphora analysis by convention, but no code was found in
   this pass that explicitly confirms 1 capacity unit = 1 liter (as opposed to some other
   internal unit). Should capacity be set to a literal `20.0`, or does this need to be
   verified in-game (e.g. by comparing the Amphora's capacity number against its known,
   wiki-documented real liter capacity) before locking in the number?
   **Recommended:** verify once in a test game (fill an Amphora, read the displayed
   liters) before finalizing; proceed with `Capacity = 20.0` as the working assumption.

4. **Output overflow behavior.** If the 2-encumbrance butter container is already full (or
   too full for one more Butter) when a 500 s batch completes, what should happen — pause
   (don't consume milk or produce butter until space frees up), drop the extra Butter on the
   ground/square, or block Start entirely whenever the output container isn't empty?
   **Recommended:** pause whenever the output container can't fit at least one more Butter —
   mirrors the washing machine's own `isItemAllowedInContainer` gating pattern, and avoids
   ever losing milk without getting butter for it. (2 encumbrance comfortably holds several
   Butter — each is 0.3 weight per `media/scripts/generated/items/food.txt:4539` — so this
   should rarely bind in practice.)

5. **Non-milk fluid handling.** Should the fluid container simply refuse/reject non-milk
   fluids on fill attempts (via the `whitelist` block sketched in §4), or accept anything
   but only ever convert the milk portion?
   **Recommended:** whitelist to Cow Milk + Sheep Milk only, for a simpler player mental
   model ("this only takes milk").

6. **Learnable recipe requirement.** You asked for "a recipe that players can learn" for
   the washing-machine conversion. Should this require a schematic/magazine item to unlock
   (the standard way PZ recipes are gated behind "learn," e.g. found manuals), or should it
   simply become available automatically once the player reaches Electrical level 5 (as
   many skill-gated recipes already are, with no separate unlock item)?
   **Recommended:** schematic/magazine unlock — it fits "a recipe that players can learn"
   more literally than an implicit skill-level unlock, and gives it a findable, lootable
   presence in the world consistent with how other specialty recipes are introduced.

7. **Reusing the manual churn's sound.** Which sound asset does the manual Butter Churn
   actually play while churning? This wasn't identified in the original Butter Churn
   analysis — it would need to be found before the "make the same noise" requirement can be
   wired up exactly as requested, versus substituting a similar existing loop (e.g. reusing
   `ClothingWasherRunning` or a mixer/motor sound) as a placeholder.
   **Recommended:** do a quick follow-up code search for the churn's sound before
   implementation; if none exists (the manual churn may be silent, using only generic craft
   UI sounds), substitute the closest existing "motor/mixing" loop instead.

8. **Power draw amount.** The washing machine draws `0.09` generator-fuel units per tick
   while running (`IsoClothingWasher.getGeneratorPowerConsumption()`). Should this machine
   use the same value, or a different (e.g. lower, since it's a smaller/simpler appliance)
   consumption rate?
   **Recommended:** reuse `0.09` as a reasonable starting point; adjust later based on
   playtesting/balance feedback.

9. **Which washing machines qualify for conversion?** The Washing Machine analysis found a
   `IsoCombinationWasherDryer` (combo unit) and an unexamined `IsoStackedWasherDryer` in
   addition to the plain `IsoClothingWasher`. Should the conversion recipe be offered on
   all three, or only the plain standalone washing machine?
   **Recommended:** plain `IsoClothingWasher` only, to start — the combo/stacked units add
   drying functionality that would otherwise just be destroyed by the conversion, which
   feels like a bigger balance/scope question than this design needs to resolve up front.

10. **Converting a non-empty washing machine.** If the washing machine being converted
    still has clothes (or is mid-cycle) in it, should the conversion be blocked until it's
    emptied, or should it proceed and drop/destroy the contents?
    **Recommended:** block the conversion option (grey it out with a tooltip, the same
    pattern `toggleClothingWasher` uses for "not available") until the machine's container
    is empty and it's turned off — simplest to implement and avoids any item-loss surprises.
