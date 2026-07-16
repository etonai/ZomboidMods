# Converting PseudoSaltWell to the B42 Fluid System

**Author:** Claude (Fable)
**Created:** 2026-07-15
**Status:** Idea / design proposal — not scheduled into a DevCycle
**Game version analyzed:** Project Zomboid B42.19 (decompiled Java in `zombie42_19/`, scripts in `media/scripts/`)

---

## 1. Summary

Today the mod models "container of saltwater" as **12 hand-made Food items** (6 saltwater/salt pairs: pot, forged pot, kettle, copper kettle, bucket, forged bucket) that ride on the Food cooking pipeline (`IsCookable` + `ReplaceOnCooked`). This proposal replaces all of them with **one modded fluid — `SaltwaterBrine`** — stored in the containers' existing vanilla `FluidContainer` components, plus a small Lua system that converts heated brine into Salt items at a rate of **one `Base.Salt` per ~0.75 L of brine boiled off**.

What this buys us:

- **Any fluid container works** — pots, kettles, buckets, saucepans, jerry cans, bottles, rain barrels — with zero per-container items or recipes. The 12 custom items and 6 "Get Salt From X" recipes go away.
- **Free UI** — the vanilla fluid transfer panel, pour-on-ground, container fluid bar, and tooltips all work automatically.
- **Partial fills** — a half-full pot yields half the salt, which the current all-or-nothing item swap cannot express.
- **Gradual conversion** — salt appears progressively as water boils off, instead of one atomic swap at `MinutesToCook`.

The one thing the engine does **not** give us for free is the boil-off itself: the engine's fluid-boiling logic is hardcoded to vanilla fluids (TaintedWater → Water), with no hook for modded fluids. Section 5 covers the options; the recommendation is a Lua heat-watcher that mirrors the engine's own heating rules.

---

## 2. Current system (what gets replaced)

From `PseudoSaltWell/42/media/scripts/items/PseudoSaltWellItems.txt` and `recipes/PseudoSaltWellRecipes.txt`:

| Container | Saltwater item | Cook time | Salt yield (recipe) |
|---|---|---|---|
| Pot | `SaltwaterPot` → `SaltPot` | 120 min | 2 |
| Forged pot | `SaltwaterPotForged` → `SaltPotForged` | 120 min | 2 |
| Kettle | `SaltwaterKettle` → `SaltKettle` | 120 min | 2 |
| Copper kettle | `SaltwaterKettleCopper` → `SaltKettleCopper` | 120 min | 2 |
| Bucket | `SaltwaterBucket` → `SaltBucket` | 240 min | 7 |
| Forged bucket | `SaltwaterBucketForged` → `SaltBucketForged` | 240 min | 7 |

All are `ItemType = base:food` because **only `Food.update()` advances cooking time** (`zombie42_19/inventory/types/Food.java:401`, `:549`) — a plain item with `IsCookable` never cooks. The Lua side (`WellFillMenu.lua`, `ISFillPotFromWell.lua`, `ISFillKettleFromWell.lua`, `EmptySaltwaterMenu.lua`, `ISEmptySaltwaterContainer.lua`) does item-swap gymnastics: remove `Base.Pot`, add `SaltwaterPot`, and the reverse for emptying.

Pain points: every new container shape means a new item pair + fill action + empty action + extraction recipe + models; weights are frozen (a "Bucket with Saltwater" always weighs 10 even conceptually half-full); the items are drinkable Food with fake nutrition values; and none of it interoperates with vanilla fluid plumbing.

---

## 3. What the B42 fluid system provides (code-verified)

### 3.1 Modded fluids are first-class

`Fluid.Init()` (`zombie42_19/entity/components/fluids/Fluid.java:137-208`) loads every `fluid` script block. Names that don't match a vanilla `FluidType` enum entry become `FluidType.Modded`, keyed by string (`Fluid.java:150-161`). Save/load handles modded fluids by writing the string name (`Fluid.saveFluid` / `loadFluid`, `Fluid.java:220-248`), so world saves survive.

**Note:** the registry key is the *script name only*, not module-qualified (`FluidDefinitionScript.Load`, `zombie42_19/scripting/objects/FluidDefinitionScript.java:217-222` stores the bare `name`). A generic name like `Brine` could collide with another mod — use a distinctive name. `SaltwaterBrine` is probably safe; `PSW_SaltwaterBrine` is bulletproof (at the cost of an uglier debug name).

### 3.2 Fluid definition script syntax

Parsed by `FluidDefinitionScript.Load` (`FluidDefinitionScript.java:212-274`). Recognized keys: `DisplayName`, `ColorReference`, `Color`/`r`/`g`/`b`. Recognized blocks: `Categories`, `Properties`, `Poison`, `BlendWhiteList`, `BlendBlackList`. Vanilla examples in `media/scripts/generated/fluids.txt` (Water, TaintedWater) and `fluids_Alcoholic.txt` (blend lists).

Valid categories (`zombie42_19/entity/components/fluids/FluidCategory.java`): `Beverage, Alcoholic, Hazardous, Medical, Industrial, Colors, Dyes, HairDyes, Paint, Fuel, Poisons, Water`.

### 3.3 The target containers already have FluidContainer components

From `media/scripts/generated/items/normal.txt` — no mod items needed at all:

| Vanilla item | Capacity (L) | Notes |
|---|---|---|
| `Base.Pot` (normal.txt:4001) | 1.5 | `Tags = base:cookable`, RainFactor 0.8 |
| `Base.Kettle` (normal.txt:4105) | 1.5 | `base:cookable` |
| `Base.Kettle_Copper` (normal.txt:4130) | 1.5 | `base:cookable` |
| `Base.Bucket` (normal.txt:13864) | 10.0 | `base:cookable`, RainFactor 0.5 |

Forged pot/bucket variants (`Base.PotForged`, `Base.BucketForged`) likewise have components (verify capacities when implementing). Saucepans, mugs, jars, jerry cans, rain collectors come along for free.

### 3.4 The engine heats fluid-container items — but boiling is hardcoded

`InventoryItem.update()` (`zombie42_19/inventory/InventoryItem.java:1431-1487`):

1. For any item with a `FluidContainer` component sitting in a heated container (stove, campfire container, fireplace, BBQ, microwave), the engine raises the item's `itemHeat` toward the container temperature. Climbing above 1.0 requires the `base:cookable` tag (`InventoryItem.java:1451-1457`) — which the pots/kettles/buckets already have.
2. When `itemHeat > 1.6` and the container isn't empty (`InventoryItem.java:1459-1485`):
   - `TaintedWater` converts to `Water` at `0.01 × GameTime multiplier` per tick (0.6 on servers) — **hardcoded fluid check**.
   - `Petrol` is dumped and may start a fire — also hardcoded.
   - **No dispatch to script or Lua for other fluids.** A pot of `SaltwaterBrine` on a fire will heat up and then do nothing.

Consequences for us:

- The engine maintains `itemHeat` for our brine containers for free, exposed to Lua via `getItemHeat()` (`InventoryItem.java:3812`). `> 1.6` is the engine's own "boiling" threshold — we should use the same one.
- The actual brine → salt conversion must be our code (Section 5).
- Do **not** give `SaltwaterBrine` the `Water` category *and* expect purification semantics; also note the TaintedWater rule only touches the TaintedWater portion of a mixture, so brine blended with tainted water behaves sanely.

### 3.5 Crafting integration

`craftRecipe` inputs support fluids natively: `-fluid 0.2 categories[Water] mode:mixture` (coffee machine, `media/scripts/generated/entities/appliances/workstations/entity_coffeemachine_craftRecipe.txt:14`) or `-fluid 0.1 [RubbingAlcohol;Vodka]` (`recipes_medical.txt:160`). So future recipes (brining meat, salt licks, etc.) can consume `[SaltwaterBrine]` directly.

---

## 4. Proposed fluid definition

New file, e.g. `PseudoSaltWell/42/media/scripts/fluids/PseudoSaltWellFluids.txt`:

```
module PseudoSaltWellB42
{
    fluid SaltwaterBrine
    {
        ColorReference = LightSteelBlue,
        DisplayName = Fluid_Name_SaltwaterBrine,
        Categories
        {
            Hazardous,
        }
        Properties
        {
            ThirstChange = 25.0,      /* drinking seawater makes you thirstier */
            UnhappyChange = 20.0,
        }
        Poison
        {
            maxEffect = Mild,
            minAmount = 0.5,
            diluteRatio = 0.3,
        }
        BlendWhiteList
        {
            whitelist = true,
            fluids
            {
                SaltwaterBrine,
            }
        }
    }
}
```

Design choices, all adjustable:

- **Not category `Water`** — brine must not count as wash/drink water. `Hazardous` matches TaintedWater's treatment in UI warnings.
- **Poison block** mirrors the TaintedWater pattern (`fluids.txt:32-37`) so chugging brine is punished; `Properties` makes even a sip thirst-positive (matches the old items' `ThirstChange = 10/20`).
- **Self-only blend whitelist** keeps the first version simple: brine never mixes, so "liters of brine in container" is always unambiguous. A later version could allow blending with Water and compute salinity from the mixture ratio (see §8).
- **Translation**: add `Fluid_Name_SaltwaterBrine` to the mod's `Translate/EN` files (fluid display names go through `Translator.getFluidText`, `FluidDefinitionScript.java:229`).
- Salinity reference for tuning flavor text: real seawater is ~35 g/L; 0.75 L → one 0.2 kg salt unit is deliberately gamey (~10× rich). That's fine — it matches the old system's economy (see §6).

---

## 5. The conversion mechanic: brine + heat → salt

### Option A — Lua heat-watcher (recommended)

A server-side Lua system that mirrors the engine's own boiling rules for our fluid.

**Detection.** Every game minute (`Events.EveryOneMinute`), scan for candidate items: containers currently hot enough to cook. Practical scan strategy, cheapest first:

1. Maintain a registry of "interesting" world objects (stoves, campfires, fireplaces, BBQs) discovered via `OnObjectAdded` / cell load events, or lazily via a bounded square scan around each player (the only places boiling can happen are near a player-lit heat source; campfires burn out without players anyway).
2. For each such object with `obj:getContainer()` and `getContainer():getTemprature() > 1.6`, iterate contained items.
3. Candidate = item with a fluid container holding brine:
   `local fc = item:getFluidContainer(); if fc and fc:contains(Fluid.get("SaltwaterBrine"))` *(verify exact Lua binding names — Java methods `getFluidContainer()`, `FluidContainer.contains(Fluid)`, `Fluid.Get(String)` are public and `@UsedFromLua`)*.
4. Gate on the item's own heat, exactly like the engine: `item:getItemHeat() > 1.6` (`InventoryItem.java:1459`). This makes our behavior consistent with vanilla tainted-water boiling — same warm-up delay, same "pot just placed is still cold" behavior.

**Conversion.** Per game minute of boiling, for each candidate:

```lua
local LITERS_PER_MINUTE = 0.00625        -- 0.75 L / 120 min: matches old pot cook time
local LITERS_PER_SALT   = 0.75

local boiled = math.min(fc:getSpecificFluidAmount(brine), LITERS_PER_MINUTE)
fc:adjustSpecificFluidAmount(brine, fc:getSpecificFluidAmount(brine) - boiled)

local md = item:getModData()
md.PSW_boiledLiters = (md.PSW_boiledLiters or 0) + boiled
while md.PSW_boiledLiters >= LITERS_PER_SALT do
    md.PSW_boiledLiters = md.PSW_boiledLiters - LITERS_PER_SALT
    item:getContainer():AddItem("Base.Salt")   -- appears beside the pot on the fire
end
```

Key details:

- **Progress lives in `getModData()`** on the container item, so it persists through saves and interrupted boils, and a pot can be topped up mid-boil without losing progress.
- **The brine amount visibly drops** as it boils — the fluid bar becomes the progress bar. No custom UI needed.
- **Salt items spawn into the same `ItemContainer` that holds the pot** (the campfire/stove container), like `ReplaceOnCooked` does today (`Food.java:413` adds to `this.container`). The player collects loose salt next to the emptied pot. Alternative flavor: hold the salt until the brine hits zero, then emit everything at once — slightly more "pan of salt crust" feeling, same code shape.
- **Leftover fraction** (< 0.75 L worth) stays in modData; design decision whether a final partial residue rounds up to one salt when the container runs dry (recommend yes if ≥ half a unit, else it evaporates — avoids exploit of repeated 0.7 L boils… actually the modData carry-over already prevents that exploit; rounding is pure UX).
- **Rate tuning:** 0.00625 L/min ≈ vanilla's client TaintedWater rate order of magnitude and reproduces the old 120-minute pot. The bucket becomes 10 L → ~26 boil-hours; see §6 for the balance discussion.
- **MP:** run this only where items actually update (server authoritative; `GameClient.client` guard mirrored from `FluidContainerUpdateSystem.java:37`). Item stat sync afterwards — vanilla uses `GameServer.sendItemStats` from Java; from Lua, mutating the fluid container on the server side and letting normal container sync handle it should suffice, but this is the top MP-testing risk item.

**Why not `Events.OnTick`:** per-minute granularity matches `Food.update()`'s own cook cadence (`lastCookMinute` check, `Food.java:389-395`) and keeps cost negligible.

### Option B — player-driven craftRecipe ("Boil Off Brine")

A `craftRecipe` with `-fluid 0.75 [SaltwaterBrine]` input and `item 1 Base.Salt` output, `time` ≈ a couple in-game hours, tagged/placed so it's only available at a lit heat source (compare the coffee-machine workstation recipes). Pros: zero custom simulation code, uses stock crafting UI, trivially MP-safe. Cons: it's an *attended* timed action — the player stands there — which loses the current mod's core "set the pot on the fire and walk away" loop. **Rejected as the primary mechanic**, but worth shipping *in addition* as a "quick boil small batches" convenience, since it's ~20 lines of script.

### Option C — keep a Food bridge item

Keep one invisible `ItemType = base:food` "brine charge" item that the fill action inserts alongside the fluid… discarded: it reintroduces everything we're trying to delete and desyncs from the fluid amount.

---

## 6. Yield & balance

At 0.75 L per salt:

| Container | Capacity | Salt (new) | Salt (old) | Old cook time |
|---|---|---|---|---|
| Pot / forged pot | 1.5 L | 2 | 2 | 120 min |
| Kettle / copper kettle | 1.5 L | 2 | 2 | 120 min |
| Bucket / forged bucket | 10 L | 13 | 7 | 240 min |

Pots and kettles come out identical to the current system — nice validation of the 0.75 number. The bucket nearly doubles yield *and* takes ~26 boil-hours at pot rate, which is both stronger and clunkier than the old 240-min → 7 salt. Options:

1. Accept it (buckets become the bulk-evaporation vessel; time-gated, feels right).
2. Raise `LITERS_PER_SALT` to ~1.4 for parity with the old bucket, breaking pot parity.
3. Keep 0.75 but let wide containers boil faster (roasting pan/bucket surface-area multiplier stored in a lookup table). Most simulationist, most tuning knobs.

Recommend option 1 for the first cut; it's the only one with no extra rules to explain.

---

## 7. Migration & demolition plan

Phase-able; each phase is testable alone.

1. **Add the fluid** (`fluids/PseudoSaltWellFluids.txt` + translation). Verify in-game: debug fluid editor shows it; a pot can hold it via Lua console.
2. **Rewrite the well interactions.** `WellFillMenu.lua` context menu now offers "Fill … with saltwater" for *any* main-inventory/hotbar item where `item:getFluidContainer() ~= nil` and `fc:canAddFluid(Fluid.get("SaltwaterBrine"))`. The timed actions (`ISFillPotFromWell`, `ISFillKettleFromWell` — merge into one `ISFillFromSaltWell`) stop doing item swaps and instead `fc:addFluid(brine, math.min(fc:getFreeCapacity(), litersPerAction))`. `EmptySaltwaterMenu.lua` / `ISEmptySaltwaterContainer.lua` are deleted outright — the vanilla fluid UI already pours/empties.
3. **Add the boil watcher** (Option A) as `media/lua/server/PSWBrineBoiling.lua`.
4. **(Optional) Add the attended craftRecipe** (Option B).
5. **Legacy item handling.** Existing saves may contain the 12 old items. Keep the item scripts (marked `OBSOLETE = true`? — verify B42 flag) for one release so saves load, and add tiny one-way conversion recipes ("Pour out old saltwater pot" → `Base.Pot` + fluid can't be recovered, or a scripted swap granting the base container + equivalent brine via `OnCreate` Lua). Remove the 6 "Get Salt From X" recipes only after the conversion path exists.

Net deletion when done: 12 item definitions, 6 recipes, 2 timed actions, 1 context-menu file → replaced by 1 fluid block, 1 timed action, 1 watcher file.

---

## 8. Open questions / risks (verify during implementation)

1. **Lua binding surface.** `FluidContainer.addFluid / contains / getSpecificFluidAmount / adjustSpecificFluidAmount / canAddFluid`, `Fluid.Get`, `InventoryItem.getItemHeat` are public Java and mostly `@UsedFromLua`, but exact Lua-side casing (`Fluid.Get` vs `Fluid.get`) must be confirmed in-game.
2. **Campfire container access from Lua** — confirm the B42 campfire entity's `ItemContainer` (named "Campfire", per `Food.java:522-525`) is reachable from the world object during the scan, and that lit-ness maps to `getTemprature() > 1.6`.
3. **Fluid name collision** — decide `SaltwaterBrine` vs prefixed `PSW_SaltwaterBrine` before first release; renaming a modded fluid later breaks saves (string-keyed persistence, `Fluid.java:225`).
4. **World fluid containers** (rain barrels, troughs) can now hold brine via transfer UI. Rain dilution: `FluidContainerUpdateSystem` (`FluidContainerUpdateSystem.java:70-100`) adds Tainted/clean water to rain catchers — with a self-only blend whitelist, `canAddFluid` should refuse and the barrel just won't collect… verify it doesn't error or overwrite. (If blending is later allowed for dilution mechanics, rain *should* dilute brine — pleasant emergent realism, needs the salinity math.)
5. **`getItemHeat` on items inside microwaves/ovens vs. open fires** behaves per `InventoryItem.java:1436-1457`; bucket-on-campfire needs a placement test (the old mod already fought campfire issues — see `doc/ideas/errorCampfire.txt`).
6. **Performance** of the per-minute scan is bounded by heat-source count near players; the registry approach makes it O(lit sources), effectively zero.
7. **The static "full pot" models** (`SaltwaterPotFull` etc.) are no longer used; vanilla fluid items render fill state via `IconFluidMask` where defined. Cosmetic-only regression: a pot of brine on the ground looks like a plain pot unless we keep model swap logic (not recommended — vanilla water pots have the same limitation).

---

## 9. Bottom line

The fluid system is the right home for this mod: modded fluids are fully supported and save-safe, every target container already has a `FluidContainer`, and the only missing engine piece — custom boil behavior — is cleanly reproducible in ~60 lines of server Lua using the engine's own `itemHeat > 1.6` convention. The result deletes most of the mod's surface area while making it *more* general (any container, partial fills, vanilla UI) and keeping pot/kettle balance exactly where it is today.
