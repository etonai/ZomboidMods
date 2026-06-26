# DevCycle 001: Raw Tortillas and Soft Tacos

**Status:** Work Complete
**Start Date:** 2026-06-26
**Target Completion:** TBD
**Focus:** Add craftable raw tortillas, cook them into vanilla tortillas, and enable soft tacos built from tortillas.

---

## Goal

Create the first gameplay slice for `PseudoTortillas`: players can mix basic ingredients into raw tortillas, cook those raw tortillas into vanilla `Base.Tortilla` items, and use tortillas as the base for soft tacos. This cycle should stay close to B42 script patterns already confirmed in `PseudoSaltRecipes` and vanilla Project Zomboid food/evolved-recipe definitions.

## Desired Outcome

The mod loads in Project Zomboid B42 with no script parse errors. A player can craft `Pseudonymous.RawTortilla` from flour, salt, water, and butter; cook it as quickly as an egg; receive vanilla `Base.Tortilla` when cooked; and make a soft taco by adding taco-compatible ingredients to a tortilla.

---

## Tasks

### Phase 1: Add Script File Structure

**Status:** Work Complete

- [x] Create `PseudoTortillas/42/media/scripts/items/PseudoTortillasItems.txt`.
- [x] Create `PseudoTortillas/42/media/scripts/recipes/PseudoTortillasRecipes.txt`.
- [x] Create `PseudoTortillas/42/media/scripts/evolvedrecipes/PseudoTortillasEvolvedRecipes.txt` if B42 accepts modded evolved recipes from that path; otherwise use the closest vanilla-compatible scripts location after verification.
- [x] Use `module Pseudonymous` for mod-owned items and recipes, matching the existing `PseudoSaltRecipes` examples.

**Technical Notes:**
`PseudoSaltRecipes` uses `module Pseudonymous` for mod items and recipes in `42/media/scripts/items/PseudoSaltItems.txt` and `42/media/scripts/recipes/PseudoSaltRecipes.txt`. Follow that structure for `RawTortilla` so references use `Pseudonymous.RawTortilla`.

Implementation note: `zombie42_11/scripting/ScriptManager.java` recursively loads `.txt` files under each mod's `media/scripts` directory, so the `items/`, `recipes/`, and `evolvedrecipes/` subdirectories are valid script locations. The soft taco evolved recipe is placed in `module Base`, matching vanilla `media/scripts/generated/evolvedrecipes.txt`.

### Phase 2: Create Raw Tortilla Item

**Status:** Work Complete

- [x] Add item `RawTortilla` with display name `Raw Tortilla`.
- [x] Set `Type = Food` and `ItemType = base:food`, following B42 food item requirements used by `PseudoSaltRecipes`.
- [x] Use vanilla tortilla visuals where possible: `Icon = Tortilla`, `StaticModel = Tortilla_Ground`, `WorldStaticModel = Tortilla_Ground`.
- [x] Make it uncooked/dangerous and cookable: `DangerousUncooked = true`, `IsCookable = true`.
- [x] Cook at egg speed: `MinutesToCook = 4`, `MinutesToBurn = 20`.
- [x] Convert cooked raw tortillas into vanilla tortillas with `ReplaceOnCooked = Base.Tortilla`.
- [x] Add reasonable food stats and spoilage, using vanilla `Base.Tortilla` as the baseline unless testing shows better balance is needed.

**Technical Notes:**
Vanilla `Base.Tortilla` is defined in `media/scripts/generated/items/food.txt:10812` with `ItemType = base:food`, `Weight = 0.1`, `Icon = Tortilla`, `DaysFresh = 3`, `DaysTotallyRotten = 5`, `HungerChange = -5.0`, and `StaticModel = Tortilla_Ground`. Vanilla `Base.Egg` is defined at `media/scripts/generated/items/food.txt:5416` with `IsCookable = true`, `MinutesToCook = 4`, and `MinutesToBurn = 20`; copy those cooking timings for raw tortillas.

Implemented in `PseudoTortillas/42/media/scripts/items/PseudoTortillasItems.txt`.

Recommended item behavior:

```txt
item RawTortilla
{
    DisplayCategory = Food,
    Type = Food,
    ItemType = base:food,
    Weight = 0.1,
    Icon = Tortilla,
    DangerousUncooked = true,
    IsCookable = true,
    MinutesToCook = 4,
    MinutesToBurn = 20,
    ReplaceOnCooked = Base.Tortilla,
    DaysFresh = 3,
    DaysTotallyRotten = 5,
    HungerChange = -5.0,
    Calories = 40.0,
    Carbohydrates = 0.0,
    Lipids = 2.0,
    Proteins = 2.0,
    StaticModel = Tortilla_Ground,
    WorldStaticModel = Tortilla_Ground,
    CookingSound = FryingFood,
}
```

### Phase 3: Add Raw Tortilla Recipe

**Status:** Work Complete

- [x] Add a `craftRecipe MakeRawTortillas` recipe.
- [x] Require 60 units of flour, `Base.Salt` for salt, 24 `Base.Butter`, and `0.25` liters of water.
- [x] Use the B42 fluid input pattern from vanilla recipes and `PseudoSaltRecipes`: a kept wildcard fluid container plus a nested `-fluid` line.
- [x] Set the category to `Cooking`, add `Tags = AnySurfaceCraft;Cooking`, and award a small amount of Cooking XP.
- [x] Decide final batch yield during implementation; recommended starting point is `item 4 Pseudonymous.RawTortilla` because the recipe name and player-facing goal are plural.

**Technical Notes:**
Ingredient IDs verified from vanilla:
- `Base.Flour2` is vanilla flour (`media/scripts/generated/items/food.txt:5162`) and carries `Tags = base:flour;base:minoringredient`. `Base.Cornflour2` is vanilla cornflour (`media/scripts/generated/items/food.txt:5130`) and carries the same `base:flour` tag, so the implemented recipe uses `tags[base:flour]` to accept either flour or cornflour.
- `Base.Salt` is vanilla salt (`media/scripts/generated/items/food.txt:13488`).
- `Base.Butter` is vanilla butter (`media/scripts/generated/items/food.txt:4535`).

B42 fluid input patterns:
- `PseudoSaltRecipes` uses `item 1 [*] mode:keep` followed by `-fluid 1.0 [Water;TaintedWater]`.
- Vanilla pottery recipes use `-fluid 0.25 categories[Water] mode:mixture` in `media/scripts/generated/entities/pottery/cratRecipes/craftrecipe_potterywheel.txt:88`.

Implemented in `PseudoTortillas/42/media/scripts/recipes/PseudoTortillasRecipes.txt` with 60 flour units, 24 butter, and a yield of 4 raw tortillas.

Recommended recipe shape:

```txt
craftRecipe MakeRawTortillas
{
    timedAction = SliceMeat_Surface,
    time = 150,
    Tags = AnySurfaceCraft;Cooking,
    category = Cooking,
    xpAward = Cooking:5,
    inputs
    {
        item 60 tags[base:flour],
        item 1 [Base.Salt],
        item 24 [Base.Butter],
        item 1 [*] mode:keep,
                -fluid 0.25 [Water],
    }
    outputs
    {
        item 4 Pseudonymous.RawTortilla,
    }
}
```

### Phase 4: Add Soft Taco Evolved Recipe

**Status:** Work Complete

- [x] Add a new evolved recipe for soft tacos using `Base.Tortilla` as the base item.
- [x] Use the vanilla taco template so existing taco-compatible ingredients remain compatible.
- [x] Use `AddIngredientIfCooked = true` like vanilla tacos and burritos.
- [x] Decide whether the result item should be vanilla `Base.TacoRecipe`, vanilla `Base.Taco`, or a new mod-owned `Pseudonymous.SoftTacoRecipe` item.
- [x] Recommended starting point: use vanilla `Base.TacoRecipe` as the result for compatibility, but name the evolved recipe `Soft Taco` so players can distinguish it from hard-shell tacos if the UI supports the separate name cleanly.

**Technical Notes:**
Vanilla tacos are defined as evolved recipes in `media/scripts/generated/evolvedrecipes.txt:506`: `BaseItem = Base.TacoShell`, `MaxItems = 5`, `ResultItem = Base.TacoRecipe`, `AddIngredientIfCooked = true`, `Name = Taco`, `Template = Taco`. Vanilla `Taco2` extends an existing `Base.Taco` at `media/scripts/generated/evolvedrecipes.txt:516`. Vanilla burritos already use `Base.Tortilla` as a base item at `media/scripts/generated/evolvedrecipes.txt:526`, so a soft taco evolved recipe should be checked for conflicts with burrito creation in the crafting UI.

Implemented in `PseudoTortillas/42/media/scripts/evolvedrecipes/PseudoTortillasEvolvedRecipes.txt` using `module Base`, `BaseItem = Base.Tortilla`, `ResultItem = Base.TacoRecipe`, and `Template = Taco`.

Recommended first implementation:

```txt
evolvedrecipe SoftTaco
{
    BaseItem = Base.Tortilla,
    MaxItems = 5,
    ResultItem = Base.TacoRecipe,
    AddIngredientIfCooked = true,
    Name = Soft Taco,
    Template = Taco,
}
```

### Phase 5: Load and Gameplay Verification

**Status:** Planning - requires in-game verification

- [ ] Launch B42 with only `PseudoTortillas` and required baseline mods enabled.
- [ ] Confirm the mod loads with no console script errors.
- [ ] Confirm `MakeRawTortillas` appears in the Cooking crafting category.
- [ ] Craft raw tortillas with flour, salt, water, and butter.
- [ ] Cook raw tortillas on at least one normal heat source and confirm they become vanilla `Base.Tortilla`.
- [ ] Confirm raw tortillas cook at roughly the same speed as eggs.
- [ ] Confirm the soft taco evolved recipe is available from a vanilla tortilla and accepts normal taco ingredients.
- [ ] Confirm vanilla burrito behavior still appears and is not hidden or made unusable by the soft taco recipe.

**Technical Notes:**
This phase requires in-game testing. An agent may mark implementation tasks as complete after file edits and static review, but may not mark the cycle `Verified` without Ed's explicit approval.

---

## Open Questions

1. **How many raw tortillas should one recipe produce?**
   Decision: implemented as 4 raw tortillas per batch, because the ingredient list is closer to a batch of dough than a single tortilla and the recipe name is plural.

2. **Should soft tacos produce vanilla `Base.TacoRecipe` or a custom `Pseudonymous.SoftTacoRecipe` item?**
   Decision: implemented with vanilla `Base.TacoRecipe` for compatibility and minimal scope. If the UI cannot distinguish soft tacos clearly or the item should have different stats/art later, create a custom soft taco item in a future cycle.

3. **Should tainted water be allowed?**
   Decision: implemented with clean `Water` only. `PseudoSaltRecipes` intentionally allows `Water;TaintedWater` for fermentation/brining, but tortillas are a direct food craft and should start conservative.

---

## Notes and Risks

- Per `mymods/PseudoTortillas/AGENTS.md`, agents must stop after creating this DevCycle document and must not begin implementation until Ed explicitly requests it.
- `PseudoTortillas/42/` currently contains only `mod.info` and `poster.png`, so this cycle includes initial script directory creation.
- The soft taco evolved recipe may compete with vanilla `Burrito` because both would use `Base.Tortilla` as the base item. This must be checked in-game before considering the cycle done.
- `ReplaceOnCooked = Base.Tortilla` should be validated in-game with a mod item converting into a vanilla item. The pattern is used by `PseudoSaltRecipes` for mod-to-mod cooked replacements, but this specific mod-to-vanilla conversion still needs testing.
- Do not modify `common/media/scripts/` in this cycle unless testing proves B42 needs it; `PseudoSaltRecipes` treats `common/` as legacy B41 content.
- Implementation completed on 2026-06-26. Recipe quantities updated on 2026-06-26 to require 60 flour/cornflour units and 24 butter. Static checks confirmed the new script files exist under `42/media/scripts`, key vanilla identifiers (`Base.Flour2`, `Base.Salt`, `Base.Butter`, `Base.Tortilla`, `Base.TacoRecipe`) exist in generated vanilla scripts, multi-word evolved-recipe names are used by vanilla, and the fluid input follows the working `PseudoSaltRecipes` pattern. In-game verification is still required before marking this cycle `Verified`.

---

## Completion Summary

*Fill in when the cycle closes. Move this document to `doc/planning/completed/` afterward.*

**Completion Date:**
**Phases Completed:**
**Work Deferred:**

**Accomplishments:**
- 

**Metrics:**
- Files modified:
- In-game checks completed:

**Lessons / Notes:**

