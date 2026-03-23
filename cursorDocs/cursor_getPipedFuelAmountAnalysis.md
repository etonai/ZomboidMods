# Analysis of getPipedFuelAmount Method in IsoObject.java

*Last Updated: August 20, 2025*

## Overview

The `getPipedFuelAmount()` method in `zombie/iso/IsoObject.java` is responsible for determining the fuel amount available at fuel station objects (gas pumps). This method implements a complex fuel availability system that takes into account sandbox settings, world conditions, and random chance factors.

## Method Signature

```java
public int getPipedFuelAmount()
```

**Return Type**: `int` - The amount of fuel available (0-1000)

## Core Logic Flow

### 1. **Initial Validation**
```java
if (this.sprite == null) {
    return 0;
}
```
- Returns 0 if the object has no sprite (invalid object)

### 2. **ModData Check**
```java
double d = -1.0;
if (this.hasModData() && !this.getModData().isEmpty() && 
    (object = this.getModData().rawget("fuelAmount")) != null) {
    d = (Double)object;
}
```
- Checks if the object already has stored fuel amount in its ModData
- If found, uses the stored value instead of recalculating

### 3. **Fuel Station Validation**
```java
if (this.sprite.getProperties().Is("fuelAmount")) {
    // Fuel station logic
}
```
- Only processes fuel logic if the sprite has the "fuelAmount" property
- This identifies the object as a fuel station

## Fuel Availability Logic

### **Infinite Fuel Setting**
```java
if (SandboxOptions.getInstance().FuelStationGasInfinite.getValue()) {
    return 1000;
}
```
- If "Fuel Station Gas Infinite" sandbox option is enabled, returns 1000 (effectively unlimited)

### **Grid Power Requirements**
```java
if (d == -1.0 && (SandboxOptions.getInstance().AllowExteriorGenerator.getValue() && 
    this.getSquare().haveElectricity() || this.hasGridPower())) {
    // Calculate fuel amount
}
```
- Fuel calculation only occurs if:
  - No stored fuel amount exists (`d == -1.0`)
  - AND either:
    - Exterior generators are allowed AND the square has electricity, OR
    - The object has grid power

## Fuel Amount Calculation

### **Base Range**
```java
float f2 = (float)SandboxOptions.getInstance().FuelStationGasMin.getValue();
float f = (float)SandboxOptions.getInstance().FuelStationGasMax.getValue();
if (f2 > f) {
    f2 = f; // Ensure min <= max
}
d = (int)Rand.Next(
    (float)Integer.parseInt(this.sprite.getProperties().Val("fuelAmount")) * f2,
    (float)Integer.parseInt(this.sprite.getProperties().Val("fuelAmount")) * f
);
```
- Uses sandbox settings `FuelStationGasMin` and `FuelStationGasMax` as multipliers
- Applies these multipliers to the sprite's base fuel amount
- Generates a random value within this range

### **Empty Station Chance**
```java
if (this.getSquare().isNoGas() || 
    Rand.Next(100) < SandboxOptions.getInstance().FuelStationGasEmptyChance.getValue()) {
    d = 0.0;
}
```
- Sets fuel to 0 if:
  - The square is marked as "no gas", OR
  - Random chance based on `FuelStationGasEmptyChance` sandbox setting

## Sign Placement Logic

### **Empty Station Signs**
```java
if (d == 0.0 && Rand.NextBool(2)) {
    // Place "out of gas" signs
}
```
- 50% chance to place signs when station is empty
- Signs indicate the station is out of fuel

### **Sign Type Selection**
```java
Object object2 = "signs_one-off_07_8";
int n = 5;
if (Objects.equals(this.square.getZombiesType(), "Fossoil")) {
    object2 = "location_shop_fossoil_01_6";
    n = 8;
} else if (Objects.equals(this.square.getZombiesType(), "Gas2Go")) {
    object2 = "location_shop_gas2go_01_3";
    n = 8;
}
```
- Different sign sprites for different gas station chains
- Fossoil and Gas2Go get specific branded signs
- Generic stations get standard "out of gas" signs

### **Sign Placement Validation**
```java
if (isoDirections == IsoDirections.E || isoDirections == IsoDirections.W) {
    ++n;
}
object2 = (String)object2 + n;
isoGridSquare.addTileObject((String)object2);
```
- Adjusts sign sprite number based on direction
- Places the sign on an adjacent square

## Sandbox Options Used

| Option | Purpose | Default Value |
|--------|---------|---------------|
| `FuelStationGasInfinite` | Enables unlimited fuel | Boolean |
| `AllowExteriorGenerator` | Allows exterior generators | Boolean |
| `FuelStationGasMin` | Minimum fuel multiplier | Float |
| `FuelStationGasMax` | Maximum fuel multiplier | Float |
| `FuelStationGasEmptyChance` | Chance of empty station | Integer |

## Data Persistence

### **ModData Storage**
```java
this.getModData().rawset("fuelAmount", d);
this.transmitModData();
```
- Calculated fuel amount is stored in the object's ModData
- Data is transmitted to clients for multiplayer synchronization

### **Setter Method**
```java
public void setPipedFuelAmount(int n) {
    int n2;
    if ((n = Math.max(0, n)) != (n2 = this.getPipedFuelAmount())) {
        this.getModData().rawset("fuelAmount", n);
        this.transmitModData();
    }
}
```
- Allows manual setting of fuel amount
- Only updates if the value actually changes
- Ensures fuel amount is never negative

## Key Features

1. **Caching**: Fuel amounts are calculated once and stored in ModData
2. **Sandbox Integration**: Multiple sandbox options control fuel availability
3. **Realistic Simulation**: Empty stations get appropriate signage
4. **Multiplayer Support**: Fuel data is synchronized across clients
5. **Grid Power Dependency**: Fuel availability depends on electrical infrastructure

## Use Cases

- **Fuel Stations**: Primary use case for gas pumps
- **Generator Fuel**: May be used for other fuel-consuming objects
- **World Generation**: Determines fuel availability during map generation
- **Dynamic Events**: Fuel amounts can change based on world conditions

## Code Location

**File**: `zombie/iso/IsoObject.java`  
**Lines**: 2346-2420  
**Class**: `IsoObject`

## Related Methods

- `setPipedFuelAmount(int)` - Sets fuel amount
- `hasGridPower()` - Checks if object has electrical power
- `getSquare().haveElectricity()` - Checks if square has electricity
- `transmitModData()` - Synchronizes data with clients

## Summary

The `getPipedFuelAmount()` method implements a sophisticated fuel availability system that balances gameplay mechanics with realistic simulation. It considers sandbox settings, world conditions, and random chance to create varied fuel station experiences while maintaining performance through data caching and multiplayer synchronization. 