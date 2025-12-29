extends Node

var player: Node = null
var debug_label: Label = null
var position_history: Array = []

func _ready():
	# Wait for scene to be ready before adding UI
	call_deferred("_setup_debug_label")
	
	print("Player Debug System Initialized")
	print("Press P to print current position to console")

func _setup_debug_label():
	# Create debug label
	debug_label = Label.new()
	debug_label.name = "PlayerDebugLabel"
	debug_label.add_theme_font_size_override("font_size", 20)
	debug_label.modulate = Color.YELLOW
	debug_label.position = Vector2(10, 10)
	debug_label.z_index = 1000
	debug_label.add_theme_color_override("font_color", Color.YELLOW)
	debug_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	debug_label.add_theme_constant_override("shadow_offset_x", 2)
	debug_label.add_theme_constant_override("shadow_offset_y", 2)
	# Add to root after scene is ready
	get_tree().root.add_child(debug_label)

var last_printed_pos: Vector2 = Vector2.ZERO
var print_interval: float = 0.5  # Print every 0.5 seconds
var time_since_last_print: float = 0.0

func _process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			# Try to find player by name
			var scene = get_tree().current_scene
			if scene:
				player = scene.get_node_or_null("Player")
	
	if player:
		var pos = player.global_position
		
		# Update debug label
		if debug_label:
			debug_label.text = "Player Position:\nX = " + str(int(pos.x)) + "\nY = " + str(int(pos.y))
			debug_label.visible = true
		
		# Print position to console continuously (every 0.5 seconds or when position changes significantly)
		time_since_last_print += delta
		var pos_changed = last_printed_pos.distance_to(pos) > 10.0
		
		if time_since_last_print >= print_interval or pos_changed:
			print("Player Position - X: ", int(pos.x), " | Y: ", int(pos.y), " | Scene: ", get_tree().current_scene.name if get_tree().current_scene else "Unknown")
			last_printed_pos = pos
			time_since_last_print = 0.0
		
		# Track position history (keep last 10 positions)
		if position_history.is_empty() or position_history[-1].distance_to(pos) > 5.0:
			position_history.append(pos)
			if position_history.size() > 10:
				position_history.pop_front()
	else:
		if debug_label:
			debug_label.text = "Player not found"
			debug_label.visible = true
	
	# Print detailed position when P is pressed
	if Input.is_action_just_pressed("ui_select") or Input.is_key_pressed(KEY_P):
		if player:
			var pos = player.global_position
			print("=== DETAILED PLAYER POSITION ===")
			print("X: ", int(pos.x), " | Y: ", int(pos.y))
			print("Global Position: ", pos)
			print("Scene: ", get_tree().current_scene.name if get_tree().current_scene else "Unknown")
			print("==============================")
