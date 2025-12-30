# Room Transition System Setup

This system allows the player to seamlessly transition between the kitchen and restaurant rooms through holes in the roof, similar to Undertale.

## How It Works

1. **Room Transition Areas**: Place `RoomTransition.tscn` instances at the holes in the roof
2. **Automatic Detection**: When the player walks into a transition area, they automatically move to the other room
3. **State Preservation**: Player's inventory (held item) is preserved during transitions

## Setup Instructions

### Step 1: Add Transition Areas to Your Scenes

#### In `resto.tscn` (Restaurant):
1. Instance `RoomTransition.tscn` at the hole in the roof that leads to the kitchen
2. Set the transition properties:
   - **target_room**: `"kitchen"`
   - **target_position**: Set to where you want the player to appear in the kitchen (e.g., `Vector2(100, 50)`)
   - **transition_direction**: `"up"` (or the direction player is moving)

#### In `kitchen.tscn` (Kitchen):
1. Instance `RoomTransition.tscn` at the hole in the roof that leads back to the restaurant
2. Set the transition properties:
   - **target_room**: `"resto"`
   - **target_position**: Set to where you want the player to appear in the restaurant (e.g., `Vector2(19, 23)`)
   - **transition_direction**: `"down"` (or the direction player is moving)

### Step 2: Position the Transition Areas

- Place the transition areas at the exact location of the holes in the roof
- Make sure the collision shape covers the entire hole area
- You can adjust the size in the `RoomTransition.tscn` scene if needed

### Step 3: Test the Transitions

1. Run the game
2. Walk the player to a transition area
3. The player should automatically transition to the other room
4. The player's held item should be preserved

## Customization

### Adjusting Transition Area Size

Edit `RoomTransition.tscn`:
- Modify the `RectangleShape2D` size to match your hole size
- The default is 48x48 pixels

### Changing Transition Positions

In the Godot editor:
1. Select the `RoomTransition` node
2. In the Inspector, set `target_position` to where you want the player to appear
3. Make sure the position is in world coordinates

### Visual Debugging

The transition areas have a semi-transparent yellow sprite for debugging. You can:
- Hide the sprite by setting `modulate` alpha to 0
- Or remove the Sprite2D node entirely in production

## Technical Details

- **Scene Manager**: Automatically created when first transition occurs
- **Player State**: Saves held item, position, and direction
- **Scene Switching**: Uses `change_scene_to_file()` for seamless transitions
- **Camera**: Automatically updates to follow player in new room

## Troubleshooting

**Player doesn't transition:**
- Make sure the transition area has a `CollisionShape2D` with a shape
- Check that the player is in the "player" group
- Verify the `target_room` string matches exactly: "kitchen" or "resto"

**Player loses inventory:**
- Check that `player_state` is being saved correctly
- Make sure the player script has `add_to_group("player")` in `_ready()`

**Camera doesn't follow:**
- Ensure there's a Camera2D node in both scenes
- The camera should be a child of the scene root or follow the player

**Player appears in wrong position:**
- Adjust the `target_position` in the transition area's Inspector
- Make sure coordinates are in world space, not local



