# PseudoSaltRecipes — B42 Porting Handoff

**Created:** 2026-06-14  
**Author:** Claude (Sonnet 4.6)  
**Status:** In progress — mod does not yet work in B42  
**Mod location:** `mymods/PseudoSaltRecipes/42/`

---

## What This Mod Does

PseudoSaltRecipes adds salt preservation and fermentation recipes to Project Zomboid. It has two categories of content:

**Salt-cured meats** — recipes that take raw meat + salt and produce a preserved version with a much longer shelf life (DaysFresh 240, DaysTotallyRotten 540 vs vanilla's 2/4 days). Outputs inherit nutrition and food age from the input meat via `InheritFood`.

**Lacto-fermented vegetables** — recipes that take a vegetable + salt + water + a jar and produce a sealed fermented product. Three jar types are supported for each vegetable (EmptyJar, ClayJar, ClayJarGlazed). Outputs have fixed nutrition defined in the item. Fermented items can be cooked into a stew variant (`ReplaceOnCooked`).

**Vegetables with fermentation recipes:** Cabbage (Sauerkraut), Cucumber, Carrots, Radishes.

---

## Changes Made During This Session

All changes were derived by comparing PseudoSaltRecipes against the working mod `notmymods/VanillaCraftableFoods/42/` and confirmed against vanilla game files in `media/scripts/generated/`.

A parallel test mod (`mymods/PseudoTestRecipes/`) was used to verify fixes one at a time before applying them here. See `claudeDocs/claude_PseudoTestRecipesChangelog.md` for the full discovery log.

### Recipe file (`42/media/scripts/recipes/PseudoSaltRecipes.txt`)

**1. Recipe names — spaces removed**  
B42 treats recipe names as single tokens. All 15 recipe names had spaces removed and were converted to PascalCase:
- `Make Salted Fillet` → `MakeSaltedFillet`
- `Salt Meat ChickenStyle` → `SaltMeatChickenStyle`
- `Salt Meat AnimalStyle` → `SaltMeatAnimalStyle`
- `Make Sauerkraut` → `MakeSauerkraut`
- `Make Clay Jar Sauerkraut` → `MakeClayJarSauerkraut`
- `Make Glazed Jar Sauerkraut` → `MakeGlazedJarSauerkraut`
- `Make Fermented Cucumbers` → `MakeFermentedCucumbers`
- `Make Clay Jar Fermented Cucumbers` → `MakeClayJarFermentedCucumbers`
- `Make Glazed Jar Fermented Cucumbers` → `MakeGlazedJarFermentedCucumbers`
- `Make Fermented Carrots` → `MakeFermentedCarrots`
- `Make Clay Jar Fermented Carrots` → `MakeClayJarFermentedCarrots`
- `Make Glazed Jar Fermented Carrots` → `MakeGlazedJarFermentedCarrots`
- `Make Fermented Radishes` → `MakeFermentedRadishes`
- `Make Clay Jar Fermented Radishes` → `MakeClayJarFermentedRadishes`
- `Make Glazed Jar Fermented Radishes` → `MakeGlazedJarFermentedRadishes`

**2. `OnCreate` callbacks removed**  
Three recipes used `OnCreate = Recipe.OnCreate.*` callbacks (`CutFillet`, `CutChicken`, `CutAnimal`). These are B41-only handlers that no longer exist in B42. All three lines were removed.

**3. Tag syntax updated**  
B42 requires tag references to use the `base:` namespace prefix and be lowercase.
- `tags[SharpKnife;MeatCleaver]` → `tags[base:sharpknife;base:meatcleaver]` (3 recipes)
- `tags[SharpKnife]` → `tags[base:sharpknife]` (12 recipes)

**4. Missing mapper entry added**  
`SaltMeatAnimalStyle` listed `Base.Chicken` as a valid input but had no corresponding entry in its `itemMapper`. The item `Pseudonymous.SaltedChicken` was already defined. Added:
```
Pseudonymous.SaltedChicken = Base.Chicken,
```

### Items file (`42/media/scripts/items/PseudoSaltItems.txt`)

**5. `ItemType = base:food` added to all items**  
B42 requires all items to declare `ItemType`. The old `Type = Food` field is still required but is separate — B42 Lua reads item type via `getItemType()` which returns the `ItemType` field. Without it, `getItemType()` returns null and crashes the debug Items panel (`ISItemsListTable.lua:290`) when iterating loaded items. Added `ItemType = base:food,` to all 44 food items.

### mod.info

**6. `versionMin` added**  
Added `versionMin=42.0` so the game warns users running incompatible versions.

---

## Known Remaining Issues

The mod still does not work. The following areas are unverified and may contain further B42 incompatibilities:

### Fluid input syntax
All fermentation recipes use this pattern:
```
item 1 [*] mode:keep,
        -fluid 1.0 [Water;TaintedWater],
```

The working VanillaCraftableFoods uses a slightly different pattern:
```
item 1 [*],
-fluid 1.0 [Water],
```

Two differences to investigate:
- `mode:keep` on the `[*]` container — VanillaCraftableFoods never applies `mode:keep` to the wildcard fluid container. This may be invalid.
- `TaintedWater` as a fluid type — unconfirmed whether this is a valid fluid type for recipe inputs in B42. Check `media/scripts/generated/` for fluid type names.

### `InheritFood` vs `InheritFoodAge` on fermentation inputs
The fermentation recipes use `flags[InheritFoodAge;ItemCount]` on the vegetable inputs. This only copies food age, not nutrition. The output items define their own nutrition, so this is intentional — but it should be verified that `InheritFoodAge` is still a valid flag in B42 for this use case (it is present in vanilla cooking recipes, so this is likely fine).

### Item tags on fermented outputs
The item definitions use `Tags = FishMeat` style (no namespace prefix) for tags on the salted meat items. This was fixed in the test mod (`Tags = base:fishmeat`) but may not have been applied to all items in PseudoSaltItems.txt. Verify all `Tags =` lines use the `base:` prefix.

### No `DisplayType` on items  
Some B42 items use `DisplayType` (e.g. `DisplayType = Jar`). This may be required for the jar/crock items to display correctly in the crafting UI, but it is not confirmed as a hard requirement.

---

## Files Changed

| File | Changes |
|---|---|
| `42/media/scripts/recipes/PseudoSaltRecipes.txt` | Recipe names, OnCreate removed, tag syntax, missing mapper entry |
| `42/media/scripts/items/PseudoSaltItems.txt` | `ItemType = base:food` added to all 44 items |
| `42/mod.info` | `versionMin=42.0` added |

## Files Not Changed

| File | Notes |
|---|---|
| `common/media/scripts/` | Old B41 files, not loaded by the game. Left untouched. |

---

## Suggested Next Steps

1. Load the mod and check the console for parse errors at startup — this will confirm whether the recipe/item syntax is now accepted.
2. If it loads cleanly, attempt to craft `MakeSauerkraut` in-game to test the fluid input syntax.
3. If the fluid step fails, try removing `mode:keep` from the `[*]` container and test again.
4. If `TaintedWater` causes issues, reduce fluid input to `[Water]` only.
5. Audit all `Tags =` lines in `PseudoSaltItems.txt` to confirm the `base:` prefix is present on all of them.
