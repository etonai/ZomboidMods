# Lacto-Fermented Vegetable Item/Recipe Formula

**Created:** 2026-06-20
**Version:** Project Zomboid 42.x
**Purpose:** Defines the repeatable formula for adding a new `LactoFermentedVEGETABLE` item (and its recipe) to the PseudoSaltRecipes mod, based on the existing pattern in `mymods/PseudoSaltRecipes/42/media/scripts/items/PseudoSaltItems.txt`.

---

## Source of Truth

Pattern derived from `LactoFermentedCabbage` (`PseudoSaltItems.txt:564`) and confirmed by reverse-engineering the three vegetables already ported: `LactoFermentedCucumber` (:729), `LactoFermentedCarrot` (:894), `LactoFermentedRadish` (:1059). All three match the formula below exactly, confirming it against the vanilla item data in `media/scripts/generated/items/food.txt`.

---

## Step 1: Find the vanilla vegetable's base stats

Look up the raw vegetable item in `media/scripts/generated/items/food.txt`. You need:
- `HungerChange` (negative value)
- `Carbohydrates`
- `Proteins`
- `Lipids`
- `Calories`

| Vegetable | HungerChange | Carbohydrates | Proteins | Lipids | Calories |
|---|---|---|---|---|---|
| Cabbage (food.txt:145) | -24.0 | 41.0 | 9.0 | 0.7 | 180.0 |
| Cucumber (food.txt:14255) | -10.0 | 6.1 | 2.37 | 0.63 | 33.0 |
| Carrots (food.txt:14151) | -8.0 | 6.0 | 0.6 | 0.15 | 25.0 |
| RedRadish (food.txt:49) | -3.0 | 0.15 | 0.0 | 0.0 | 1.0 |

## Step 2: Pick N — the whole-number vegetable count

Choose the smallest whole number `N` such that:

```
N * vanilla.HungerChange  is between -24 and -36 (inclusive)
```

i.e. `abs(N * HungerChange)` falls in `[24, 36]`. This is also the `item N [Base.Vegetable]` count used in the crafting recipe's input line.

Confirmed values already in the mod:
- Cabbage: N=1 → 1 × -24 = **-24** ✓ (recipe: `item 1 [Base.Cabbage]`)
- Cucumber: N=3 → 3 × -10 = **-30** ✓ (recipe: `item 3 [Base.Cucumber]`)
- Carrots: N=3 → 3 × -8 = **-24** ✓ (recipe: `item 3 [Base.Carrots]`)
- RedRadish: N=8 → 8 × -3 = **-24** ✓ (recipe: `item 8 [Base.RedRadish]`)

**Always take the smallest N that lands in range — do not pick a larger N just because it's also valid.** Since `N * HungerChange` grows in magnitude as `N` increases, the smallest valid `N` is also the one that lands closest to -24 (the low end of the range), and using more vegetables than necessary contradicts the existing pattern of using the fewest raw vegetables needed.

Example: a vegetable with `HungerChange = -6` has *three* candidate N values that satisfy the range — N=4 (-24), N=5 (-30), N=6 (-36). Use **N=4 → -24**, not 5 or 6.

## Step 3: Compute the new item's nutritional fields

Multiply every nutritional field by `N`:

```
new.HungerChange   = N * vanilla.HungerChange
new.Carbohydrates  = N * vanilla.Carbohydrates
new.Proteins       = N * vanilla.Proteins
new.Lipids         = N * vanilla.Lipids
new.Calories        = N * vanilla.Calories
```

Verified against existing data:
- Cucumber (N=3): Carbs 6.1×3=**18.3**, Proteins 2.37×3=**7.11**, Lipids 0.63×3=**1.89**, Calories 33×3=**99** — matches `LactoFermentedCucumber` exactly.
- Carrots (N=3): Carbs 6.0×3=**18.0**, Proteins 0.6×3=**1.8**, Lipids 0.15×3=**0.45**, Calories 25×3=**75** — matches `LactoFermentedCarrot` exactly.
- RedRadish (N=8): Carbs 0.15×8=**1.2**, Proteins 0×8=**0.0**, Lipids 0×8=**0.0**, Calories 1×8=**8** — matches `LactoFermentedRadish` exactly.

**Known deviation:** `LactoFermentedCabbage` uses `HungerChange = -25` instead of the formula result of `-24` (1×-24). Its Carbohydrates/Proteins/Lipids/Calories (41.41 / 9.14 / 0.71 / 178) are also slightly off from a clean ×1 multiply (41.0 / 9.0 / 0.7 / 180.0). This looks like a manual rounding choice by the original mod author rather than the formula — treat Cabbage as the one hand-tuned exception, and use the formula as written for all new vegetables.

## Step 4: Fixed fields (copy unchanged from `LactoFermentedCabbage`)

```
Weight              = 0.7
Type                = Food
ItemType            = base:food
DaysFresh           = 120
DaysTotallyRotten   = 240
ThirstChange        = 5
Packaged            = TRUE
FoodType            = Vegetables
EatType             = can
IsCookable          = TRUE
MinutesToCook       = 10
MinutesToBurn       = 40
CookingSound        = BoilingFood
```

## Step 5: Vegetable-specific naming/display fields

```
DisplayName        = Jar of Fermented <Vegetable>(s)
Icon               = JarWhite
EvolvedRecipeName  = Fermented <Vegetable>
ReplaceOnUse       = Base.EmptyJar
ReplaceOnCooked    = Pseudonymous.JarOf<Vegetable>Stew   (the cooked-variant item, see Step 6)
StaticModel        = JarWhite
EvolvedRecipe      = Soup:15;Stew:15;Stir fry Griddle Pan:15;Stir fry:15;Sandwich:10;Burger:10;Salad:15;Roasted Vegetables:15
```

## Step 6: The companion "stew" item (cooked output)

Every `LactoFermented<Vegetable>` has a matching `<Container>Of<Vegetable>Stew` item (e.g. `JarOfCarrotStew`) that it cooks into. It reuses the **same nutritional values** as the fermented item (same N×vanilla math) but with:

```
DisplayName       = Jar of Fermented <Vegetable> Stew
DaysFresh         = 3
DaysTotallyRotten = 5
ReplaceOnUse      = Base.EmptyJar
(no ReplaceOnCooked, no IsCookable/MinutesToCook/MinutesToBurn/CookingSound)
BadCold           = false
GoodHot           = true
```

## Step 7: ClayJar and GlazedJar variants

The mod also defines `LactoFermented<Vegetable>ClayJar` and `LactoFermented<Vegetable>GlazedJar` (plus their stew variants), identical to Steps 4–6 except:
- `Icon`/`StaticModel` = `ClayJar_Fired` (clay) or `ClayJar_Glazed_Fired`/`GlazedClayJar` (glazed) instead of `JarWhite`
- `ReplaceOnUse` = `Base.ClayJar` or `Base.ClayJarGlazed` instead of `Base.EmptyJar`
- `ReplaceOnCooked` points to `ClayJarOf<Vegetable>Stew` / `GlazedJarOf<Vegetable>Stew` respectively
- Recipe input swaps `[Base.EmptyJar]` for `[Base.ClayJar]` / `[Base.ClayJarGlazed]`

Nutritional values and `N` are identical across all three jar variants of the same vegetable — only the container-related fields change.

---

## Step 8: Recipe definition in PseudoSaltRecipes.txt

Each item variant from Steps 5–7 needs a matching `craftRecipe` in `mymods/PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt` (and the same change must be mirrored into the test mod at `mymods/PseudoTestRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt` per the DevCycle 1 process — port to the test mod first, verify in-game, then backport).

All fermentation recipes in this family share an identical skeleton — only the recipe name, jar input, vegetable input/count, and output item change:

```
craftRecipe Make<Variant>Fermented<Vegetable>s
{
    timedAction = SliceMeat_Surface,
    time = 200,
    Tags = AnySurfaceCraft;Cooking,
    category = Cooking,
    xpAward = Cooking:10,
    inputs
    {
        item 1 tags[base:sharpknife] mode:keep flags[IsNotDull;SharpnessCheck],
        item 1 [<JarType>] mode:destroy flags[ItemCount],
        item N [Base.<Vegetable>] flags[InheritFoodAge;ItemCount] mode:destroy,
        item 3 [Base.Salt],
        item 1 [*] mode:keep,
        		-fluid 1.0 [Water;TaintedWater],
    }
    outputs
    {
        item 1 Pseudonymous.LactoFermented<Vegetable><JarSuffix>,
    }
}
```

Field-by-field:
- **Recipe name**: `MakeFermented<Vegetable>s` for the empty-jar version, `MakeClayJarFermented<Vegetable>s` for clay, `MakeGlazedJarFermented<Vegetable>s` for glazed (pluralize the vegetable name the same way the existing recipes do — e.g. `Cucumbers`, `Carrots`, `Radishes`).
- **`timedAction`, `time`, `Tags`, `category`, `xpAward`**: always identical across every recipe in this family — copy verbatim (`SliceMeat_Surface`, `200`, `AnySurfaceCraft;Cooking`, `Cooking`, `Cooking:10`).
- **Sharp knife input**: always identical — copy verbatim. It's `mode:keep` (the knife isn't consumed) and requires `IsNotDull`/`SharpnessCheck`.
- **Jar input** (`<JarType>`): `Base.EmptyJar` / `Base.ClayJar` / `Base.ClayJarGlazed` for the three variants — matches the `ReplaceOnUse` value used on the corresponding item from Step 7. The jar is `mode:destroy` with `flags[ItemCount]`.
- **Vegetable input**: `item N [Base.<Vegetable>]` where `N` is the exact same whole number computed in Step 2 — the recipe input count and the nutritional multiplier must always match. Always `flags[InheritFoodAge;ItemCount] mode:destroy`.
- **Salt input**: always `item 3 [Base.Salt]` — fixed across the whole recipe family, independent of `N`.
- **Wildcard container input**: always `item 1 [*] mode:keep` — this is the fermentation vessel/surface the recipe is performed on; it is kept, not consumed.
- **Fluid input**: always `-fluid 1.0 [Water;TaintedWater]` — accepts either clean or tainted water.
- **Output**: exactly one of the item from Step 5 (empty jar), Step 7-clay, or Step 7-glazed, matching the jar input used.

### Worked example: a new `MakeFermentedTurnips` (hypothetical, N=4)

```
craftRecipe MakeFermentedTurnips
{
    timedAction = SliceMeat_Surface,
    time = 200,
    Tags = AnySurfaceCraft;Cooking,
    category = Cooking,
    xpAward = Cooking:10,
    inputs
    {
        item 1 tags[base:sharpknife] mode:keep flags[IsNotDull;SharpnessCheck],
        item 1 [Base.EmptyJar] mode:destroy flags[ItemCount],
        item 4 [Base.Turnip] flags[InheritFoodAge;ItemCount] mode:destroy,
        item 3 [Base.Salt],
        item 1 [*] mode:keep,
        		-fluid 1.0 [Water;TaintedWater],
    }
    outputs
    {
        item 1 Pseudonymous.LactoFermentedTurnip,
    }
}
```

Repeat with `Base.ClayJar`/`LactoFermentedTurnipClayJar` and `Base.ClayJarGlazed`/`LactoFermentedTurnipGlazedJar` for the other two jar tiers.

### Stew items get no craftRecipe of their own

Confirmed by grep: `PseudoSaltRecipes.txt` has zero `craftRecipe` blocks referencing any `*Stew` item. The full Radish family is exactly **3 recipes** — `MakeFermentedRadishes`, `MakeClayJarFermentedRadishes`, `MakeGlazedJarFermentedRadishes` — and they only ever output the three `LactoFermentedRadish`/`LactoFermentedRadishClayJar`/`LactoFermentedRadishGlazedJar` items.

The stew items (`JarOfRadishStew`, `ClayJarOfRadishStew`, `GlazedJarOfRadishStew`) are produced automatically by the base game's cooking system, not by a recipe: each `LactoFermented<Vegetable><JarSuffix>` item has `IsCookable = TRUE` plus `ReplaceOnCooked = Pseudonymous.<Container>Of<Vegetable>Stew` (see Step 6/7). Once the player cooks the fermented jar item (e.g. on a stove/campfire) the engine swaps it for the stew item directly — no `craftRecipe` entry is needed or wanted for that conversion.

So for a new vegetable, the complete unit of work per jar tier is:
1. One `item LactoFermented<Vegetable><JarSuffix>` (Steps 4–7) with `ReplaceOnCooked` pointing at...
2. One `item <Container>Of<Vegetable>Stew` (Step 6) — no recipe attached.
3. One `craftRecipe Make<Variant>Fermented<Vegetable>s` (Step 8) that outputs item #1 — never item #2.

Across all three jar tiers that's **6 items** and **3 recipes** per vegetable, matching the Radish/Carrot/Cucumber pattern exactly.

---

## Worked Example Template

For a new vegetable `X` with vanilla `HungerChange = H`, `Carbohydrates = C`, `Proteins = P`, `Lipids = L`, `Calories = K`:

1. Find smallest whole `N` where `N*H` is in `[-36, -24]`.
2. `item LactoFermented<X>`: `HungerChange = N*H`, `Carbohydrates = N*C`, `Proteins = N*P`, `Lipids = N*L`, `Calories = N*K`, plus fixed fields from Step 4 and naming from Step 5.
3. Add matching `JarOf<X>Stew` per Step 6.
4. Add `ClayJar`/`GlazedJar` variants per Step 7 if the full jar-tier set is desired.
5. Add the corresponding `craftRecipe` with `item N [Base.X]` as the vegetable input, following the existing `MakeFermented<X>` pattern (see `mymods/PseudoSaltRecipes/42/media/scripts/recipes/PseudoSaltRecipes.txt`).
