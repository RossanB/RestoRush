# Interaction System Quick Reference

## Controls
- **WASD** or **Arrow Keys**: Move player
- **E Key**: Interact with nearest station (within 50 pixels)

## How It Works

1. **Player** checks for stations in the "stations" group every frame
2. Finds the **closest station** within 50 pixels
3. When you press **E**, calls that station's `interact()` method
4. Each station type has its own interaction logic

## Station Structure

Every station is an **Area2D** node with:
- **Script**: Extends `StationBase` (e.g., `cabinet_station.gd`)
- **CollisionShape2D child**: Defines the interaction area
- **In "stations" group**: Automatically added by `StationBase._ready()`

## Station Settings Checklist

When placing a station, make sure:

- ✅ **Area2D → Monitoring**: `true`
- ✅ **Area2D → Collision Mask**: Includes layer `1` (player's layer)
- ✅ **CollisionShape2D**: Has a shape assigned (RectangleShape2D or CircleShape2D)
- ✅ **Position**: Set to where you want the station in the scene

## Station Types & What They Do

| Station | Scene File | Items/Function |
|--------|-----------|----------------|
| **Cabinet** | `StationCabinet.tscn` | Flour, Lettuce, Tomato, Potato |
| **Fridge** | `StationFridge.tscn` | Meat, Egg, Milk, Cola, Fruit, Pepperoni, Glaze |
| **Sink** | `StationSink.tscn` | Water |
| **Cutting Board** | `StationCuttingBoard.tscn` | Chop, Mix, Assemble |
| **Oven** | `StationOven.tscn` | Cook Taco, Pizza |
| **Stove** | `StationStove.tscn` | Fry Fries, Eggs |
| **Mixer** | `StationMixer.tscn` | Mix Milk → Icecream |

## Quick Placement Steps

1. Open your scene (`resto.tscn` or `kitchen.tscn`)
2. Right-click root node → **Instance Child Scene**
3. Select a station scene (e.g., `StationCabinet.tscn`)
4. Position it where you want (drag or set X/Y in Inspector)
5. Run and test with **E key**

See `STATION_PLACEMENT_GUIDE.md` for detailed instructions.

