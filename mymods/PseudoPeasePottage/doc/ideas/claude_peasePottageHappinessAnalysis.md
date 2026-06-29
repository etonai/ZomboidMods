# Pease Pottage Happiness Behavior Analysis

**Created:** 2026-06-29  
**Updated:** 2026-06-29  
**Version Context:** Project Zomboid 42.11.0 codebase analysis, PseudoPeasePottage Dev Cycle 1 implementation  
**Scope:** Why adding ground beef improves pot of rice happiness faster than pot of pease pottage.

## Summary

The observed difference is not caused by ground beef having a special happiness value. Ground beef has evolved recipe entries for both `Stew` and `Rice`, but no direct `UnhappyChange` field in its item definition.

The difference comes from how the two evolved recipes are structured:

- Vanilla rice starts from a separate water-rice base item, such as `Base.WaterPotRice`, and produces `Base.RicePot`.
- PseudoPeasePottage starts from `Pseudonymous.PeasePottagePot` and also produces `Pseudonymous.PeasePottagePot`.

When an evolved recipe transforms a base item into a different result item, the engine explicitly resets the result item's `UnhappyChange` and `BoredomChange` to `0`. Rice benefits from that reset before ground beef applies its normal ingredient happiness adjustment. Pease pottage does not, because the pottage item is already the result item, so its script value of `UnhappyChange = 20` remains in place.

In practical terms:

- First ground beef added to rice can move the result from `0` unhappy to about `-5` unhappy, which appears as a fast happiness improvement.
- First ground beef added to pease pottage moves it from `20` unhappy to about `15` unhappy, which is still an unhappy food.

## Relevant Script Definitions

### PseudoPeasePottage Items

The current mod items both start with a high base unhappiness value:

```txt
mymods/PseudoPeasePottage/PseudoPeasePottage/42/media/scripts/items/PseudoPeasePottageItems.txt:3
item PeasePottagePot
...
mymods/PseudoPeasePottage/PseudoPeasePottage/42/media/scripts/items/PseudoPeasePottageItems.txt:22
UnhappyChange = 20,

mymods/PseudoPeasePottage/PseudoPeasePottage/42/media/scripts/items/PseudoPeasePottageItems.txt:35
item PeasePottagePan
...
mymods/PseudoPeasePottage/PseudoPeasePottage/42/media/scripts/items/PseudoPeasePottageItems.txt:55
UnhappyChange = 20,
```

The evolved recipes use the same item as both base and result:

```txt
mymods/PseudoPeasePottage/PseudoPeasePottage/42/media/scripts/evolvedrecipes/PseudoPeasePottageEvolvedRecipes.txt:13
evolvedrecipe PeasePottagePot
{
    BaseItem = Pseudonymous.PeasePottagePot,
    MaxItems = 6,
    ResultItem = Pseudonymous.PeasePottagePot,
    Cookable = true,
    Template = Stew,
}
```

### Vanilla Rice

Vanilla rice result items also have `UnhappyChange = 20` in their final item definitions:

```txt
media/scripts/generated/items/food.txt:6266
item RicePot
...
media/scripts/generated/items/food.txt:6283
UnhappyChange = 20,
```

However, the evolved recipe starts from a different water-rice item and produces the final rice item:

```txt
media/scripts/generated/evolvedrecipes.txt:328
evolvedrecipe RicePot
{
    BaseItem = Base.WaterPotRice,
    MaxItems = 5,
    ResultItem = Base.RicePot,
    Cookable = true,
    AddIngredientIfCooked = true,
    Name = Prepare Rice,
    CanAddSpicesEmpty = true,
    Template = Rice,
}
```

That separate base/result structure is the important difference.

### Ground Beef

Ground beef is `Base.MincedMeat`. It can be added to both rice and stew-template recipes:

```txt
media/scripts/generated/items/food.txt:9449
item MincedMeat
...
media/scripts/generated/items/food.txt:9458
EvolvedRecipe = Pizza:20;Stew:20;Pie:20;Sandwich:5|Cooked;Burger:10|Cooked;Hotdog:10|Cooked;Taco:10|Cooked;Burrito:10|Cooked;Pasta:20;Rice:20;Stir fry:20,
```

There is no `UnhappyChange` field in this item block, so the quick rice improvement is not coming from a special ground-beef happiness bonus.

## Template Matching

The pottage recipe correctly receives stew-compatible ingredients through its `Template = Stew` setting. The engine registers an ingredient with evolved recipes that either match the named recipe directly or share the requested template:

```java
// zombie42_11/scripting/objects/Item.java:3676
public void OnScriptsLoaded(ScriptLoadMode scriptLoadMode) throws Exception {
    ArrayList<EvolvedRecipe> arrayList = ScriptManager.instance.getAllEvolvedRecipesList();
    for (Map.Entry<String, ItemRecipe> entry : this.itemRecipeMap.entrySet()) {
        boolean bl = false;
        EvolvedRecipe evolvedRecipe = ScriptManager.instance.getEvolvedRecipe(entry.getKey());
        if (evolvedRecipe != null) {
            evolvedRecipe.itemsList.put(this.name, entry.getValue());
            bl = true;
        }
        for (EvolvedRecipe evolvedRecipe2 : arrayList) {
            if (!evolvedRecipe2.template.equalsIgnoreCase(entry.getKey())) continue;
            evolvedRecipe2.itemsList.put(this.name, entry.getValue());
            bl = true;
        }
```

This means `Base.MincedMeat`'s `Stew:20` entry is enough to make it valid for pease pottage, because pease pottage uses `Template = Stew`.

## Engine Happiness Behavior

The crucial logic is in `EvolvedRecipe.addItem`.

When the recipe's current base item is not already the result item, the engine creates/replaces it with the result item. During that replacement, it resets unhappy and boredom:

```java
// zombie42_11/scripting/objects/EvolvedRecipe.java:296
inventoryItem.setUnhappyChange(0.0f);
inventoryItem.setBoredomChange(0.0f);
```

After that, for a normal non-spice food ingredient, the evolved recipe recalculates unhappiness from the current unmodified unhappiness:

```java
// zombie42_11/scripting/objects/EvolvedRecipe.java:373
inventoryItem.setUnhappyChange(((Food)inventoryItem).getUnhappyChangeUnmodified() - (float)(5 - n2 * 5));
if (inventoryItem.getUnhappyChange() > 25.0f) {
    inventoryItem.setUnhappyChange(25.0f);
}
```

For the first non-duplicate ingredient, `n2` is normally `0`, so the formula subtracts `5` from the food's current unmodified unhappy value.

## Why Rice Improves Faster

For vanilla `RicePot`:

1. The player begins with `Base.WaterPotRice`, not `Base.RicePot`.
2. Adding ground beef causes the evolved recipe to create the result item, `Base.RicePot`.
3. During result creation, the engine resets the result item's unhappiness to `0`.
4. The ground beef ingredient then applies the normal first-ingredient adjustment: `0 - 5 = -5`.

So even though the final `RicePot` script says `UnhappyChange = 20`, the evolved recipe path can clear that penalty before applying the ingredient adjustment.

For `PeasePottagePot`:

1. The player begins with `Pseudonymous.PeasePottagePot`.
2. The evolved recipe result is also `Pseudonymous.PeasePottagePot`.
3. Because the item is already the result item, the replacement/reset path does not clear the scripted `UnhappyChange = 20`.
4. The ground beef ingredient applies the normal first-ingredient adjustment: `20 - 5 = 15`.

That is still an unhappy food, so the tooltip will not show the same quick happiness improvement that rice shows.

## Secondary Differences

Rice also has:

```txt
AddIngredientIfCooked = true,
CanAddSpicesEmpty = true,
```

Pease pottage currently does not. These flags matter for adding ingredients after cooking and adding spices to an otherwise empty base, but they are probably not the primary reason for the ground-beef happiness difference. The main observed difference is explained by the separate rice base item and the result-item happiness reset.

## Fix Candidates For A Future Dev Cycle

### Option 1: Lower or remove pease pottage base unhappiness

Set `PeasePottagePot` and `PeasePottagePan` to `UnhappyChange = 0`, or remove the field if the default is acceptable.

Expected effect:

- Plain pease pottage becomes neutral instead of starting at `20` unhappy.
- First normal ingredient would move it toward `-5` unhappy, matching the practical rice behavior more closely.
- This is the smallest script-only fix.

Tradeoff:

- It does not mirror vanilla rice's exact base/result structure.

### Option 2: Add intermediate water-pottage base items

Create intermediate items such as:

- `WaterPotPeasePottage`
- `WaterSaucepanPeasePottage`

Then make the crafting recipes produce those intermediate items, and make the evolved recipes convert them into:

- `PeasePottagePot`
- `PeasePottagePan`

Expected effect:

- This follows the vanilla rice/pasta pattern more closely.
- The engine result-item reset should clear unhappy/boredom before the first added ingredient, just like rice.

Tradeoff:

- More script and translation work.
- More item states to test.

### Option 3: Add cooked-ingredient/spice flags

Add:

```txt
AddIngredientIfCooked = true,
CanAddSpicesEmpty = true,
```

Expected effect:

- Better parity with rice for post-cooking additions and empty-base spices.

Tradeoff:

- This does not by itself fix the high starting unhappiness. If `UnhappyChange = 20` remains and the pottage item remains both base and result, ground beef will still only reduce it to about `15` on the first add.

## Recommendation

For Dev Cycle 2, the best target depends on desired vanilla parity:

- If the goal is a quick balance fix, set pease pottage base unhappiness to `0` and consider adding `AddIngredientIfCooked = true`.
- If the goal is rice/pasta-style behavior, introduce intermediate water-pottage items and update the evolved recipes so pease pottage has distinct base and result items.

The second approach is more work, but it is the most code-faithful explanation of why rice behaves better today.
