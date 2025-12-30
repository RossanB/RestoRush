# How to Add Stations to Your Scene - Step by Step

## Method 1: Drag and Drop (Easiest!)

1. **Open your scene** (double-click `resto.tscn` or `kitchen.tscn` in the FileSystem dock)

2. **In the FileSystem dock** (bottom-left), navigate to `scenes/` folder

3. **Find a station scene** (e.g., `StationCabinet.tscn`)

4. **Drag the station scene file** from FileSystem dock

5. **Drop it** onto your scene in the 2D viewport (the main editing area) OR drop it onto the root node in the Scene dock (left side)

6. **Done!** The station will appear in your scene

7. **Move it** by clicking and dragging in the 2D viewport, or set exact position in Inspector (right side)

## Method 2: Using the Scene Dock Menu

1. **Open your scene** (`resto.tscn` or `kitchen.tscn`)

2. **Look at the Scene dock** (left side of the screen) - this shows all nodes in your scene

3. **Find the root node** - it's usually named "Game" or "Game2" and is at the top of the tree

4. **Right-click on that root node** (the one at the top)

5. **In the menu that appears**, look for **"Instance Child Scene"** or **"Change Scene Type"** → **"Instance Child Scene"**

6. **A file browser will open** - navigate to `scenes/` folder and select a station (e.g., `StationCabinet.tscn`)

7. **Click "Open"** - The station will be added as a child of the root node

8. **Move it** to where you want it

## Method 3: Using the + Button

1. **Open your scene**

2. **In the Scene dock**, click the **"+" button** at the top (or press `Ctrl+A`)

3. **In the "Create Node" dialog**, click **"Instance Child Scene"** button at the top

4. **Select a station scene** from the file browser

5. **Click "Open"**

## What is the "Root Node"?

The **root node** is the top-most node in your scene. In the Scene dock, it's the first item in the tree. It's usually named:
- "Game" (in resto.tscn)
- "Game2" (in kitchen.tscn)
- Or whatever you named your main scene node

All other nodes (Player, stations, etc.) are children of this root node.

## Visual Guide

```
Scene Dock (Left Side):
┌─────────────────────┐
│ Game (root node)    │ ← This is the root node
│ ├─ Player           │
│ ├─ TileMap         │
│ └─ Camera2D         │
└─────────────────────┘
```

When you add a station, it becomes:
```
┌─────────────────────┐
│ Game (root node)    │
│ ├─ Player           │
│ ├─ TileMap         │
│ ├─ Camera2D         │
│ └─ CabinetStation   │ ← New station added here
└─────────────────────┘
```

## Quick Steps Summary

**Easiest way:**
1. Open scene
2. Drag `StationCabinet.tscn` from FileSystem dock
3. Drop it in the 2D viewport
4. Move it where you want
5. Done!

## Troubleshooting

**Can't find "Instance Child Scene"?**
- Try Method 1 (drag and drop) instead - it's easier!

**Station not appearing?**
- Make sure you dropped it in the 2D viewport or on the root node
- Check the Scene dock to see if it was added

**Station in wrong place?**
- Click the station in Scene dock
- In Inspector (right side), set Position → X and Y values
- Or drag it in the 2D viewport

## Example: Adding a Cabinet to Kitchen

1. Open `kitchen.tscn`
2. In FileSystem dock, go to `scenes/` folder
3. Drag `StationCabinet.tscn` into the 2D viewport
4. Position it where you want (e.g., X: 100, Y: 50)
5. Press F5 to test - walk near it and press E!

