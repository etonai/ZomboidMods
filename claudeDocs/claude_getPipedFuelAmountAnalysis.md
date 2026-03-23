# getPipedFuelAmount Analysis - Project Zomboid

*Updated: August 20, 2025*

## Overview

Analysis of the `getPipedFuelAmount()` method in `zombie/iso/IsoObject.java`, which handles fuel dispensing at gas stations and fuel pumps in Project Zomboid.

## Method Signature

```java
public int getPipedFuelAmount()
```

**Location:** `IsoObject.java:2346-2417`

## Core Functionality

The method determines how much fuel is available from fuel dispensing objects (gas pumps, fuel stations) based on multiple factors including sandbox settings, power status, and object properties.

## Implementation Analysis

### 1. Initial Setup
```java
if (this.sprite == null) {
    return 0;
}
double d = -1.0;
boolean bl = false;
```
- Returns 0 if no sprite exists
- Initializes fuel amount to -1 (unset)

### 2. ModData Check
```java
if (this.hasModData() && !this.getModData().isEmpty() && 
    (object = this.getModData().rawget("fuelAmount")) != null) {
    d = (Double)object;
}
```
- Checks if fuel amount is already stored in object's mod data
- Uses stored value if available

### 3. Sprite Property Validation
```java
if (this.sprite.getProperties().Is("fuelAmount")) {
```
- Only proceeds if the sprite has the "fuelAmount" property
- This identifies fuel dispensing objects

### 4. Infinite Fuel Check
```java
if (SandboxOptions.getInstance().FuelStationGasInfinite.getValue()) {
    return 1000;
}
```
- **Sandbox Setting:** "Fuel Station Gas Infinite"
- Returns unlimited fuel (1000 units) if enabled

### 5. Power Requirement Check
```java
if (d == -1.0 && (SandboxOptions.getInstance().AllowExteriorGenerator.getValue() && 
    this.getSquare().haveElectricity() || this.hasGridPower())) {
```

**Power Requirements:**
- **Generator Power:** Exterior generators allowed AND square has electricity
- **Grid Power:** Object has grid power connection
- Only generates fuel if powered

### 6. Fuel Amount Calculation
```java
float f2 = (float)SandboxOptions.getInstance().FuelStationGasMin.getValue();
float f = (float)SandboxOptions.getInstance().FuelStationGasMax.getValue();
if (f2 > f) {
    f2 = f;
}
d = (int)Rand.Next(
    (float)Integer.parseInt(this.sprite.getProperties().Val("fuelAmount")) * f2, 
    (float)Integer.parseInt(this.sprite.getProperties().Val("fuelAmount")) * f
);
```

**Formula:**
```
finalFuel = baseFuelAmount × randomValue(minMultiplier, maxMultiplier)
```

**Where:**
- `baseFuelAmount`: Defined in sprite properties
- `minMultiplier`: FuelStationGasMin sandbox setting (0.0-1.0)
- `maxMultiplier`: FuelStationGasMax sandbox setting (0.0-1.0)

### 7. Empty Station Check
```java
if (this.getSquare().isNoGas() || 
    Rand.Next(100) < SandboxOptions.getInstance().FuelStationGasEmptyChance.getValue()) {
    d = 0.0;
}
```

**Empty Conditions:**
- **Map Property:** Square is marked as "no gas"
- **Random Chance:** Based on FuelStationGasEmptyChance sandbox setting

### 8. Visual Indicator System
```java
if (d == 0.0 && Rand.NextBool(2)) {
    // Add "outoforder" tile overlays
    IsoGridSquare isoGridSquare;
    // ... overlay placement logic
    object2 = (String)object2 + n;
    isoGridSquare.addTileObject((String)object2);
}
```
- 50% chance to add visual "out of order" indicators when empty
- Places overlay sprites on surrounding tiles

### 9. Data Persistence
```java
this.getModData().rawset("fuelAmount", d);
this.transmitModData();
return (int)d;
```
- Stores calculated fuel amount in mod data
- Syncs data across clients
- Returns final fuel amount

## Sandbox Settings Impact

| Setting | Effect |
|---------|--------|
| **FuelStationGasInfinite** | Returns 1000 fuel if enabled |
| **FuelStationGasMin** | Minimum fuel multiplier (0.0-1.0) |
| **FuelStationGasMax** | Maximum fuel multiplier (0.0-1.0) |
| **FuelStationGasEmptyChance** | Percentage chance station is empty |
| **AllowExteriorGenerator** | Allows generator power for exterior pumps |

## Power Dependencies

**Grid Power:**
- `hasGridPower()` → `getSquare().hasGridPower()`
- Connected to electrical grid system

**Generator Power:**
- Requires `AllowExteriorGenerator` sandbox setting
- `getSquare().haveElectricity()` checks for generator power
- Only works for exterior locations

## Key Features

1. **One-Time Calculation:** Fuel amount is calculated once and stored
2. **Power-Dependent:** No power = no fuel dispensing
3. **Sandbox Configurable:** Multiple settings control behavior
4. **Visual Feedback:** Empty stations get "out of order" overlays
5. **Multiplayer Safe:** Data synced across clients

## Related Methods

- `setPipedFuelAmount(int)` - Manually set fuel amount
- `hasGridPower()` - Check electrical grid connection
- `getSquare().haveElectricity()` - Check generator power

## Usage Context

This method is called when:
- Players interact with fuel dispensers
- Generators check for fuel-powered objects
- Game initializes fuel station contents
- Power status changes at fuel stations

## Summary

`getPipedFuelAmount()` implements a sophisticated fuel dispensing system that balances realism (power requirements, finite fuel) with gameplay flexibility (sandbox settings, random variation). The method ensures fuel stations behave consistently while providing server operators control over fuel availability and scarcity.