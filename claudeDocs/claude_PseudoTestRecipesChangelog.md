# PseudoTestRecipes — B42 Porting Changelog

**Status:** Working as of 2026-06-14

**Created:** 2026-06-14  
**Purpose:** Track changes made to PseudoTestRecipes and the reasoning behind each fix  
**Context:** PseudoTestRecipes is a minimal single-recipe test mod used to verify B42 recipe syntax before applying fixes to PseudoSaltRecipes

---

## Changes

### 1. Recipe name spaces removed
**File:** `42/media/scripts/recipes/PseudoSaltRecipes.txt`  
`craftRecipe Make Salted Fillet` → `craftRecipe MakeSaltedFillet`  
**Why:** B42 treats recipe names as single tokens. Spaces cause parse or registration failures. All working B42 mods use single-word PascalCase names.

---

### 2. `OnCreate` callback removed
**File:** `42/media/scripts/recipes/PseudoSaltRecipes.txt`  
Removed: `OnCreate = Recipe.OnCreate.CutFillet`  
**Why:** The `Recipe.OnCreate.*` callback namespace is B41-only. These handlers no longer exist in B42 and cause recipe registration to fail.

---

### 3. Tag syntax updated to B42 format
**File:** `42/media/scripts/recipes/PseudoSaltRecipes.txt`  
`tags[SharpKnife;MeatCleaver]` → `tags[base:sharpknife;base:meatcleaver]`  
**Why:** B42 requires tag references to include the module namespace prefix (`base:`) and be lowercase. Without this, no tool ever matches the recipe.

---

### 4. `InheritFood` vs `InheritFoodAge` — two distinct flags
**File:** `42/media/scripts/recipes/PseudoSaltRecipes.txt`  
Both flags are valid in B42 but do different things:
- `InheritFood` — inherits all food properties from the input, including nutrition (HungerChange, Calories, Carbohydrates, Lipids, Proteins) and age
- `InheritFoodAge` — inherits only the food age, not nutrition

For a salting recipe the input food's nutrition should carry through to the output, so `InheritFood` is correct. The item definition should not hardcode nutrition values — they are supplied at craft time by `InheritFood`. Using `InheritFoodAge` here would result in all nutritional values showing as 0.

---

### 5. Item tag updated to B42 format
**File:** `42/media/scripts/items/PseudoSaltItems.txt`  
`Tags = FishMeat` → `Tags = base:fishmeat`  
**Why:** Item tags follow the same namespace convention as recipe tags in B42. Other recipes searching for `base:fishmeat` would not find this item without the prefix.

---

### 6. `versionMin` added to mod.info
**File:** `42/mod.info`  
Added: `versionMin=42.0`  
**Why:** Tells the game the minimum compatible version. Without it the game won't warn users running an incompatible version.

---

### 7. `ItemType` field added to food item
**File:** `42/media/scripts/items/PseudoSaltItems.txt`  
Added: `ItemType = base:food`  
**Why:** B42 requires all items to declare an `ItemType` field. The old `Type = Food` field is still needed but is separate — `ItemType` is what the game's Lua reads via `getItemType()`. Without it, `getItemType()` returns null and crashes the debug Items panel (`ISItemsListTable.lua:290`) when iterating over all loaded items.
