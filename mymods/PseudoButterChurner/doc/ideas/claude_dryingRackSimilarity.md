# Investigation: Modeling the Automatic Butter Churner on Drying Racks

**Created:** 2026-08-31
**Game Version:** Project Zomboid 42.20.4 (decompiled Java) / current `media/` scripts
**Related:** [claude_dryingAnalysis.md](../../../claudeDocs/claude_dryingAnalysis.md), [claude_automaticButterChurning.md](../../../claudeDocs/claude_automaticButterChurning.md), [claude_troughAnalysis.md](../../../claudeDocs/claude_troughAnalysis.md), `doc/planning/completed/DevCycle001.md`

## Requested Shape

- Input: milk, consumed in **5 L increments** (not a continuously-drainable tank — a fixed batch size, like the drying racks' fixed-count item batches).
- Output: **sticks of butter**, appearing one at a time as batches complete.
- Timing: **a few minutes per stick** — much shorter than any real drying rack recipe (which run in half-days), but the same *shape* of mechanic: consume input, wait, produce a different output, with visual feedback during the wait.
- Explicit ask: make it **operate like the drying rack**, not like the trough/rain-barrel "simple pour" pattern DevCycle 1 ended up chasing in Phase 17.

## Why This Is the Right Question to Ask

DevCycle 1 closed unresolved specifically because it tried to reconcile two incompatible vanilla UX patterns on the same entity (`doc/planning/completed/DevCycle001.md`, Phase 17):

- The **trough/rain-barrel "simple pour" UX** is gated on a single check, `hasComponent(ComponentType.FluidContainer)` (an entity-level component) — but `CraftLogic`-family components (`CraftLogic`, `DryingCraftLogic`, `MashingLogic`, `FurnaceLogic`) only ever read their inputs from `component Resources` groups, **never** from a sibling `component FluidContainer`. Phase 17 chose the pour UX and lost automatic batching as a result; the cycle closed with that version "confirmed not working," cause unknown.
- Phase 1 originally chose the opposite: `component Resources` + `CraftLogic`-style automation, and got automatic batching working in principle — but assumed (incorrectly, per Phase 17's own corrected notes) that a `Resources` fluid entry needed a *named* `fluidFilter` script object, and didn't establish whether milk could even go into `Resources` as a fluid type at all versus only as items.

**The drying rack sidesteps this conflict entirely, because it was never trying to get the pour UX in the first place.** Drying racks are loaded through the crafting-style `ISEntityWindow` (drag an item into an input `Resources` slot), not through a right-click "pour" interaction. If the butter churner adopts that same interaction model — deliberately giving up the trough-style one-click pour, in exchange for `CraftLogic`-driven automatic batching — the Phase 1/17 conflict doesn't apply, because both halves of the design (filling *and* automation) now agree on using `Resources`.

That reframing, on its own, is the main finding of this investigation. The rest of this document works out whether the engine actually supports a **fluid-type** `Resources` entry (needed since milk is a fluid, not an item like the crops drying racks handle) and sketches the entity.

## Can `Resources` Hold a Fluid Input? — Yes, Confirmed in Engine Code (Unused by Any Shipped Entity)

Every drying rack's `Resources` groups only ever declare `Item@Input@N` / `Item@Output@N@StackAny` entries — none of the drying-rack or leather-rack entities examined use a fluid resource. But the underlying engine fully supports it:

- `zombie/entity/components/resources/ResourceType.java` declares `ResourceType.Fluid` as a first-class sibling of `ResourceType.Item` (`Item((byte)1)`, `Fluid((byte)2)`), not a bolt-on.
- `zombie/entity/components/resources/ResourceFluid.java` is a complete, working implementation: it owns its **own internal `FluidContainer`** (`this.fluidContainer = FluidContainer.CreateContainer()`), sized from the blueprint's capacity (`loadBlueprint()`: `this.fluidContainer.setCapacity(bp.getCapacity())`), and implements `canDrainFromItem(InventoryItem)` / `drainFromItem(InventoryItem)` — the exact mechanism needed for a player to drag a milk-holding item (a bottle, jug, bucket — whatever in-game item carries `CowMilk`/`SheepMilk` in its own `FluidContainer`) into the slot and have it drain into the resource. This is precisely the UI interaction drying racks already use for items, just for a fluid.
- `ResourceBlueprint.Deserialize()` (`ResourceBlueprint.java:203-251`) parses entries as `id@type@io@capacity[@StackAny][@filter@channel@flags]`, with `type = ResourceType.valueOf(elements[1])` reading straight from the script text — nothing restricts that to `Item`. A raw `Fluid@Input@5` line inside a `group` block (mirroring exactly how `Item@Input@20` is written in the drying-rack scripts) auto-generates a 4-element serial (`craft_inputs_0@Fluid@Input@5`) through the same `groupName_index@line` fallback path (`ResourcesScript.loadResourceBlock()`) that `Item@Input@20` already goes through — same script syntax, same parser, different `ResourceType`.
- `ResourceFluid`'s filter is set via `this.fluidFilter.setFilterScript(this.getFilterName())`, where `getFilterName()` reads the blueprint's optional `filter` string — this is the **named `fluidFilter` script object** pattern DevCycle 1 Phase 1's notes already flagged (not an inline `whitelist` block, which is specific to `component FluidContainer`, a different, entity-level thing). So a fluid `Resources` entry restricted to milk needs a small named `fluidFilter` script object (e.g. one allowing `CowMilk`/`SheepMilk`), exactly as DC1 originally suspected before Phase 17 reversed course.

**Caveat, stated plainly:** this is engine-code-confirmed but **not exercised by any shipped entity** in this build — the same category of risk DC1 already ran into with bare `component CraftLogic` (also unused in vanilla, per the original design doc's Q2). Choosing `Fluid@Input` inside `Resources` means being an early/first user of that specific code path, same as choosing bare `CraftLogic` would have been. It is lower-risk than that specific prior gap only in that the class involved (`ResourceFluid`) is a complete, non-experimental-looking implementation with save/load, tooltip, and network sync all written out — it doesn't read like a half-finished or deprecated feature.

## Choosing `DryingCraftLogic` Over Bare `CraftLogic`

DevCycle 1's original design (`claude_automaticButterChurning.md` §3, Q2) proposed bare `component CraftLogic` with `StartMode = Automatic`, explicitly flagging that **no shipped entity uses plain `CraftLogic`** — only its specialized subclasses (`DryingCraftLogic`, `MashingLogic`, `FurnaceLogic`) appear in real content.

Given the explicit request to model this on the drying rack, the natural resolution is to **use `DryingCraftLogic` itself**, not bare `CraftLogic`:

- It is the exact component 12 shipped `craftRecipe`s and 7 shipped entities (`Drying_Rack`, `Simple_Drying_Rack`, `Herb_Drying_Rack`, `Simple_Herb_Drying_Rack`, `DryingRackLarge/Medium/Small`) already run through, in this exact build — the most heavily-proven `CraftLogic` variant available.
- It supports `StartMode = Automatic` (inherited, same `StartMode` enum every `CraftLogic` subclass shares) — same "press Start once, it keeps batching" behavior the original design wanted from bare `CraftLogic`.
- It resolves DC1's Q2 outright: this is no longer "untested territory," it's the same class already confirmed working end-to-end by every drying/leather rack in the game.

**Tradeoff to accept:** `DryingCraftLogic.onUpdate()` (`zombie42_20_4/entity/components/crafting/DryingCraftLogic.java:56-86`) unconditionally applies its temperature/wetness pacing logic (see `claude_dryingAnalysis.md` §4) to *any* recipe it runs — there's no way to opt out of it short of overriding the component. For a milk churner this is arguably still thematically fine (churning is slower when it's freezing, and rain doesn't matter if the churner sits indoors — `isOutside()` gates the wetness accumulation entirely), but it does mean the "a few minutes per batch" timing is a **baseline at 20°C**, not a hard duration, exactly like the drying racks' own 24h/48h being baselines. This should be an explicit, accepted design choice, not a surprise discovered mid-implementation the way Phase 17's failure was.

## Proposed Entity Sketch

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
        component Resources
        {
            group churn_inputs
            {
                Fluid@Input@5,              -- 5 L capacity == exactly one batch; see "Fixed 5 L batching" below
            }
            group churn_outputs
            {
                Item@Output@20@StackAny,    -- accumulates multiple butter sticks, same shape as the drying racks' output groups
            }
        }
        component DryingCraftLogic
        {
            Recipes = AutoButterChurn,
            StartMode = Automatic,          -- vs. drying racks' Manual: player doesn't re-trigger each batch, matches original design intent
            inputGroup = churn_inputs,
            outputGroup = churn_outputs,
            actionAnim = <tbd, e.g. reuse the manual churn's crank/stir anim>,
        }
        component SpriteConfig
        {
            face S { layer { row = <washing-machine-like sprite row, per original design's visual concept> } }
        }
        component SpriteOverlayConfig
        {
            style Churning
            {
                progress 0   { face S { layer { row = <empty/idle> } } }
                progress 50  { face S { layer { row = <mid-churn, e.g. milk visibly present> } } }
                progress 100 { face S { layer { row = <butter-ready look> } } }
            }
        }
        component CraftBenchSounds
        {
            -- see original design doc §5 / Q7 — churn sound still unidentified
        }
    }
}
```

```
craftRecipe AutoButterChurn
{
    time = 300,                              -- "a few minutes"; see timing discussion below
    Tags = AutoButterChurn,
    category = Farming,
    overlayStyle = Churning,
    inputs
    {
        fluid 5.0 [CowMilk;SheepMilk] mode:mixture,
    }
    outputs
    {
        item 1 Base.Butter,
    }
}
```

### Fixed 5 L batching, no `variable[1:N]` needed

The grain/herb drying racks use `item variable[1:20] [...]` because their input slot holds up to 20 items and the recipe scales to consume however many are present in one go. Here, the input `Resources` fluid slot itself is capped at `Fluid@Input@5` — exactly one 5 L batch of capacity — so there is never more than 5 L available to consume at once. This makes the recipe a **fixed** `fluid 5.0 → item 1`, structurally identical to vanilla `churn_butter`'s own shape (`claude_automaticButterChurning.md` §1), rather than needing a variable range. Refilling happens by the player dragging another milk-holding container into the slot once it drains, same interaction as topping up a drying rack's item slot.

*(An alternative is a larger fluid capacity, e.g. 20 L like the original design's proposed `FluidContainer`, with the recipe fixed at `fluid 5.0` per batch and `StartMode = Automatic` re-triggering itself every time ≥5 L remains — mirroring the original design's "20 L tank → four 500 s batches" example. This trades "always exactly one batch in flight" for "top off less often, get a queue of batches automatically" — worth deciding as a preference, not a technical constraint, since `Resources` fluid entries support any capacity.)*

### Timing: "a few minutes"

Vanilla's own manual `churn_butter` recipe (traced in the earlier Butter Churn analysis) already runs at `time = 500` (≈8.3 minutes at the 20°C baseline) for the identical 5 L → 1 Butter conversion. That's a reasonable anchor point if "a few minutes" should stay close to the existing manual process's pace; `time = 300` (5 minutes) or lower is equally easy to set if the automatic version is meant to feel meaningfully faster than hand-churning, as a reward for the electrical-skill/conversion investment. This is a pure balance number with no engine constraint either way — recommend picking a value and adjusting after playtesting, same as DC1's own approach to other numeric unknowns.

## What This Resolves From DevCycle 1

| DevCycle 1 open item | Status after this investigation |
|---|---|
| Q1: Combined fluid + item container on one entity | **Answered differently than DC1 assumed.** Not "`FluidContainer` + item `container` on one `IsoObject`" (never confirmed) — instead "`Resources` fluid entry + `Resources` item entry on one entity," which is directly supported by `ResourceType.Fluid`/`ResourceFluid` and requires no combination of two different container systems at all. |
| Q2: Bare `CraftLogic` on a plain entity, untested | **Resolved by not using bare `CraftLogic`.** Use `DryingCraftLogic` instead — proven by 12 shipped recipes. |
| Phase 1 → Phase 17 UX conflict (pour UX vs. `CraftLogic` automation) | **Resolved by picking a side deliberately.** Adopt the drying rack's `ISEntityWindow` drag-fill UX and give up the trough-style one-click pour entirely — this was the actual source of DC1's unresolved failure, not a technical dead end. |
| Phase 17's "fluid filter must be inline `whitelist`" reversal | **Reverts back toward Phase 1's original instinct**, now on firmer footing: milk restriction lives in a named `fluidFilter` script object referenced by the `Resources` fluid entry's `filter`, exactly the pattern DC1 first assumed before Phase 17 dropped `Resources` for `component FluidContainer` (which needed the inline `whitelist` instead, because it's a structurally different component). |
| Q3: Fluid unit-to-liter mapping | Still open — unchanged by this investigation, still needs in-game verification (fill something, read displayed liters). |
| Q5: Non-milk fluid handling | Same answer as before (whitelist to Cow Milk + Sheep Milk), now implemented via the `fluidFilter` script object mechanism above instead of an inline block. |
| Q4: Output overflow behavior | Same shape of question, now answered by precedent: drying racks simply stop progressing when the output resource `isFull()` (`DryingCraftLogicSystem`/`CraftLogic`'s generic "wait for output room" handling) — no custom overflow Lua needed, unlike the DC1 Phase 17 "drop unconditionally on the ground" workaround. |

## Recommended Next Step

This document is research/design only, per this project's process (`AGENTS.md`: DevCycle document creation stops after the document; implementation needs an explicit go-ahead). If this direction is approved, the natural next step is a new DevCycle 2 plan that:

1. Prototypes the entity + recipe exactly as sketched above, in isolation, before wiring in the washing-machine-conversion flow from DC1 §4a (keep the two risks — "does a fluid `Resources` entry actually work" and "does the conversion timed-action still work" — separated, unlike DC1 which discovered its Phase 17 failure with both bundled together and no way to isolate which part broke).
2. Confirms in-game, with diagnostic logging kept in place until success is confirmed (per this project's standing practice — see `doc/planning/completed/DevCycle001.md` Phase 15's lesson): that dragging a milk-holding item onto the `churn_inputs` slot actually drains it, that the batch completes and produces `Base.Butter` in `churn_outputs`, and that `StartMode = Automatic` re-triggers on its own once more milk is available.
3. Only then re-attaches the washing-machine conversion flow, sound, and power gating from the original design.
