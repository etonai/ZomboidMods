# DevCycle 003: Kentucky Kimchi Jar Model Fix

**Status:** Verified
**Start Date:** 2026-07-01
**Target Completion:** 2026-07-01
**Focus:** Replace the non-working `JarWhite` static/world model on glass jar kimchi with the sealed vanilla preserved-food jar model.

---

## Goal

Fix the glass jar Kentucky kimchi item model. The previous `Pseudonymous.KentuckyKimchi` item used:

```txt
Icon = JarWhite,
StaticModel = JarWhite,
WorldStaticModel = JarWhite,
```

`JarWhite` appears to be a valid icon name, but it is not working as a static/world model for the item. The fix uses the sealed model pattern vanilla B42 uses for jars of preserved food instead of treating the icon name as a model name.

## Desired Outcome

The glass jar Kentucky kimchi item renders as a sealed jar of preserved food. The chosen model is based on vanilla preserved-food jar items and fits a cabbage-based fermented food.

---

## Current PseudoKimchi Item

Target file:

- `mymods/PseudoKimchi/PseudoKimchi/42/media/scripts/items/PseudoKimchiItems.txt`

Implemented glass jar item model fields:

```txt
item KentuckyKimchi
{
    DisplayName = Jar of Kentucky Kimchi,
    Icon = JarGreen,
    ReplaceOnUse = Base.EmptyJar,
    WorldStaticModel = JarFoodCabbage_Ground,
}
```

Clay jar items were left unchanged because they already use known jar model names:

- `KentuckyKimchiClayJar`: `StaticModel = ClayJar`, `WorldStaticModel = ClayJar`
- `KentuckyKimchiGlazedJar`: `StaticModel = GlazedClayJar`, `WorldStaticModel = GlazedClayJar`

---

## Vanilla Evidence

Relevant B42 generated item examples from `media/scripts/generated/items/food.txt`:

### Sealed preserved cabbage jar

```txt
item CannedCabbage
{
    Icon = JarGreen,
    WorldStaticModel = JarFoodCabbage_Ground,
    CantEat = true,
    Tags = base:hasmetal;base:hidehungerchange;base:spawncooked;base:preservedfood,
}
```

### Other sealed preserved vegetable jars

Vanilla sealed preserved vegetables use ingredient-specific `WorldStaticModel` values such as:

- `JarFoodBellPeppers_Ground`
- `JarFoodBroccoli_Ground`
- `JarFoodCabbage_Ground`
- `JarFoodCarrots_Ground`
- `JarFoodRadish_Ground`
- `JarFoodTomatoes_Ground`

The cabbage model is the closest match for Kentucky kimchi because the recipe is cabbage-based.

### Rejected open-jar pattern

Vanilla open preserved cabbage uses:

```txt
StaticModel = JarFoodGreen_Open,
WorldStaticModel = JarFoodGreen_Open,
```

Ed explicitly rejected the open jar model for this fix. No `JarFood*_Open` model was added.

Local mod reference from `PseudoSaltRecipes`:

- Sauerkraut glass jar items also use `Icon = JarWhite` and `StaticModel = JarWhite`.
- That appears to be the inherited pattern that caused the current issue; vanilla B42 sealed preserved-food models were used as the stronger source of truth for this fix.

---

## Implemented Fix

Implemented for `Pseudonymous.KentuckyKimchi`:

```txt
Icon = JarGreen,
WorldStaticModel = JarFoodCabbage_Ground,
```

Removed the invalid glass-jar line:

```txt
StaticModel = JarWhite,
```

Implementation rationale:

- Kimchi is cabbage-based and should look like a sealed jar of preserved food.
- Vanilla sealed preserved cabbage uses `WorldStaticModel = JarFoodCabbage_Ground`.
- `JarGreen` is the vanilla icon for preserved cabbage and better matches cabbage/kimchi than `JarWhite`.
- Open jar models were explicitly out of scope for this fix.
- Vanilla sealed preserved vegetable items generally rely on `WorldStaticModel`; this implementation does not force an unverified `StaticModel` fallback.

---

## Tasks

### Phase 1: Confirm Vanilla Sealed-Jar Model Pattern

**Status:** Verified

- [x] Re-check vanilla B42 sealed preserved vegetable items for `CannedCabbage` and nearby jarred vegetables.
- [x] Confirm whether sealed preserved foods omit `StaticModel` and rely on `WorldStaticModel`.
- [x] Confirm whether `JarWhite` appears only as an icon or also as a valid static/world model anywhere in vanilla.
- [x] Decide whether glass jar kimchi should omit `StaticModel` or set `StaticModel = JarFoodCabbage_Ground` as a fallback.
- [x] Do not select any `JarFood*_Open` model.

**Implementation Notes:**
Selected the vanilla sealed preserved cabbage pattern: `Icon = JarGreen` and `WorldStaticModel = JarFoodCabbage_Ground`. Omitted `StaticModel` for the glass jar item rather than forcing an unverified fallback.

### Phase 2: Update PseudoKimchi Item Script

**Status:** Verified

- [x] Update only the glass jar `KentuckyKimchi` item unless evidence shows the clay/glazed variants are also wrong.
- [x] Remove or replace `StaticModel = JarWhite` with the approved sealed-jar approach.
- [x] Replace `WorldStaticModel = JarWhite` with `WorldStaticModel = JarFoodCabbage_Ground`.
- [x] Consider changing `Icon = JarWhite` to `Icon = JarGreen` if Ed approves matching vanilla cabbage/preserved vegetable visuals.
- [x] Preserve nutrition, spoilage, recipe, and jar-return behavior unless a model-field dependency requires otherwise.

**Implementation Notes:**
Updated both the workspace source file and the installed mod copy used by Project Zomboid:

- `mymods/PseudoKimchi/PseudoKimchi/42/media/scripts/items/PseudoKimchiItems.txt`
- `C:/Users/edwar/Zomboid/mods/PseudoKimchi/42/media/scripts/items/PseudoKimchiItems.txt`

### Phase 3: Verification

**Status:** Verified

- [x] Read back `PseudoKimchiItems.txt` and confirm only intended model/icon fields changed.
- [x] Check script brace balance.
- [x] Search the file for remaining `JarWhite` references and decide whether any are intentional.
- [x] Confirm no `JarFood*_Open` model was introduced.
- [x] Launch or ask Ed to launch with PseudoKimchi enabled and verify the item renders correctly as a sealed preserved-food jar.
- [x] Mark the cycle `Verified` after Ed explicitly approves that status.

**Verification Notes:**
Local script read-back completed. Brace count was balanced: 4 opening braces and 4 closing braces. `JarWhite` no longer appears in the PseudoKimchi item script. No `JarFood*_Open` model appears in the PseudoKimchi item script. After the first relaunch attempt, `docs/console.txt` reported `MakeKentuckyKimchi item not found: Pseudonymous.KentuckyKimchi` and marked all three PseudoKimchi items as removed. Byte-level inspection found the item script had been written with a UTF-8 BOM (`EF BB BF`) while the recipe script was clean. Rewrote the workspace and installed item script as UTF-8 without BOM; both now start with `6D 6F 64 75` (`modu`) and the installed mod copy matches the workspace source copy. Ed confirmed the latest load/render check looks good, so DC3 is marked Verified.

---

## Notes and Risks

- Ed explicitly rejected the open jar model; the implemented model is the sealed cabbage preserved-food model `JarFoodCabbage_Ground`.
- If in-game testing shows the sealed cabbage model also needs `StaticModel = JarFoodCabbage_Ground` for a specific render path, add that as a follow-up adjustment rather than using an open model.
- `PseudoSaltRecipes` sauerkraut may have the same inherited `JarWhite` model issue, but this cycle is scoped to PseudoKimchi unless Ed expands it.
- Ed explicitly approved marking this cycle `Verified`.

---

## Completion Summary

**Completion Date:** 2026-07-01
**Status:** Verified
**Files modified:**

- `mymods/PseudoKimchi/PseudoKimchi/42/media/scripts/items/PseudoKimchiItems.txt`
- `mymods/PseudoKimchi/doc/planning/DevCycle003.md`
- `C:/Users/edwar/Zomboid/mods/PseudoKimchi/42/media/scripts/items/PseudoKimchiItems.txt`

**Work Deferred:**

- Possible follow-up to add `StaticModel = JarFoodCabbage_Ground` only if the sealed world model is not enough for the relevant render path.

