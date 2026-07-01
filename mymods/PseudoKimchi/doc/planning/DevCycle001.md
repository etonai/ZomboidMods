# DevCycle 001: Kentucky Kimchi Initial Implementation

**Status:** Planning
**Start Date:** 2026-07-01
**Target Completion:** TBD
**Focus:** Build the first playable B42 version of PseudonymousEd's Kentucky Kimchi.

---

## Goal

Create the initial implementation of the PseudoKimchi mod for Project Zomboid B42. The mod should add a Kentucky-style kimchi recipe using available game ingredients and produce a balanced preserved food item that matches the design notes in `doc/ideas/kimchi_recipe.md`.

This cycle is intentionally limited to the first working version. Future work, such as optional ginger support, should be deferred until the core item and recipe are working cleanly.

## Desired Outcome

PseudoKimchi loads in B42 without script errors. Players can craft Kentucky kimchi from cabbage, salt, water, garlic, dried jalapeno, and cooked little bait fish, producing a food item with the intended nutrition, thirst, happiness, and spoilage behavior.

---

## Tasks

### Phase 1: Script Structure and References

**Status:** Planning

- [ ] Inspect existing B42 food item and recipe script patterns in `media/scripts/generated/`.
- [ ] Use `mymods/PseudoSaltRecipes/` as the reference mod for naming, folder structure, script organization, and B42 conventions.
- [ ] Decide exact item module/name and recipe name for Kentucky kimchi.

**Technical Notes:**
Use vanilla B42 scripts as the source of truth for syntax. Use `mymods/PseudoSaltRecipes/` as the project-specific reference for local mod structure and conventions when those patterns match B42 generated script conventions.

### Phase 2: Kentucky Kimchi Item

**Status:** Planning

- [ ] Add the Kentucky kimchi food item script under the mod's `42/media/scripts/` tree.
- [ ] Set food values based on the design note: nutrition comparable to one cabbage, `thirstChange = 0`, happiness benefit, `DaysFresh = 21`, and `DaysTotallyRotten = 730` if supported by B42 item syntax.
- [ ] Investigate whether stale-stage happiness can increase to 20; if unsupported or risky, set the initial happiness value to 20 per the design note.

**Technical Notes:**
The design intent is "same nutritional value as 1 cabbage" rather than a stronger late-game food. Verify the actual B42 cabbage item values before assigning stats.

### Phase 3: Crafting Recipe

**Status:** Planning

- [ ] Add a B42-compatible recipe using cabbage, salt, water, garlic, dried jalapeno, and cooked little bait fish.
- [ ] Confirm ingredient identifiers and quantities against B42 scripts.
- [ ] Ensure the water input uses valid B42 fluid/container syntax.
- [ ] Decide whether the recipe should require a container, work surface, tool, or preservation-related category.

**Technical Notes:**
Initial target recipe from `doc/ideas/kimchi_recipe.md`: cabbage 24 units, salt 5 units, water 1 liter, garlic 1 unit, dried jalapeno 1 unit, cooked little bait fish 1 unit.

### Phase 4: Mod Metadata and Player-Facing Text

**Status:** Planning

- [ ] Review `mod.info` for B42 compatibility fields such as `versionMin=42.0`.
- [ ] Add or update display names and recipe text where required.
- [ ] Preserve the existing mod description tone unless a B42 packaging requirement needs a change.

**Technical Notes:**
The current mod metadata already identifies the mod as `PseudoKimchi`. Keep that id stable unless a load conflict is discovered.

### Phase 5: Verification

**Status:** Planning

- [ ] Review all new script files for B42 syntax issues.
- [ ] Compare recipe and item syntax against known working mods in `mymods/`.
- [ ] Record any assumptions or unresolved behavior in this DevCycle document before moving the cycle to Work Complete.

**Technical Notes:**
In-game verification may require user involvement. Do not mark this phase or cycle as `Verified` without explicit user approval.

---

## Open Questions

1. **Can B42 food items increase happiness only after becoming stale?**
   Recommendation: Check B42 item fields and vanilla examples first. If there is no clear support, use the fallback from the design note and set the kimchi's happiness benefit to 20 from the start.
ED: Please check this

2. **Which exact B42 item should represent dried jalapeno?**
   Recommendation: Search the B42 generated scripts for jalapeno and dried pepper variants before implementing the recipe. If no exact dried jalapeno exists, pause and choose the closest available ingredient with user approval.
ED: Dried Jalapeno is already in vanilla project zomboid

3. **Should the first version include optional ginger?**
   Recommendation: No. The design note explicitly defers optional ginger investigation to version 2.
ED: NO
---

## Notes and Risks

- This cycle should not begin implementation until Ed reviews and approves the plan.
- The mod's local `doc/planning/DevCycleTemplate.md` is currently empty, so this document follows the root `DevCycles/DevCycleTemplate.md` structure.
- `mymods/PseudoKimchi/AGENTS.md` prohibits implementation after DevCycle document creation until the user explicitly requests it.
- The phrase "same nutritional value as 1 cabbage" needs code verification against the B42 cabbage item before final values are assigned.
- Ingredient names may differ from intuitive labels; all item identifiers must be verified against B42 scripts.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**

**Metrics:**
- Files modified:

**Lessons / Notes:**
