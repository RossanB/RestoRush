extends Node

var player_state: Dictionary = {}
var is_transitioning: bool = false

func transition_to_room(room_name: String, target_position: Vector2, state: Dictionary):
	if is_transitioning:
		print("Already transitioning, ignoring request")
		return
	
	is_transitioning = true
	
	# Save player state
	player_state = state.duplicate()
	player_state["target_position"] = target_position
	print("SceneManager: Transitioning to ", room_name, " at position: ", target_position)
	
	# Change scene
	var scene_path = ""
	if room_name == "kitchen":
		scene_path = "res://scenes/kitchen.tscn"
	else:
		scene_path = "res://scenes/resto.tscn"
	
	print("Changing scene to: ", scene_path)
	
	# Use call_deferred to change scene after current frame
	call_deferred("_change_scene", scene_path)

func _change_scene(scene_path: String):
	# Ensure we fully change the scene (not add to it)
	get_tree().change_scene_to_file(scene_path)
	
	# Wait for scene to load, then restore player immediately
	await get_tree().process_frame
	restore_player_state()

func restore_player_state():
	# Wait one more frame to ensure scene is fully loaded
	await get_tree().process_frame
	
	# Find player immediately
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		# Try to find player by name
		var scene = get_tree().current_scene
		if scene:
			player = scene.get_node_or_null("Player")
	
	if not player:
		print("ERROR: Could not find player in scene!")
		return
	
	print("Found player at initial position: ", player.global_position)
	
	# Stop player movement during transition FIRST
	player.velocity = Vector2.ZERO
	player.current_dir = "none"
	
	# Hide player immediately to prevent flashes
	player.visible = false
	
	# Get target position - it should always be in player_state
	var target_pos: Vector2
	if "target_position" in player_state:
		target_pos = player_state["target_position"]
		print("Target position from state: ", target_pos)
	else:
		print("ERROR: No target_position in player_state! Using defaults.")
		# Use default position based on scene
		var scene_name = get_tree().current_scene.name if get_tree().current_scene else ""
		if "kitchen" in scene_name.to_lower():
			target_pos = Vector2(231, 1)  # Kitchen door position
		else:
			target_pos = Vector2(-162, 50)  # Resto door position
	
	# Make sure we're not placing player at (0,0) which might be a transition area
	if target_pos == Vector2(0, 0) or target_pos.length() < 1.0:
		# Use default safe position based on scene
		var scene_name = get_tree().current_scene.name if get_tree().current_scene else ""
		if "kitchen" in scene_name.to_lower():
			target_pos = Vector2(231, 1)  # Kitchen door position
		else:
			target_pos = Vector2(-162, 50)  # Resto door position
		print("Warning: Target position was invalid, using safe default: ", target_pos)
	
	# Position player immediately BEFORE making visible
	player.global_position = target_pos
	print("Player positioned at: ", player.global_position)
	
	# Restore held item
	if "held_item" in player_state:
		var held_item = player_state["held_item"]
		if held_item != -1 and player.has_method("set_held_item"):
			player.set_held_item(held_item)
		elif player.has_method("clear_item"):
			player.clear_item()
	
	# Set player direction
	if "exit_direction" in player_state:
		var exit_dir = player_state["exit_direction"]
		if exit_dir != "none" and "current_dir" in player:
			player.current_dir = exit_dir
	elif "direction" in player_state and "current_dir" in player:
		player.current_dir = player_state["direction"]
	
	# Make player visible after positioning - ALWAYS make visible
	player.visible = true
	print("Player made visible at position: ", player.global_position, " visible: ", player.visible)
	
	# Reset flags immediately to allow new transitions
	is_transitioning = false
	
	# Get transitions and reset their flags
	var transitions = get_tree().get_nodes_in_group("room_transitions")
	for transition in transitions:
		# RoomTransition class has these properties, so we can access them directly
		if transition is RoomTransition:
			transition.is_transitioning = false
			transition.player_in_transition = false
			if transition.has_method("reset_cooldown"):
				transition.reset_cooldown()
		# Disable monitoring temporarily to prevent immediate re-trigger
		if transition is Area2D:
			transition.monitoring = false
	
	# Re-enable transitions after a brief delay to prevent immediate re-trigger
	await get_tree().create_timer(0.5).timeout
	transitions = get_tree().get_nodes_in_group("room_transitions")
	for transition in transitions:
		if transition is Area2D:
			transition.monitoring = true
	
	# Camera should not follow player - leave it at its initial position
