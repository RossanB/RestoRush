extends Node

var player_state: Dictionary = {}
var is_transitioning: bool = false
var customer_states: Array[Dictionary] = []  # Save customer states across scenes
var table_states: Dictionary = {}  # Save table occupancy states
var customer_spawn_timer: float = 0.0  # Persist spawn timer across scenes
var time_left_restaurant: float = 0.0  # Timestamp when player left restaurant (for timer continuation)

func transition_to_room(room_name: String, target_position: Vector2, state: Dictionary):
	if is_transitioning:
		print("Already transitioning, ignoring request")
		return
	
	is_transitioning = true
	
	# Save player state
	player_state = state.duplicate()
	player_state["target_position"] = target_position
	print("SceneManager: Transitioning to ", room_name, " at position: ", target_position)
	
	# Save customer states if leaving restaurant
	if room_name == "kitchen":
		# Save timestamp when leaving restaurant (for timer continuation)
		time_left_restaurant = Time.get_ticks_msec() / 1000.0  # Convert to seconds
		print("SceneManager: Saved time when leaving restaurant: ", time_left_restaurant)
		
		# Save spawn timer from CustomerManager
		var customer_manager = get_tree().get_first_node_in_group("customer_manager")
		if customer_manager and "spawn_timer" in customer_manager:
			customer_spawn_timer = customer_manager.spawn_timer
			print("SceneManager: Saved spawn timer: ", customer_spawn_timer)
		
		# Hide customers before saving (so they don't appear during transition)
		var customers = get_tree().get_nodes_in_group("customers")
		for customer in customers:
			if customer.has_method("set_visible"):
				customer.visible = false
		save_customer_states()
	
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
	
	# Wait for scene to load
	await get_tree().process_frame
	
	# Restore customers FIRST if returning to restaurant (before player)
	var scene_name = get_tree().current_scene.name if get_tree().current_scene else ""
	if "resto" in scene_name.to_lower() or scene_name == "Game":
		# Calculate elapsed time while player was in kitchen
		var elapsed_time: float = 0.0
		if time_left_restaurant > 0.0:
			var current_time = Time.get_ticks_msec() / 1000.0
			elapsed_time = current_time - time_left_restaurant
			print("SceneManager: Elapsed time while in kitchen: ", elapsed_time, " seconds")
			time_left_restaurant = 0.0  # Reset
		
		# Restore spawn timer to CustomerManager
		var customer_manager = get_tree().get_first_node_in_group("customer_manager")
		if customer_manager and "spawn_timer" in customer_manager:
			customer_manager.spawn_timer = customer_spawn_timer
			print("SceneManager: Restored spawn timer: ", customer_spawn_timer)
		
		if customer_states.size() > 0:
			# Try to find CustomerManager immediately
			if customer_manager and customer_manager.has_method("restore_customers"):
				print("SceneManager: Restoring customers immediately after scene load")
				customer_manager.restore_customers(customer_states, table_states, elapsed_time)
				customer_states.clear()
				table_states.clear()
	
	# Then restore player
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
			target_pos = Vector2(226, 35)  # Resto player start position (moved down to avoid customers)
	
	# Make sure we're not placing player at (0,0) which might be a transition area
	if target_pos == Vector2(0, 0) or target_pos.length() < 1.0:
		# Use default safe position based on scene
		var scene_name = get_tree().current_scene.name if get_tree().current_scene else ""
		if "kitchen" in scene_name.to_lower():
			target_pos = Vector2(231, 1)  # Kitchen door position
		else:
			target_pos = Vector2(226, 35)  # Resto player start position (moved down to avoid customers)
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
	
	# Customers should already be restored by now (in _change_scene)
	# This is just a fallback in case it didn't happen
	var scene_name = get_tree().current_scene.name if get_tree().current_scene else ""
	if "resto" in scene_name.to_lower() or scene_name == "Game":
		if customer_states.size() > 0:
			print("SceneManager: Fallback - restoring customers that weren't restored earlier")
			restore_customer_states()
	
	# Re-enable transitions after a brief delay to prevent immediate re-trigger
	await get_tree().create_timer(0.5).timeout
	transitions = get_tree().get_nodes_in_group("room_transitions")
	for transition in transitions:
		if transition is Area2D:
			transition.monitoring = true
	
	# Camera should not follow player - leave it at its initial position

func save_customer_states():
	customer_states.clear()
	table_states.clear()
	
	var customers = get_tree().get_nodes_in_group("customers")
	print("SceneManager: Found ", customers.size(), " customers to save")
	
	for customer in customers:
		if customer.has_method("get_customer_state"):
			var state = customer.get_customer_state()
			customer_states.append(state)
			print("SceneManager: Saved customer state - table: ", state.get("table_id", "none"), " state: ", state.get("customer_state", -1))
		else:
			print("SceneManager: Customer missing get_customer_state method: ", customer.name)
	
	# Save table states
	var tables = get_tree().get_nodes_in_group("tables")
	for table in tables:
		if table.has_method("get_table_state"):
			var table_id = table.name  # Use table name as identifier
			table_states[table_id] = table.get_table_state()
	
	print("SceneManager: Saved ", customer_states.size(), " customer states and ", table_states.size(), " table states")

func restore_customer_states():
	if customer_states.is_empty():
		print("No customer states to restore")
		return
	
	var customer_manager = get_tree().get_first_node_in_group("customer_manager")
	if not customer_manager:
		print("No customer manager found, cannot restore customers")
		return
	
	# Tell customer manager to restore instead of spawn
	# Calculate elapsed time (if we have a saved timestamp)
	var elapsed_time: float = 0.0
	if time_left_restaurant > 0.0:
		var current_time = Time.get_ticks_msec() / 1000.0
		elapsed_time = current_time - time_left_restaurant
		time_left_restaurant = 0.0  # Reset
	
	if customer_manager.has_method("restore_customers"):
		customer_manager.restore_customers(customer_states, table_states, elapsed_time)
		customer_states.clear()  # Clear after restoring
		table_states.clear()
		print("Restored customers from saved state")
