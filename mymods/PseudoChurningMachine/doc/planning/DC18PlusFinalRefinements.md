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

---

## Summary Table

| # | Idea | Status | Key dependency / cross-reference |
|---|---|---|---|
| 1 | Exact washer→Churning Machine conversion requirements | Open, no design yet | Baseline is DC016's screwdriver + Electricity 6, zero consumables; vanilla Butter Churn's own build recipe is the "minimal but not free" precedent |
