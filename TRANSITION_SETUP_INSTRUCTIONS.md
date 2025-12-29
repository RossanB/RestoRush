# Room Transition Setup Instructions

## Door Location Found
Based on your debug output, the door/transition point is at:
- **Position**: X: -186, Y: 50
- **Scene**: resto.tscn (restaurant)

## Setup Steps

### Step 1: Add Transition to Restaurant Scene (resto.tscn)

1. Open `resto.tscn` in Godot
2. Instance the `RoomTransition.tscn` scene (drag it from FileSystem into the scene)
3. Position it at: **X: -186, Y: 50**
4. In the Inspector, set:
   - **target_room**: `"kitchen"` (lowercase, with quotes)
   - **target_position**: Set this to where you want the player to appear in the kitchen (you'll need to find the corresponding hole in the kitchen scene)

### Step 2: Find the Kitchen Door Location

1. Run the game and go to the kitchen scene
2. Walk to the hole in the roof that leads back to the restaurant
3. Note the X and Y coordinates from the debug output
4. That will be your `target_position` for the resto transition

### Step 3: Add Transition to Kitchen Scene (kitchen.tscn)

1. Open `kitchen.tscn` in Godot
2. Instance the `RoomTransition.tscn` scene
3. Position it at the hole location you found
4. In the Inspector, set:
   - **target_room**: `"resto"` (lowercase, with quotes)
   - **target_position**: `Vector2(-186, 50)` (the restaurant door location)

## Quick Setup (If you know the kitchen door position)

If you already know where the kitchen door is, you can set:
- **resto transition** → `target_position` = kitchen door position
- **kitchen transition** → `target_position` = Vector2(-186, 50)

## Testing

1. Run the game
2. Walk to X: -186, Y: 50 in the restaurant
3. You should automatically transition to the kitchen
4. Walk to the corresponding hole in the kitchen to return

## Visual Debug

The transition areas have a yellow semi-transparent sprite so you can see them. You can hide this later by:
- Setting the Sprite2D's `modulate` alpha to 0
- Or removing the Sprite2D node

