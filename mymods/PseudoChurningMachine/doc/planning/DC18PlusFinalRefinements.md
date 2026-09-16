# PseudoChurningMachine — DC18+ Final Refinements

**Created:** 2026-09-15
**Purpose:** The mod looks largely complete as of DevCycle 017 (see `doc/ideas/PseudoChurningMachineDC11Plus.md`, now closed). This document tracks the final refinements that in-game testing surfaces from here on — a numbered, analyzed breakdown in the same style as `PseudoChurningMachineDC11Plus.md`, for future DevCycles to implement out of order, referenced by number (`#1`, `#2`, etc.). Numbers are stable once assigned — don't renumber this list as items are completed or dropped; mark them done/dropped in place instead.

This is an analysis document, not a DevCycle plan — it doesn't commit to an implementation order or bundle items into cycles. Each numbered item below should get its own DevCycle (or be folded into one, if a future planning pass decides two items are cheaper to do together) when work on it actually begins, per `DevelopmentProcess.md`.

---

## 1. Exact requirements to convert a real washing machine into a Churning Machine

**Status:** Open, no design yet — needs a decision before its own DevCycle.

**The question, per Ed (2026-09-15):** what should it actually cost, in full, to convert a real washing machine into a Churning Machine — skill level(s), tools the player keeps (checked but not consumed), and consumables the player does not keep (materials actually spent)? Ed's framing: a washing machine already structurally matches most of what a butter churner needs (a sealed drum capable of agitation), so whatever consumables are required should be minimal — and this should be weighed against how simplified vanilla's own Butter Churn already is.

**Current baseline (DevCycle 016, still in effect, not yet revisited):** `ChurningMachineCode.lua`'s `canConvertWasher()` requires:
- A screwdriver — checked via `playerInv:containsTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)` (any non-broken item tagged `SCREWDRIVER`, not one specific item type), **not consumed** — a tool requirement only.
- `Perks.Electricity` level 6 — the "Electrician"-flavored skill (internal name `Electricity`), matching the real washer/dryer's own perk namespace (per `PseudoChurningMachineDC11Plus.md` #8's original research).
- **No consumable materials at all** — zero items are spent on conversion today. This was carried over from idea #8's original design discussion without being revisited since.

**Relevant vanilla precedent, per Ed's "simplified" framing — the vanilla Butter Churn's own build recipe** (`media42_20_4/scripts/generated/entities/animals/workstations/entity_butter_churn.txt`):
```
component CraftRecipe
{
    timedAction = BuildWoodenStructureMedium,
    time = 50,
    category = Farming,
    Tooltip = Tooltip_craft_churnBucketDesc,
    xpAward = Woodwork:10,
    inputs
    {
        item 1 tags[base:hammer] mode:keep flags[Prop1;MayDegradeVeryLight],
        item 2 [Base.Plank],
        item 2 [Base.Nails],
    }
}
```
Vanilla's own equivalent workstation costs one kept tool (a hammer, with a small chance to degrade — `MayDegradeVeryLight`) plus a genuinely small amount of consumed material (2 planks, 2 nails) — not nothing, but not much either. No perk/skill requirement is attached to this recipe at all. This is the concrete "how simplified is vanilla's own version" data point Ed's comment references.

**Open sub-questions this item needs to resolve, not yet decided:**
- **Skill level:** is Electricity 6 still the right level for washer→churn conversion specifically, now considered on its own merits rather than as leftover framing from idea #8's original "Electrician-gated" concept? A washing machine conversion may not need to be electrical-skill-gated at all, depending on what the conversion is actually understood to represent (rewiring vs. simple mechanical repurposing).
- **Tools kept:** is a screwdriver the right (or only) tool? Vanilla's own analogous build recipe above uses a hammer with `mode:keep` and a small degrade chance (`MayDegradeVeryLight`) rather than a zero-risk check — worth deciding whether the Churning Machine conversion should carry a similar small degrade risk on its kept tool(s), or remain a pure check with no wear, as it is today.
- **Consumables spent:** should conversion consume anything at all? Today it consumes nothing. Given Ed's "minimal, not zero" framing and the vanilla precedent above (a small amount of cheap material, not a free action), this item should land on a specific small consumable list (e.g., a couple of common, cheap items) rather than staying at zero by default.
- **What in-game testing needs to surface before this is decided:** whether the current zero-tool-degrade, zero-consumable, Electricity-6 baseline feels right in actual play, or whether it's too easy/too hard relative to the value of a free 50L Churning Machine from an existing washer.

**Not yet started:** no implementation, no in-game testing pass specific to this question yet. This item exists to hold the question and the vanilla-precedent research above until a future DevCycle picks it up.

## 2. Remove the ability to build a Churning Machine from scratch, once testing is complete

**Status:** Open, blocked on Ed's own "testing is complete" call — no implementation until then.

**The change, per Ed (2026-09-15):** once testing wraps up, remove the build-menu path entirely — the Churning Machine should no longer be craftable from raw materials, only obtainable via conversion (currently: converting a real White Washing Machine, per DevCycle 016/idea #8; see also item #3 below for the Blue Combo Washer/Dryer variant).

**What this actually touches:** `entity_ChurningMachine.txt`'s `component CraftRecipe` block —
```
component CraftRecipe
{
    timedAction = BuildWoodenStructureMedium,
    time = 50,
    category = Farming,
    Tooltip = Tooltip_craft_churningMachineDesc,
    inputs
    {
        item 1 [Base.Plank],
        item 1 [Base.Nails],
    }
}
```
This is the placeholder recipe (1 plank + 1 nail) that `PseudoChurningMachineDC11Plus.md` #4 explicitly said to keep for testing purposes, and #9 ("Build UI shows the old manual Butter Churner, not the Churning Machine") was deferred for the same reason — both of those notes are the reason this recipe (and the build-menu entry it produces) still exists today. This item is the other half of that deferral: removing the `CraftRecipe` component once Ed says testing is done.

**Open questions, not yet decided:**
- Does removing `CraftRecipe` entirely still leave `GameEntityFactory.CreateIsoObjectEntity` able to attach the entity's other components correctly when placed via the conversion action (`ISConvertWasherToChurningMachine.lua`, DevCycle 016)? That path doesn't go through the crafting/build-menu system at all (it builds an `IsoThumpable` directly and attaches components via the entity script), so removing `CraftRecipe` is expected not to affect it — worth a quick confirmation in-game once this is picked up, not assumed.
- Whether removing `CraftRecipe` also resolves idea #9 (old Butter Churner showing in the build UI) as a side effect, since the Churning Machine's own build-menu entry would no longer exist to be confused with it — or whether #9 was actually about something else entirely (it was never investigated, per its own deferred note).

**Blocked on:** Ed's explicit sign-off that testing is complete — not a technical blocker, a sequencing one. Do not implement this until Ed says so.

## 3. Convert a real Blue Combo Washer/Dryer into a Churning Machine (25L capacity)

**Status:** Open, no design yet — a variant of DevCycle 016's existing conversion feature, not a new mechanism.

**The request, per Ed (2026-09-15):** extend conversion to also accept a real Blue Combo Washer/Dryer (`IsoCombinationWasherDryer`), not just the plain White Washing Machine (`IsoClothingWasher`) DevCycle 016 currently supports — but the resulting Churning Machine should be capped at **25L capacity**, not the 50L a converted White Washing Machine produces today.

**What DevCycle 016 already built, directly reusable:** `ChurningMachineCode.lua`'s `onFillWorldObjectContextMenu` currently gates on `instanceof(object, "IsoClothingWasher")` only (`PseudoChurningMachineDC11Plus.md` #8's DC016 scope note: "plain washer only... not the combo unit or a standalone dryer — a natural follow-on, not implemented here"). This item is that natural follow-on. The conversion mechanism itself (`ISConvertWasherToChurningMachine.lua`: `transmitRemoveItemFromSquare` + `GameEntityFactory.CreateIsoObjectEntity` + `AddSpecialObject`, per DevCycle 016 Phase 1-2) is generic to "replace a real object with our scripted entity" and isn't specific to which washer type triggered it.

**Open design questions, not yet decided:**
- **A second entity, or a capacity flag on the same entity?** Since a converted White Washing Machine needs 50L and a converted Combo Washer/Dryer needs 25L, either (a) a second entity script (e.g. `ChurningMachineCombo`) with its own `Capacity = 25.0`, reusing `ChurningMachineCode.turnOnOffMenu` exactly as idea #7's analysis already found straightforward for a hypothetical top-loading variant, or (b) some way of parameterizing capacity on the single existing entity at placement time. (a) is more consistent with how the mod already handles entity variation (per #7's own analysis) and is the likely simpler path, but hasn't been decided.
- **Tile/sprite for the combo-derived machine:** should it keep the same White Washing Machine sprite rows (`appliances_laundry_01_4..7`) regardless of which real object it was converted from, or should a combo-derived Churning Machine look different (e.g. reusing `appliances_laundry_01_0`, the Blue Combo Washer/Dryer tile `PseudoChurningMachineDC11Plus.md` #2 notes was the entity's own original sprite before DevCycle 015 moved to the white washer tiles)? Not yet decided — needs Ed's input on whether visual distinction matters here.
- **Same conversion requirements as the White Washing Machine, or different?** Item #1 above is still deciding the White Washing Machine's own conversion cost (skill, tools, consumables); this item should presumably reuse whatever #1 lands on rather than inventing a second, separate cost — but that's not yet explicit, and the two items should be resolved together or #1 resolved first.
- **Does idea #2's reclassification hypothesis (now accepted/won't-fix, plumbed-only Wash Menu quirk) also apply to a combo-derived conversion?** Likely yes, same as the plain washer case, since it's the same underlying mechanism — not expected to be a new problem, just worth noting it isn't scoped out by this item.

**Not yet started:** no implementation. This item is a follow-on to DevCycle 016's own explicitly-scoped-out combo/dryer case, now picked up with a specific capacity requirement (25L) from Ed.

## 4. Make a poster for the mod

**Status:** Open, no design yet.

**The request, per Ed (2026-09-16):** produce real cover art (`poster.png`) for `PseudoChurningMachine/42/mod.info`'s `poster=` field, replacing the placeholder blank/generic image carried over from `PseudoTemplate` (see `README.md`'s "Using This Template" step 2).

**Open questions, not yet decided:**
- What the poster should actually depict — likely the converted washing machine in its Churning Machine form (mod's core visual identity), but not yet decided whether it should show the entity in-world, an isolated icon-style render, or something illustrative (e.g. a butter-churning motif) instead.
- Production method — this is image-asset work, not code; needs a decision on how the art itself gets produced (in-engine screenshot/render vs. external image tool) before a DevCycle can scope it.

**Not yet started:** no design, no asset. This item only exists to hold the request until a future DevCycle picks it up.

## 5. Script an investor-pitch advertisement video for the mod

**Status:** Open, no design yet.

**The request, per Ed (2026-09-16):** write a script for a promotional video advertising the mod, framed in-character — the speaker is an inventor pitching investors on his new invention: a butter churning machine he built by converting an inexpensive used washing machine he found at the garbage dump. The tone is an investor pitch (enthusiasm, a founder's sales pitch for the "invention"), not a straightforward feature-list trailer.

**Open questions, not yet decided:**
- Target length/format — not yet specified (e.g. a short 30-60s pitch vs. a longer infomercial-style script).
- Whether the script should call out specific mod mechanics by name (sheep/cow milk only, 10-minute churn time, contaminated-milk failure) as "product features" within the pitch framing, or stay purely in-character without breaking down mechanics explicitly.
- Whether this is a script only (text deliverable) or is expected to lead into an actual recorded/produced video — not yet decided; affects whether this item needs its own DevCycle at all or is a documentation-only task.

**Not yet started:** no script written. This item only exists to hold the request until a future DevCycle (or a direct documentation pass) picks it up.

---

## Summary Table

| # | Idea | Status | Key dependency / cross-reference |
|---|---|---|---|
| 1 | Exact washer→Churning Machine conversion requirements | Open, no design yet | Baseline is DC016's screwdriver + Electricity 6, zero consumables; vanilla Butter Churn's own build recipe is the "minimal but not free" precedent |
| 2 | Remove build-from-scratch once testing is complete | Open, blocked on Ed's "testing complete" call | Removes `entity_ChurningMachine.txt`'s `CraftRecipe`; relates to DC11Plus #4/#9's original "keep for testing" deferrals |
| 3 | Convert Blue Combo Washer/Dryer, 25L capacity | Open, no design yet | Follow-on to DC016's plain-washer-only conversion scope; likely shares #1's conversion-cost decision |
| 4 | Make a poster for the mod | Open, no design yet | Replaces placeholder `poster.png` inherited from `PseudoTemplate` |
| 5 | Script an investor-pitch advertisement video | Open, no design yet | In-character inventor pitch; garbage-dump-washer-to-churner origin story framing |
