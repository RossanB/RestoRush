extends CharacterBody2D

const SPEED = 150.0
const INTERACTION_DISTANCE = 30.0  # Distance to detect nearby stations

var current_dir = "none"
var held_item = -1  # -1 means no item (using int instead of enum for now)
var nearby_station: Node = null

signal item_changed(item_type)

func _ready():
	add_to_group("player")
	# Make sure player is on collision layer 1 so Area2D can detect it
	collision_layer = 1
	# Collision mask: 1 = TileMap physics and StaticBody2D walls on layer 1
	# If you added border collision shapes, make sure they're children of StaticBody2D nodes on collision layer 1
	collision_mask = 1
	$AnimatedSprite2D.play("front_idle")
	update_held_item_display()

func _physics_process(delta):
	player_movement(delta)
	check_nearby_stations()
	
	if Input.is_action_just_pressed("interact"):
		interact_with_station()

func player_movement(_delta):
	# Check for WASD or arrow keys (both work)
	var right = Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D)
	var left = Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A)
	var down = Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S)
	var up = Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W)
	
	if right:
		current_dir = "right"
		play_anim(1)
		velocity.x = SPEED
		velocity.y = 0
	elif left:
		current_dir = "left"
		play_anim(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif down:
		current_dir = "down"
		play_anim(1)
		velocity.x = 0
		velocity.y = +SPEED
	elif up:
		current_dir = "up"
		play_anim(1)
		velocity.x = 0
		velocity.y = -SPEED
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()
	
	# Clamp player position to prevent walking past boundaries
	# This is a backup if collision shapes aren't working
	# Adjust these values based on your scene boundaries
	# Allow extra space around door areas: resto door at (-162, 50), kitchen door at (231, 1)
	var min_x = -250  # Allow movement past -162 door
	var max_x = 500
	var min_y = -50
	var max_y = 200
	
	global_position.x = clamp(global_position.x, min_x, max_x)
	global_position.y = clamp(global_position.y, min_y, max_y)

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			anim.play("front_idle")
	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			anim.play("side_idle")

var previous_nearby_station: Node = null

func check_nearby_stations():
	var closest_station = null
	var closest_distance = INTERACTION_DISTANCE
	
	# Find all stations in the scene
	var stations = get_tree().get_nodes_in_group("stations")
	
	# Hide prompt on previous station
	if previous_nearby_station != nearby_station:
		if previous_nearby_station and previous_nearby_station.has_method("hide_interact_prompt"):
			previous_nearby_station.hide_interact_prompt()
	
	for station in stations:
		var distance = global_position.distance_to(station.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_station = station
	
	# Show prompt on new nearby station
	if closest_station != nearby_station:
		if closest_station and closest_station.has_method("show_interact_prompt"):
			closest_station.show_interact_prompt()
	
	previous_nearby_station = nearby_station
	nearby_station = closest_station
	
	# Hide prompt if no station nearby
	if nearby_station == null and previous_nearby_station:
		if previous_nearby_station.has_method("hide_interact_prompt"):
			previous_nearby_station.hide_interact_prompt()
		previous_nearby_station = null

func interact_with_station():
	if nearby_station == null:
		print("No nearby station to interact with")
		return
	
	print("Interacting with station: ", nearby_station.name, " type: ", nearby_station.station_type if "station_type" in nearby_station else "unknown")
	
	if nearby_station.has_method("interact"):
		nearby_station.interact(self)
	else:
		print("Station does not have interact method")

func set_held_item(item_type):
	held_item = item_type
	update_held_item_display()
	item_changed.emit(item_type)

func get_held_item():
	return held_item

func has_item() -> bool:
	return held_item != -1

func clear_item():
	held_item = -1
	update_held_item_display()
	item_changed.emit(-1)

func update_held_item_display():
	if not has_node("HeldItemSprite"):
		return
	
	var sprite = $HeldItemSprite
	if held_item == -1:
		sprite.visible = false
	else:
		sprite.visible = true
		var texture_path = ItemTypes.get_item_texture_path(held_item)
		if texture_path != "":
			var texture = load(texture_path)
			if texture:
				sprite.texture = texture
				sprite.position = Vector2(0, -25)
				sprite.z_index = 10
			
