# Station Placement Guide

This guide explains how to place interactable stations (cabinets, stoves, ovens, etc.) in your scenes.

## How the Interaction System Works

1. **Stations are Area2D nodes** that extend `StationBase`
2. **Player detects nearby stations** within 50 pixels distance
3. **Press E key** to interact with the nearest station
4. **Stations must be in the "stations" group** (automatically added by `StationBase`)

## Available Station Scenes

All station scenes are in `scenes/` folder:
- `StationCabinet.tscn` - For getting flour, lettuce, tomato, potato
- `StationFridge.tscn` - For getting meat, egg, milk, cola, fruit, pepperoni, glaze
- `StationCuttingBoard.tscn` - For chopping, mixing, and assembling
- `StationOven.tscn` - For cooking taco and pizza
- `StationStove.tscn` - For frying fries and eggs
- `StationSink.tscn` - For getting water
- `StationMixer.tscn` - For mixing milk into icecream

## Step-by-Step: Placing a Station

### Method 1: Instance a Station Scene (Recommended)

1. **Open your scene** (e.g., `resto.tscn` or `kitchen.tscn`)

2. **In the Scene dock**, right-click on the root node (usually "Game" or "Game2")

3. **Select "Instance Child Scene"** (or press `Ctrl+Shift+A`)

4. **Browse to** `res://scenes/StationCabinet.tscn` (or any station you want)

5. **Click "Open"** - The station will appear in your scene

6. **Select the station node** in the Scene dock

7. **In the Inspector**, you'll see:
   - **Position**: Set X and Y to place it where you want
   - **Script variables**: The station type is set automatically

8. **Move the station** in the 2D viewport:
   - Click and drag the station node
   - Or set exact coordinates in the Inspector

9. **Adjust the CollisionShape2D** (optional):
   - Expand the station node in Scene dock
   - Select the `CollisionShape2D` child
   - In Inspector, you can adjust the `Shape` size
   - Default is 32x32 pixels - make it larger if needed

### Method 2: Create a New Station from Scratch

If you want to create a custom station:

1. **Add an Area2D node** to your scene

2. **Attach a script**:
   - Select the Area2D node
   - In Inspector, click the script icon (📄)
   - Choose "Load" and select a station script (e.g., `cabinet_station.gd`)
   - Or choose "New" and extend `StationBase`

3. **Add a CollisionShape2D child**:
   - Right-click the Area2D node → "Add Child Node"
   - Search for "CollisionShape2D"
   - Select it and press Enter

4. **Set up the CollisionShape2D**:
   - Select the CollisionShape2D node
   - In Inspector, under "Shape", click "New RectangleShape2D"
   - Set the size (e.g., `Vector2(32, 32)`)

5. **Configure collision layers**:
   - Select the Area2D (station) node
   - In Inspector, under "Collision":
     - **Collision Layer**: Set to `0` (stations don't collide with anything)
     - **Collision Mask**: Set to `1` (detect player on layer 1)
   - **Monitoring**: Should be `true` (checked)
   - **Monitorable**: Can be `false` (unchecked)

## Important Settings for Stations

### Area2D Settings:
- **Monitoring**: `true` ✓ (must be checked)
- **Monitorable**: `false` (optional, usually not needed)
- **Collision Layer**: `0` (stations don't need collision layers)
- **Collision Mask**: `1` (detect player on layer 1)

### CollisionShape2D Settings:
- **Shape**: RectangleShape2D (or CircleShape2D)
- **Size**: Adjust based on how large the interaction area should be
  - Default: `32x32` pixels
  - Larger stations: `64x64` or `48x48`
  - Make it match the visual size of your station sprite

## Visual Debugging

Stations have a semi-transparent colored sprite by default to help you see where they are:
- **Color**: Brown/orange tint
- **Opacity**: 50% (0.5 alpha)
- **Scale**: 2x (so 32x32 collision = 64x64 visual)

You can:
- **Hide the sprite** if you have your own station graphics
- **Adjust the color** to match your station
- **Remove the Sprite2D** node if not needed

## Testing Your Station

1. **Run the scene** (F5)

2. **Move the player** near the station (within 50 pixels)

3. **Press E** to interact

4. **Check the console** for any errors

## Common Issues

### Station not detecting player:
- Check that `Monitoring` is `true` on the Area2D
- Check that `Collision Mask` includes layer `1` (player's layer)
- Make sure player's `collision_layer` is set to `1`

### Station too small/large:
- Adjust the `CollisionShape2D` size in the Inspector
- The collision shape determines the interaction area

### Station in wrong position:
- Use the 2D viewport to drag it
- Or set exact coordinates in Inspector (Position → X, Y)

## Example: Placing a Cabinet in the Kitchen

1. Open `kitchen.tscn`
2. Instance `StationCabinet.tscn` as a child of the root node
3. Set position to `Vector2(100, 50)` (or wherever you want)
4. Run the scene and test with E key

## Tips

- **Group stations together** visually in the Scene dock for organization
- **Name your stations** clearly (e.g., "KitchenCabinet1", "RestoStove1")
- **Use snap to grid** (View → Snap to Grid) for alignment
- **Test frequently** to make sure interactions work

