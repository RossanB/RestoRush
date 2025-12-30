# How to Adjust Interaction Area Size

There are two ways to control how close the player needs to be to interact with stations:

## Method 1: Change Interaction Distance (Recommended)

This controls how close the player must be to interact. This affects ALL stations.

**File:** `scripts/player.gd`

**Current setting:**
```gdscript
const INTERACTION_DISTANCE = 50.0
```

**To make it smaller:**
```gdscript
const INTERACTION_DISTANCE = 30.0  # Player must be within 30 pixels
```

**To make it larger:**
```gdscript
const INTERACTION_DISTANCE = 80.0  # Player can be up to 80 pixels away
```

**Steps:**
1. Open `scripts/player.gd`
2. Find line 4: `const INTERACTION_DISTANCE = 50.0`
3. Change the number (e.g., `30.0` for smaller, `80.0` for larger)
4. Save and test

## Method 2: Change CollisionShape2D Size (Per Station)

This changes the visual/interaction area size for individual stations. This is useful if you want different stations to have different interaction areas.

### For a Single Station Instance:

1. **Open your scene** (e.g., `resto.tscn` or `kitchen.tscn`)

2. **In the Scene dock**, find your station (e.g., `CabinetStation`)

3. **Expand the station node** (click the arrow) to see its children

4. **Select the `CollisionShape2D` child**

5. **In the Inspector** (right side), find the **"Shape"** property

6. **Click on the shape** (e.g., "RectangleShape2D")

7. **Change the "Size"** property:
   - Current: `Vector2(32, 32)` (32 pixels wide, 32 pixels tall)
   - Smaller: `Vector2(16, 16)` (16x16 pixels)
   - Even smaller: `Vector2(8, 8)` (8x8 pixels)
   - Larger: `Vector2(48, 48)` (48x48 pixels)

8. **Save the scene**

### For All Stations of a Type:

If you want to change the size for ALL cabinets (or all fridges, etc.):

1. **Open the station scene file** (e.g., `scenes/StationCabinet.tscn`)

2. **Select the `CollisionShape2D` node**

3. **In Inspector**, change the **"Shape" → "Size"**

4. **Save the scene file**

5. **All instances** of that station will now use the new size

## Understanding the Two Settings

- **INTERACTION_DISTANCE**: How far away the player can be (measured from player center to station center)
  - This is the main control for interaction range
  - Smaller = player must be closer
  - Larger = player can be farther away

- **CollisionShape2D Size**: The visual/interaction area of the station
  - This is mainly visual (the colored rectangle you see)
  - Doesn't directly affect interaction distance, but helps you see where the station is
  - Can be useful for fine-tuning individual stations

## Recommended Settings

**For tighter, more precise interactions:**
- `INTERACTION_DISTANCE = 25.0` or `30.0`
- `CollisionShape2D size = Vector2(16, 16)` or `Vector2(24, 24)`

**For easier, more forgiving interactions:**
- `INTERACTION_DISTANCE = 60.0` or `70.0`
- `CollisionShape2D size = Vector2(48, 48)` or `Vector2(64, 64)`

**Default (current):**
- `INTERACTION_DISTANCE = 50.0`
- `CollisionShape2D size = Vector2(32, 32)`

## Quick Example: Make Interaction Smaller

**To make all stations require closer interaction:**

1. Open `scripts/player.gd`
2. Change line 4 to: `const INTERACTION_DISTANCE = 30.0`
3. Save
4. Test - player must now be closer to interact

**To make a specific station have a smaller visual area:**

1. Open your scene (`resto.tscn` or `kitchen.tscn`)
2. Select the station → `CollisionShape2D` child
3. In Inspector, change Shape → Size to `Vector2(16, 16)`
4. Save scene
5. Test

## Visual Guide

The semi-transparent colored rectangle you see on stations is the CollisionShape2D. Making it smaller makes the visual area smaller, but the actual interaction distance is controlled by `INTERACTION_DISTANCE` in `player.gd`.

