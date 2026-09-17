# DevCycle 018: Washer-to-Churning-Machine Conversion Recipe Change

**Status:** Verified
**Start Date:** 2026-09-17
**Target Completion:** 2026-09-17

---

## Goal

Resolve `DC18PlusFinalRefinements.md` #1 (exact washer→Churning Machine conversion requirements) per Ed's decision (2026-09-17): change the real-washer-to-Churning-Machine conversion recipe to require:

1. `Perks.Electricity` level 3 (down from the current level 6 baseline — see Skill Mapping Note below).
2. A screwdriver, **kept** (checked, not consumed) — unchanged from the current baseline.
3. 1 `Base.ElectronicsScrap` ("Scrap Electronics"), **consumed** — new; the current baseline consumes nothing.

## Skill Mapping Note

Ed's request named the skill "electronics." Vanilla Project Zomboid has no perk by that name — the only matching skill is `Perks.Electricity` (`PerkFactory.java:354`), displayed in-game as "Electrical" (`IGUI_perks_Electricity`) under the "Electrician" magazine line. This is the same skill DC016 already gates conversion on (currently level 6), so this DevCycle is understood as lowering that existing gate's required level from 6 to 3, not adding a second skill requirement. Flagged here as an assumption inherited from the ambiguous request, not an explicit confirmation from Ed — worth a quick sanity check if anything about the in-game skill name looks off during implementation.

## Item Mapping Note

Ed's request named "1 electrical component." Vanilla has no item literally named that; asked Ed directly and confirmed `Base.ElectronicsScrap` ("Scrap Electronics") over the other plausible candidate (`Base.ElectricWire`, "Electrical Wire").

## Desired Outcome

- **Visibility gate (new, per Ed 2026-09-17):** the "Convert to Churning Machine" option should not appear in the menu at all — not even greyed out — for a player below `Perks.Electricity` level 3. This is a change from the current behavior (see Menu Visibility Change Note below), which always shows the option and greys it out when requirements aren't met.
- **Availability gate (unchanged pattern, greyed out with tooltip):** for a player who does meet the level-3 skill threshold, the option is shown but greyed out (`notAvailable = true`, existing tooltip pattern) unless they also have:
  - A non-broken screwdriver (`inventory:containsTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)`), unchanged — kept, not consumed.
  - At least 1 `Base.ElectronicsScrap` in inventory — new requirement, consumed on conversion.
- The conversion action (`ISConvertWasherToChurningMachine.lua`) removes 1 `Base.ElectronicsScrap` from the player's inventory as part of performing the conversion, alongside its existing removal of the real washer object.
- Any tooltip shown when the conversion option is greyed out (screwdriver and/or Scrap Electronics missing) reflects the new item requirement accurately. No tooltip is needed for the skill gate, since not meeting it now hides the option entirely instead of greying it out.
- This applies to the White Washing Machine conversion path only — `DC18PlusFinalRefinements.md` #3 (Blue Combo Washer/Dryer conversion) is out of scope for this DevCycle and was already noted to likely reuse whatever #1 lands on.

## Menu Visibility Change Note

Ed's direction (2026-09-17): below Electricity level 3, the option should not be visible at all, not just greyed out. This is a behavior change from the current code (`ChurningMachineCode.lua:211-228`), where `onFillWorldObjectContextMenu` always adds the option for any real White Washing Machine and only sets `option.notAvailable = true` when `canConvertWasher()` fails — the option itself is never omitted today. Implementation will need to split `canConvertWasher()`'s single combined check into two: a skill-level check gating whether the option is added to the menu at all, and a separate screwdriver/item check gating `notAvailable` on the option once it is shown.

---

## Tasks

### Phase 1: Update conversion requirements

**Status:** Verified (Ed, 2026-09-17)

- [x] Change `REQUIRED_ELECTRICITY_LEVEL` (or equivalent constant) in `ChurningMachineCode.lua` from 6 to 3.
- [x] Split `canConvertWasher()` into two separate checks: a skill-level check (`hasConversionSkill`, `playerObj:getPerkLevel(Perks.Electricity) >= 3`) used to decide whether the option is added to the menu at all, and a tool/item check (`canConvertWasher`, screwdriver + `Base.ElectronicsScrap` via `containsTypeRecurse`) used to decide `notAvailable`/tooltip on the option once it's shown.
- [x] Update `onFillWorldObjectContextMenu` so the option is only added (`context:addGetUpOption(...)`) when the skill-level check passes; below level 3, skip adding the option entirely (no tooltip needed, since there's no visible option to attach one to).
- [x] Update the option's greyed-out/tooltip logic to reflect only the tool/item check (screwdriver, Scrap Electronics) once the option is shown.
- [x] Update `ISConvertWasherToChurningMachine.lua`'s `complete()` to remove 1 `Base.ElectronicsScrap` from the player's inventory (`self.character:getInventory():RemoveOneOf(...)`) when conversion completes, alongside the existing real-washer removal.
- [x] Updated `Tooltip_ChurningMachine_RequiresConversion` text to reflect the new item requirement instead of the old skill-level wording.
- [x] Run `utilities\CopyModToZomboid.bat PseudoChurningMachine` to copy the mod into place before testing.
- [x] In-game verification: option does not appear at all below Electricity level 3; at level 3+, option appears but greys out (with tooltip) if missing a screwdriver or Scrap Electronics; becomes clickable once all three are met; performing the conversion consumes exactly 1 Scrap Electronics and does not consume the screwdriver. **Confirmed by Ed (2026-09-17).**

---

## Notes and Risks

- Per `AGENTS.md`, no implementation begins until Ed explicitly requests it — this document defines the plan only.
- `DC18PlusFinalRefinements.md` #1 should be updated to point at this DevCycle once work begins, per that document's own convention of marking items done/dropped in place rather than renumbering.
- `DC18PlusFinalRefinements.md` #1's own open sub-questions (tool degrade risk on the screwdriver, whether Electricity should gate this at all) are **not** addressed by this DevCycle — Ed's 2026-09-17 direction is a specific, final recipe decision that supersedes those open sub-questions for the White Washing Machine path, not a resolution of the broader analysis discussion.

---

## Completion Summary

**Completion Date:** 2026-09-17

**Phases Completed:** Phase 1 (the DevCycle's only phase) — recipe change implemented and verified in-game by Ed.

**Accomplishments:**
- Converting a real White Washing Machine into a Churning Machine now requires `Perks.Electricity` level 3 (down from 6), a kept (non-consumed) screwdriver, and 1 consumed `Base.ElectronicsScrap`.
- Below Electricity level 3, the "Convert to Churning Machine" option no longer appears in the menu at all — a real behavior change from the prior always-visible/greyed-out pattern, per Ed's explicit direction. At level 3+, the option is shown and greys out (with tooltip) only for the tool/item requirements.
- Resolves `DC18PlusFinalRefinements.md` #1 for the White Washing Machine path.

**Work Deferred:** None for this DevCycle's own scope. `DC18PlusFinalRefinements.md` #1's broader open sub-questions (screwdriver degrade risk) were not revisited — Ed's 2026-09-17 direction was a specific final recipe decision, not a resolution of that wider discussion. `DC18PlusFinalRefinements.md` #3 (Blue Combo Washer/Dryer conversion) remains open and out of scope, as noted at the start of this cycle.

**Metrics:** 1 phase, 3 files modified (`ChurningMachineCode.lua`, `ISConvertWasherToChurningMachine.lua`, `Tooltip.json`).
