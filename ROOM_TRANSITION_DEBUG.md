# Room Transition Debugging Guide

If the player can't pass through the door/transition area, check these:

## Common Issues

### 1. Transition Area Not Detecting Player

**Check:**
- Is the `RoomTransition` node positioned at the hole in the roof?
- Is the collision shape large enough? (Default is 48x48 pixels)
- Is `monitoring` set to `true` on the Area2D?

**Fix:**
- In Godot editor, select the RoomTransition node
- Check that `Monitoring` is enabled in the Inspector
- Check that `Collision Mask` has layer 1 checked (to detect CharacterBody2D)

### 2. Player Not in Correct Group

**Check:**
- Open the Player script and verify `add_to_group("player")` is in `_ready()`
- Check the Output panel for "Player entered transition area" message

**Fix:**
- The player script should have `add_to_group("player")` in `_ready()`

### 3. Collision Layers Not Set

**Check:**
- Player (CharacterBody2D) should be on collision layer 1
- RoomTransition (Area2D) should have collision_mask = 1

**Fix:**
- Player: Set `collision_layer = 1` in `_ready()`
- RoomTransition: Already set in the scene file

### 4. Transition Area Position

**Check:**
- Is the transition area positioned exactly where the hole is?
- Is it at the right Z-index/height?

**Fix:**
- Move the transition area to match the hole position
- Make sure it's at the same Y position as the player can reach

### 5. Target Room/Position Not Set

**Check:**
- In Inspector, is `target_room` set to "kitchen" or "resto"?
- Is `target_position` set to a valid position?

**Fix:**
- Set `target_room` to exactly "kitchen" or "resto" (lowercase)
- Set `target_position` to where you want player to appear (e.g., Vector2(100, 50))

## Debug Steps

1. **Check Console Output:**
   - When player enters transition area, you should see: "Player entered transition area: kitchen" (or resto)
   - If you don't see this, the Area2D isn't detecting the player

2. **Visual Debug:**
   - The transition area has a yellow semi-transparent sprite
   - Make sure you can see it at the hole location
   - If you can't see it, the node might not be in the scene

3. **Test Collision:**
   - Temporarily make the sprite more visible (increase alpha)
   - Walk player directly into the center of the yellow area
   - Check console for messages

4. **Check Scene Manager:**
   - After transition, check if SceneManager was created
   - Look for "Created SceneManager" in console

## Quick Fix Checklist

- [ ] RoomTransition node is in the scene
- [ ] RoomTransition is positioned at the hole
- [ ] `monitoring = true` on Area2D
- [ ] `collision_mask = 1` on Area2D
- [ ] Player has `add_to_group("player")`
- [ ] Player has `collision_layer = 1`
- [ ] `target_room` is set correctly
- [ ] `target_position` is set correctly

## Manual Test

To test if the transition script works:
1. Select the RoomTransition node in the scene
2. In the Inspector, find the script variables
3. Make sure `target_room` and `target_position` are set
4. Run the game and walk player into the yellow area
5. Check console for debug messages



