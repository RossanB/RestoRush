# Inventory and Cooking System

## Overview
This system implements a single-slot inventory with visual item display on the player's head, along with interactive cooking stations for a Diner Dash/Overcooked style game.

## Features
- **Single-slot inventory**: Player can only hold one item at a time
- **Visual item display**: Held items appear above the player's head
- **Interactive stations**: Fridge, Cabinet, Cutting Board, Oven, Stove, Sink, Mixer
- **Pixel-style inventory UI**: Select items from fridge and cabinet
- **Recipe system**: All foods from your list are implemented

## Controls
- **Arrow Keys**: Move player
- **E Key**: Interact with nearby station
- **ESC**: Close item selection UI

## Adding Stations to Your Scene

1. **Fridge Station**: 
   - Instance `StationFridge.tscn` in your scene
   - Position it where you want the fridge
   - Items available: Meat, Egg, Milk, Cola, Fruit, Pepperoni, Glaze

2. **Cabinet Station**:
   - Instance `StationCabinet.tscn` in your scene
   - Position it where you want the cabinet
   - Items available: Flour, Lettuce, Tomato, Potato

3. **Cutting Board**:
   - Instance `StationCuttingBoard.tscn` in your scene
   - Used for: Chopping, mixing dough, assembling foods

4. **Oven**:
   - Instance `StationOven.tscn` in your scene
   - Used for: Cooking Taco and Pizza

5. **Stove**:
   - Instance `StationStove.tscn` in your scene
   - Used for: Frying Fries and Eggs

6. **Sink**:
   - Instance `StationSink.tscn` in your scene
   - Gives: Water

7. **Mixer**:
   - Instance `StationMixer.tscn` in your scene
   - Used for: Mixing Milk into Icecream

## Recipes

### TACO (Hard Food)
1. Get Flour from cabinet
2. Get Water from sink
3. Mix Flour + Water on cutting board → Dough
4. Get Lettuce from cabinet
5. Chop Lettuce on cutting board → Chopped Lettuce
6. Get Meat from fridge
7. Chop Meat on cutting board → Chopped Meat
8. Get Tomato from cabinet
9. Chop Tomato on cutting board → Chopped Tomato
10. Assemble Dough + Chopped Lettuce + Chopped Meat + Chopped Tomato on cutting board → Taco
11. Cook Taco in oven

### FRIES (Easy Food)
1. Get Potato from cabinet
2. Chop Potato on cutting board → Uncut Fries
3. Fry Uncut Fries on stove → Fries

### PIZZA (Easy Food)
1. Get Flour from cabinet
2. Get Water from sink
3. Mix Flour + Water on cutting board → Dough
4. Get Pepperoni from fridge
5. Chop Pepperoni on cutting board → Chopped Pepperoni
6. Assemble Dough + Chopped Pepperoni on cutting board → Pizza
7. Cook Pizza in oven

### SUNNY SIDEUP EGG (Easy Food)
1. Get Egg from fridge
2. Fry Egg on stove → Sunny Sideup Egg

### ICECREAM (Easy Food)
1. Get Milk from fridge
2. Mix Milk in mixer → Icecream
3. Store Icecream in fridge (optional)

### DRINKS
- **Cola**: Get from fridge
- **Fruit**: Get from fridge

### DONUTS (Easy Food)
1. Get Flour from cabinet
2. Get Water from sink
3. Mix Flour + Water on cutting board → Dough
4. Get Glaze from fridge
5. Assemble Dough + Glaze on cutting board → Donuts

## Technical Details

### Item System
- All items are defined in `item_types.gd` as an enum
- Item textures are loaded from `assets/environment/ingredients/`
- Each item has a name and texture path

### Player Inventory
- Player script (`player.gd`) manages the single-slot inventory
- `HeldItemSprite` node displays the item above player's head
- Items are positioned at `Vector2(0, -25)` relative to player

### Station Interaction
- Stations use `Area2D` nodes with collision detection
- Player checks for nearby stations within `INTERACTION_DISTANCE` (50 pixels)
- Press E to interact with the nearest station

### Item Selection UI
- Pixel-style UI appears when interacting with Fridge or Cabinet
- Shows available items in a grid
- Click an item to pick it up
- Press ESC or Close button to cancel

## Notes
- The player can only hold one item at a time
- You must drop/use an item before picking up another
- Cutting board can store multiple items temporarily for assembly
- All stations are automatically added to the "stations" group for detection



