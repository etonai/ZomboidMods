# Project Zomboid Fishing System Analysis

*Updated: August 21, 2025*

## Overview

Project Zomboid features a sophisticated fishing system that combines Java engine mechanics with extensive Lua scripting. The system includes fish behavior simulation, environmental factors, skill progression, and complex lure/bait mechanics.

## Core Architecture

### Java Engine Components

**FishingAction.java** (`zombie/core/FishingAction.java`)
- Main action class extending `Action` for fishing activities
- Handles multiplayer synchronization with flags for different states
- Manages bobber creation, fish updates, and rod parameters
- Duration: 100,000 game ticks (very long-running action)

**FishingState.java** (`zombie/ai/states/FishingState.java`)
- Character state machine for fishing animations and behavior
- Manages fishing variables: `FishingFinished`, `FishingStage`, `FishingX/Y`
- Handles movement interruption (standing up from fishing)

**FishSchoolManager.java** (`zombie/iso/FishSchoolManager.java`)
- Procedural fish abundance generation using seed-based algorithms
- Manages fish zones, chum effects, and noise disruption
- Handles visual fish splashes and abundance calculations
- Implements trash vs. fish probability systems

### Lua Script Components

**Core System Files:**
- `Fish.lua` - Fish behavior and catching mechanics
- `FishingRod.lua` - Rod mechanics, tension, and line management  
- `FishingManager.lua` - State machine and UI coordination
- `Bobber.lua` - Bobber physics and fish attraction
- `fishing_properties.lua` - Fish species, lures, and equipment data

## Fish Species System

### Available Fish (19 Species)

The game includes detailed configurations for North American freshwater fish:

**Bass Family:**
- Largemouth Bass (51cm max, 2.8kg, trophy: 75cm/10kg)
- Smallmouth Bass (41cm max, 2.3kg)
- Spotted Bass (38cm max, 1.8kg)
- White Bass (38cm max, 1.5kg)
- Striped Bass (76cm max, 9kg) - Large saltwater species

**Sunfish Family:**
- Bluegill (20cm max, 1.4kg)
- Redear Sunfish (20cm max, 1.4kg)
- Green Sunfish (20cm max, 1.4kg)

**Others:**
- Walleye (80cm max, 9kg) - Excellent table fare
- Yellow Perch (30cm max, 1.0kg)
- Crappie (White/Black, ~25-30cm)
- Channel/Blue/Flathead Catfish (large bottom feeders)
- Muskellunge (101cm max, 18kg) - Apex predator
- Alligator Gar (180cm max, 45kg) - Massive predator
- Freshwater Drum (76cm max, 4.5kg)
- Paddlefish (150cm max, 27kg) - Filter feeder
- Sauger (45cm max, 1.9kg)
- BaitFish (5-10cm, 0.05kg) - Used as live bait

### Fish Size Categories

**Small Fish (Bottom third of size range):**
- Easier to catch for beginners
- Lower nutritional value but reliable food source
- Weight: 0.1kg to 20% of max weight

**Medium Fish (Middle third):**
- Balanced difficulty and reward
- Weight: 20% to 60% of max weight

**Big Fish (Top third):**
- Require higher fishing skill to catch
- Maximum nutritional and XP rewards
- Weight: 60% to 100% of max weight

**Legendary Fish:**
- Level 8+ fishing skill required
- 5% chance (1/20 roll) when catching big fish
- Exceed normal maximum size/weight limits
- Trophy variants with exceptional dimensions

## Bait and Lure System

### Bait Categories

**Insects (Natural):**
- Crickets, Grasshoppers, Caterpillars
- Best for small fish like Bluegill and Perch
- Consumed based on fishing skill (higher skill = less consumption)

**Worms (Universal):**
- Earthworms, Maggots
- Effective for most fish species
- Reliable all-around bait choice

**Minnows (Live Bait):**
- BaitFish, Tadpoles
- Preferred by predatory fish like Bass and Walleye
- Higher effectiveness than static baits

**Flesh (Scent Bait):**
- Meat, Fish Fillet, Dog food
- Excellent for Catfish species
- Provides hunger satisfaction when used

**Plant Matter:**
- Cheese, Corn, Bread, Dough
- Specialized for bottom feeders like Drum
- Catfish also respond well to plant baits

**Artificial Lures:**
- Jig Lure (rubber, mimics worms/leeches)
- Minnow Lure (plastic, mimics small fish)
- Don't provide hunger when used
- More durable than natural baits

### Lure Effectiveness Scale
- **1.0**: Excellent match (90% effectiveness)
- **0.7**: Good choice (70% effectiveness)  
- **0.5**: Average (50% effectiveness)
- **0.3**: Below average (30% effectiveness)
- **0.1**: Poor choice (10% effectiveness)
- **0.0**: No effect (fish won't bite)

## Equipment System

### Fishing Rods

**Crafted Fishing Rod:**
- Rod coefficient: 0.8 (less effective)
- Breaks into Wooden Stick when line snaps
- Beginner-friendly option

**Store-bought Fishing Rod:**
- Rod coefficient: 1.0 (standard effectiveness)
- Breaks into Fishing Rod Break item
- Better durability and performance

### Fishing Line

**Line Durability (damage per high-tension event):**
- Twine: 0.02 damage (weakest, 15 uses)
- Fishing Line: 0.013 damage (standard, ~23 uses)
- Premium Fishing Line: 0.007 damage (strongest, ~43 uses)

### Hooks

**Hook Effectiveness:**
- Paperclip: 0.8 coefficient (makeshift)
- Nails: 1.0 coefficient (functional)
- Fishing Hook: 1.2 coefficient (optimal)
- Forged/Bone Hooks: 1.2 coefficient (crafted alternatives)

## Environmental Factors

### Fish Abundance System

Fish abundance is calculated procedurally using:
- **Seed-based generation**: Daily changing fish locations
- **Base abundance**: 0-40 fish per point (modified by sandbox settings)
- **Zone depletion**: Catching fish reduces local abundance
- **Recovery time**: Zones recover fish over 5 days (7200 game minutes)

### Environmental Modifiers

**Temperature Effects:**
- Optimal: 15-30°C (1.0x modifier)
- Suboptimal: 0-15°C or 30-40°C (0.75x modifier)
- Poor: -10-0°C or 40°C+ (0.5x modifier)
- Terrible: Below -10°C (0.25x modifier)

**Weather Conditions:**
- Rain: 1.2x fish activity (fish bite more)
- Fog/Wind: 0.8x activity (reduced visibility/disturbance)
- Clear weather: 1.0x baseline activity

**Time of Day:**
- Dawn (4-6 AM): 1.2x activity
- Dusk (6-8 PM): 1.2x activity  
- Other times: 1.0x baseline

**Location Factors:**
- River vs. Lake: Some species prefer specific water types
- Near shore: 2x longer wait times, smaller fish
- Deep water: Better chance for larger fish
- Player proximity: Close players (< 3 tiles) triple wait times

### Noise and Disturbance

**Sound Effects:**
- Loud noises create 3-minute (180 game minutes) no-fish zones
- Affects both natural fish points and chum spots
- Radius scales with noise intensity

**Chum System:**
- Chum lasts 100 game minutes at full effectiveness
- Additional duration based on chum quality
- Creates temporary high-activity fishing spots
- Overrides some environmental penalties

## Skill Progression

### Fishing Skill Benefits

**Level 0-4 (Novice):**
- Can catch fish up to 1.4-2.3kg
- 95-60% chance for small fish
- Frequent bait/lure loss
- Basic fish size limits

**Level 5-7 (Competent):**
- Can catch fish up to 2.8-9kg  
- Reduced trash chance (20-40% less garbage)
- 48-25% chance for small fish
- Better bait conservation

**Level 8-10 (Expert):**
- Can catch massive fish up to 27-45kg
- 80% less trash than beginners
- 5% chance for legendary fish
- 20-10% chance for small fish
- Maximum fishing effectiveness

### Skill Size Limits (kg)

| Level | Max Fish Weight | Notable Species Available |
|-------|----------------|---------------------------|
| 0 | 1.4kg | Bluegill, small Perch |
| 1 | 1.5kg | Crappie, small Bass |
| 2 | 1.9kg | Sauger, medium Bass |
| 3 | 2.2kg | Smallmouth Bass |
| 4 | 2.3kg | Channel Catfish |
| 5 | 2.8kg | Largemouth Bass |
| 6 | 4.5kg | Freshwater Drum |
| 7 | 9kg | Walleye, Striped Bass |
| 8 | 27kg | Large Catfish, Paddlefish |
| 9 | 32kg | Blue Catfish |
| 10 | 45kg | Alligator Gar, massive fish |

### Experience Gain

**XP Formula:** `2 × Fish Length (cm)`
- Small fish (10-20cm): 20-40 XP
- Medium fish (30-50cm): 60-100 XP  
- Large fish (80-180cm): 160-360 XP
- Legendary fish provide maximum XP for their enhanced size

## Fishing Mechanics

### Casting and Bobber Physics

**Casting Accuracy:**
- Skill-based accuracy: `(ZombRand(3) - 1.5) / (skill + 1)`
- Higher skill = more precise casts
- 85-tick delay before bobber appears

**Bobber Movement:**
- Physics simulation with tension and fish forces
- Fish create movement: `±10 * fishSize / 1200` per update
- Tension pulls toward rod when line is tight
- Boundaries prevent movement onto land

### Fish Attraction System

**Nibble Time Calculation:**
```
Base chance = 1.0 × fishAbundance × temperature × weather × timeOfDay × 100

Wait times based on nibble chance:
- 0%: 2000 ticks (no fish)
- <40%: 1500 ticks (poor conditions)  
- <65%: 1000 ticks (average conditions)
- <80%: 650 ticks (good conditions)
- 80%+: 500 ticks (excellent conditions)
```

**Fish Attraction:**
```
Success chance = 0.8 × temperature × weather × time × hook × fishNumber
```

### Tension and Line Management

**Tension System:**
- Calculated as distance difference from optimal line length
- High tension (>0.8): Risk of line break or fish escape
- Low tension (<-0.8) with fish: Fish may escape
- Tension limits scale with rod quality and skill

**Line Breaking:**
- Occurs when tension exceeds `(120 + skillLevel × 10) × rodCoefficient`
- First-time fishers get 3x tension tolerance
- Random damage at high tension (10% chance per update)
- Line condition decreases with stress

### Catching Process

**Reeling Mechanics:**
- Mouse/gamepad controls for reel in/out
- Line movement coefficient builds with strength skill
- Optimal timing required to land fish successfully
- Predator fish require active reeling to catch

**Fish Behavior:**
- Small fish: Simple movement patterns
- Medium/Large fish: Complex evasion behaviors  
- Predatory fish: Must reel while nibbling to hook
- Trash items: Minimal resistance, easy to reel

## Multiplayer Synchronization

### Network Architecture

**Client-Server Model:**
- Server authoritative for fish generation and catching
- Clients handle UI, input, and visual feedback
- Bobber position synchronized between players

**Packet Types (FishingActionPacket.java):**
- `flagStartFishing` (1): Initialize fishing session
- `flagStopFishing` (2): End fishing session  
- `flagUpdateFish` (4): Fish caught/lost updates
- `flagUpdateBobberParameters` (8): Bobber position sync
- `flagCreateBobber` (16): Bobber spawn notification
- `flagDestroyBobber` (32): Bobber removal

### Data Synchronization

**Daily Fish Updates:**
- Fish school locations regenerated daily
- Seed distributed to all clients via `GameServer.transmitFishingData()`
- Chum points and noise zones synchronized
- Zone depletion tracked server-side

## Advanced Features

### Fishing Nets

**Deployable Nets:**
- Passive catching method requiring bait
- Can catch multiple fish types:
  - Without bait: BaitFish, Frogs, Mussels, Seaweed, Crayfish, Tadpoles
  - With bait: Additional Catfish species
- Alternative to active rod fishing

### Debug and Testing

**Admin Features:**
- Fishing zones visualization (F11 debug mode)
- Fish abundance overlays
- Chum point indicators  
- No-fish zone boundaries
- Fishing cheat mode for instant catches

**Debug Windows:**
- Real-time fishing data display
- Zone management tools
- Fish abundance monitoring
- Environmental factor display

## Technical Implementation

### File Structure

**Java Components:**
- `zombie/core/FishingAction.java` - Core action system
- `zombie/ai/states/FishingState.java` - Character state
- `zombie/iso/FishSchoolManager.java` - Fish abundance management
- `zombie/network/packets/FishingActionPacket.java` - Multiplayer sync

**Lua Components:**
- `shared/Fishing/Fish.lua` - Fish behavior and generation
- `shared/Fishing/FishingRod.lua` - Equipment mechanics  
- `shared/Fishing/fishing_properties.lua` - Species and equipment data
- `client/Fishing/FishingManager.lua` - UI and state management
- `shared/Fishing/Bobber.lua` - Physics simulation

### Performance Considerations

**Optimization Features:**
- Fish spawning limited to loaded chunks
- Visual splashes only near players
- Procedural generation reduces memory usage
- Network updates batched for efficiency

**Resource Management:**
- Fish abundance cached per zone
- Old fishing zones automatically cleaned up
- Bobber physics run only when active
- Sound effects localized to player vicinity

## Conclusion

Project Zomboid's fishing system represents a comprehensive simulation balancing realism with gameplay enjoyment. The system's depth includes 19 fish species, environmental factors, skill progression, equipment variety, and multiplayer support. The procedural fish abundance system ensures dynamic gameplay while the detailed lure/bait mechanics reward player knowledge and preparation.

The integration between Java engine performance and Lua script flexibility allows for both robust simulation and easy modding, making fishing a rich survival activity that scales from basic sustenance to advanced trophy hunting.