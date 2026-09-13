# Composter Analysis

**Created:** 2026-09-06
**Updated:** 2026-09-12 — re-verified against Project Zomboid 42.20.4
**Version:** Project Zomboid 42.20.4 (decompiled sources in `zombie42_20_4/`, scripts in `media42_20_4/`). Originally analyzed against 42.19. All findings below are unchanged except one sandbox option range correction (see "Verified Against 42.20.4").
**Status:** Verified against decompiled Java + shipped Lua

## Overview

The composter (`IsoCompost`) is one of the only containers in the game that runs its own background simulation loop on `update()`, silently consumes/deletes items it holds, and converts that consumption into an abstract resource value (`compost`, a float 0–100) that is *not itself an item*. That resource is later withdrawn from the object via a menu-driven conversion into a real item (a partially-filled `Base.CompostBag`). This combination — timed passive item destruction + an internal float stat + a manual "cash out into item" action — does not have a close analogue elsewhere in vanilla PZ (compare: rain collectors just accumulate water in a normal fluid container; the fridge/freezer just change food decay rates; the butter churn/still are player-driven single-step conversions, not passive multi-item accumulators).

## Core Data Model — `IsoCompost.java`

Location: `zombie42_19/iso/objects/IsoCompost.java`

```java
private static final float MaximumCompost = 100.0F;
private static final int DefaultCapacity = 30;
private float compost;          // 0..100, persisted
private float lastUpdated = -1.0F;
```

- `compost` is a plain float clamped to `[0, 100]` by `setCompost()` (line 209-211). It is **not** an inventory item and has no weight — it lives purely as a field on the world object and is saved/loaded via `save()`/`load()` (raw float writes, lines 183-197).
- The container itself (`this.container`) is a normal `ItemContainer` of type `"composter"` (`ContainerType.COMPOSTER`), capacity 30 by default, overridable per-sprite via the `CONTAINER_CAPACITY` Isometric property (line 67). So capacity is a property of the *tile entity's sprite*, not hardcoded — a modded composter sprite can declare a different capacity for free.

## The Update Loop (the "unique mechanic")

`update()` (lines 71-145) runs once per world-hour-delta, server-side only (`!GameClient.client`). Per tick it:

1. **Refreshes worms.** Any `Base.Worm` item in the container that is still fresh has its age reset to 0 (line 89-92) — worms placed in a composter never rot as long as they stay fresh, and are the trigger for worm breeding below.
2. **Iterates every item in the container** looking for `Food` items that are not tagged `CantCompost`:
   - Non-worm food ages normally server-side (`food.updateAge()`).
   - If the food `isRotten()` **or** is tagged `IsCompostable` (dung items — see below), it accumulates `compostTime` by the elapsed hours, and its `rottenTime` is pinned to 0 (so it never triggers a "disappear from age" removal from elsewhere — the composter fully owns its fate once accepted).
   - Once `compostTime >= SandboxOptions.getCompostHours()` (sandbox `CompostTime` option: 168/336/504/672/1008/1344 hours, default index 2 = **336 hours / 14 days**), the item **converts**:
     - `compostValue = abs(food.getHungChange()) * 2`, falling back to `abs(food.getWeight()) * 10` if `HungChange` is 0 (e.g. dung items, which have no hunger value — this is why the dung items all have small `Weight` values like 0.01–1.0, directly controlling how much compost % they're worth).
     - `compost += compostValue`, clamped to 100.
     - The item is fully deleted from the world (`item.Use()` with `CurrentUses=1`, then `addToProcessItemsRemove`) — **this is literally the "contents disappear" behavior you noticed.**
     - **Worm breeding side-effect:** if ≥2 fresh worms are present and it is *not* winter-outdoors, a new `Base.Worm` is spawned into the container on every single conversion event. With enough compostable throughput, a composter is a positive-feedback worm farm.

So the "container that eats its own contents and turns them into a hidden percentage" is a deliberate, single-purpose design: it's a timed, multi-item batch-conversion queue with per-item value weighting, hidden behind one float.

## Sprite State Reflects the Float

`updateSprite()` (lines 147-161) swaps between two hardcoded sprite pairs purely based on a **10% threshold** on `compost`:
- `camping_01_19` (empty) ↔ `camping_01_20` (full) — the tent/camping-style composter
- `carpentry_02_116` ↔ `carpentry_02_117` — the built wooden composter

There is only one visual breakpoint (10%), not a gradient — visually the bin looks "full" any time it's ≥10% done, all the way to 100%. `MOCompost.lua` (world-gen) exploits this same pair by randomizing an initial `compost` value of 0-10 or 10-100 depending on which pre-placed sprite variant a map artist used (lines 17-23), i.e. level designers can pre-seed decorative composters with a starting percentage just by picking the sprite.

## Withdrawal: `ISGetCompost` / the Compost Bag Menu

Files: `media/lua/shared/TimedActions/ISGetCompost.lua`, `ISAddCompost.lua`, menu wiring in `media/lua/client/ISUI/ISWorldObjectContextMenu.lua:351-399`.

Key constants (shared by both directions):
```lua
COMPOST_PER_BAG = 10                                  -- % of composter per full CompostBag
USES_PER_BAG = 1 / CompostBag:getUseDelta()           -- CompostBag UseDelta = 0.25 -> 4 uses/bag
COMPOST_PER_USE = COMPOST_PER_BAG / USES_PER_BAG      -- = 2.5 compost-% per "use"
```

- **Getting compost out:** the player needs an empty/partial `Base.CompostBag` *or* an empty sandbag (`HOLD_COMPOST` tag) in inventory. The context menu offers one sub-option per eligible bag, each showing exactly how much of the composter's current % that specific bag can absorb (`min(percent, availableUses*COMPOST_PER_USE)`). `ISGetCompost:complete()` converts `floor(amount/COMPOST_PER_USE)` uses into bag fill (via `setUsedDelta`) and decrements the composter's `compost` by the same amount — **the composter's float is a shared, drainable resource pool**, not a one-shot item spawn. Multiple players/bags can incrementally drain it.
- **Putting compost back in (recycling a used bag):** `ISAddCompost` lets you dump a *used* CompostBag's remaining content back into a composter (`compost:getCompost() + COMPOST_PER_USE <= 100` gate), converting bag uses back into composter %. This means compost is actually fungible and transportable between composter instances via bag as an intermediate carrier — you can farm one composter and top off another, or consolidate several partially-full composters' output into one bag before depositing.
- The resulting item (`Base.CompostBag`, tag `base:compost`) is a `drainable` item exactly like Fertilizer, and is what `ISFertilizeAction` (farming) actually consumes as plant fertilizer — so the entire mechanic exists to be an alternate fertilizer-production pipeline (`claude_fertilizerAnalysis.md` covers the consumption side).

## Item Eligibility Rules

- Accepts any `Food`-type item without the `CantCompost` tag.
- Two acceptance paths: (a) natural rot (`isRotten()`), or (b) explicit `IsCompostable` tag, which currently is applied only to the `Dung_*` items (turkey/chicken/cow/deer/mouse/pig/rabbit/raccoon/rat/sheep, `media/scripts/generated/items/food.txt:1211-1329`) — these are inedible (`CantEat=true`), have no hunger value, and rely on the weight-fallback formula for their compost value. This is the intended "manure" pathway; dung doesn't need to rot first.
- `Base.Worm` is special-cased entirely outside the rot/compost pipeline — worms are never composted, only kept fresh and multiplied.

## Balance-Relevant Numbers (as coded, 42.19)

| Constant | Value | Source |
|---|---|---|
| Max compost | 100% | `IsoCompost.MaximumCompost` |
| Default container capacity | 30 items (sprite-overridable) | `IsoCompost.DefaultCapacity` / `CONTAINER_CAPACITY` property |
| Compost time to convert one item | 336 hours (14 days) default; sandbox range 168–2016h | `SandboxOptions.getCompostHours()` |
| Compost-% per full CompostBag | 10% | `ISGetCompost`/`ISAddCompost` `COMPOST_PER_BAG` |
| Compost-% per CompostBag "use" | 2.5% | derived from `CompostBag.UseDelta = 0.25` |
| Worm breed trigger | ≥2 fresh worms present, not winter+outdoors, on every conversion tick | `IsoCompost.update()` |
| Sprite "full" visual threshold | ≥10% | `updateSprite()` |

## Mod-Exploit Angles

Because the mechanic is a generic "value accumulator fed by consuming tagged container contents, cashed out via a scripted timed action," it generalizes well beyond fertilizer:

1. **Reskin the whole pipeline for a new resource.** `IsoCompost`, `ISGetCompost`/`ISAddCompost`, and the `CompostBag` item are all closed-form and tag-driven (`IsCompostable`/`CantCompost`, `ContainerType.COMPOSTER`). A mod could add a *new* container type with its own Java-free clone written entirely in Lua (there's no compost-specific native code path other than the `IsoCompost` class itself — a Lua-only mod would need to either reuse `IsoCompost`/the `composter` container type directly, or drive an equivalent loop from a custom `OnTick`/`EveryHours` event against a normal container + a persisted mod-data float). Reusing the existing entity is far cheaper: change what tag counts as "compostable" and what item the bag becomes.
2. **Weight-based value tuning is already exposed.** Since compost value falls back to `weight * 10` for zero-hunger items, any new junk item just needs a `Weight` and the `IsCompostable` tag (no HungerChange required) to participate — an easy lever for adding "put trash here to convert to X" mod content (e.g., manure from new animals, compostable mod food scraps) without touching Java.
3. **Bag-mediated resource transport is reusable.** The get/add-compost pair demonstrates a pattern for a *portable, quantized, refillable resource carrier* (partial-use drainable item ↔ world-object float, bidirectional) that could back other slow-passive-production buildings (e.g., a mod-added rain-fed mineral leacher, a slow charcoal kiln, a batch cheese cave) by copying the `COMPOST_PER_BAG`/`COMPOST_PER_USE` math against a different drainable item and container type.
4. **Composter capacity is a free per-sprite balance knob.** Since capacity reads `CONTAINER_CAPACITY` off the sprite properties (`IsoCompost.java:67`) rather than being hardcoded, a mod can ship a bigger/smaller composter model+sprite entry with zero Java/Lua logic changes, just a new entity + `CONTAINER_CAPACITY` prop, for a "modded compost bin sizes" style variant pack.
5. **Worm-farming as an intentional side loop.** The ≥2-fresh-worm breeding rule (uncapped by container-space checks other than normal container capacity) means a composter maintained with a worm pair and steady compostable throughput passively multiplies worms for fishing bait — worth surfacing in any farming/fishing-integration mod, and easy to re-tune (the `2` worm threshold and 1-worm-per-conversion output are the only knobs, both trivially overridable by re-deriving `IsoCompost` in Lua if you want a from-scratch clone, or by patching the sandbox/derived class if you go the reuse route).
6. **No player-facing cap on simultaneous composters.** Nothing in this code limits how many `IsoCompost` objects a player can build/drain, and the get/add actions never check ownership — a base with many composters is a straightforward (if slow, given the 14-day default cycle) fertilizer factory; sandbox's `CompostTime` option is the only vanilla throttle, so a "compost time" balance mod is a one-line `SandboxOptions`-driven change already exposed to server admins without any code mod at all.

## Verified Against `zombie42_20_4`/`media42_20_4`

**Checked:** 2026-09-12

- `IsoCompost.java` diffed byte-for-byte between `zombie42_19/` and `zombie42_20_4/`. The
  only changes in the file are: (1) the `lastUpdated` bounds-check was refactored into
  `GameTime.checkHours(this.lastUpdated, worldAgeHours)` (previously inline `if`/`else if`)
  — the same cosmetic refactor already noted in the Washing Machine analysis, no behavioral
  change; (2) the `Thump()` method signature and internal zombie-thump-damage bookkeeping
  changed (`thumpEventCount` parameter, `ThumpDamageRender` hook) — this is unrelated to the
  compost mechanic, it only affects how much damage zombies thumping the composter object
  deal to its health. **All compost accumulation, conversion, worm-breeding, and capacity
  logic (lines 71-145, 209-211) is byte-for-byte identical.**
- `ISGetCompost.lua` and `ISAddCompost.lua` are byte-for-byte identical between `media/` and
  `media42_20_4/` — the withdrawal/deposit math (`COMPOST_PER_BAG = 10`,
  `COMPOST_PER_USE = 2.5`) is unchanged.
- The 10 `Dung_*` food items and their `Tags = base:iscompostable` / `IsDung = true` fields
  are byte-for-byte identical between `media/scripts/generated/items/food.txt` and
  `media42_20_4/scripts/generated/items/food.txt`.
- **One correction:** `SandboxOptions.java`'s `CompostTime` enum now has **8** steps in
  42.20.4, not 6 as originally documented — `getCompostHours()`
  (`zombie42_20_4/SandboxOptions.java:442-452`) maps `1..8` to `168 / 336 / 504 / 672 /
  1008 / 1344 / 1680 / 2016` hours, extending the previously-documented 168–1344h range up
  to 2016h (84 days) at the new maximum setting. The default index (2 → 336 hours / 14 days)
  is unchanged.

No other structural or balance-relevant changes were found. The mod-exploit angles and
general design analysis above apply unchanged to 42.20.4.

## Open Questions / Not Yet Verified

- Whether non-Food-tagged items (e.g. compostable crafted items) can be added to the
  container tag-wise; the container itself doesn't appear to filter *input* (that's likely
  UI-side, via `ContainerType.COMPOSTER` restrictions not inspected here) — worth confirming
  before assuming any item can be tagged `IsCompostable` and dropped in freely by players
  versus only spawned pre-tagged (dung is spawned with the tag already; no code path was
  found that lets a *recipe* apply `IsCompostable` to an existing item).
