extends Area2D
class_name RoomTransition

@export var target_room: String = ""  # "kitchen" or "resto"
@export var target_position: Vector2 = Vector2(0, 0)  # Where player should appear in target room

var player_in_transition: bool = false
var transition_cooldown: float = 2.0  # Cooldown after transition to prevent immediate re-trigger
var time_since_last_transition: float = 999.0  # Start with high value so transitions work initially
var is_transitioning: bool = false  # Global flag to prevent multiple transitions

func _ready():
	add_to_group("room_transitions")
	
	# Enable monitoring
	monitoring = true
	monitorable = false
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Make sure collision is set up
	if not has_node("CollisionShape2D"):
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(4, 48)  # Very thin rectangle: 4px wide, 48px tall (almost as thin as roof)
		collision.shape = shape
		add_child(collision)
	
	# Set collision layers - Area2D should detect bodies on layer 1
	collision_layer = 0
	collision_mask = 1
	
	# Wait a bit before allowing transitions (prevents immediate trigger after scene change)
	await get_tree().create_timer(0.5).timeout

func _process(delta):
	time_since_last_transition += delta

func _on_body_entered(body):
	# Check if it's the player (by group or by checking if it has the player script)
	# Also check cooldown and global transition flag to prevent immediate re-triggering
	# IMPORTANT: Also check if player is visible - invisible players shouldn't trigger transitions
	if (body.is_in_group("player") or body.has_method("get_held_item")) and not player_in_transition and time_since_last_transition >= transition_cooldown and not is_transitioning:
		# Check if player is visible
		if "visible" in body and not body.visible:
			print("Player is invisible, ignoring transition")
			return
		
		print("Player entered transition area: ", target_room, " at position: ", global_position, " target_pos: ", target_position)
		player_in_transition = true
		time_since_last_transition = 0.0
		is_transitioning = true
		transition_player(body)

func _on_body_exited(body):
	if body.is_in_group("player") or body.has_method("get_held_item"):
		player_in_transition = false

func transition_player(player: Node):
	print("Transitioning player to: ", target_room)
	
	# Get or create scene manager
	var scene_manager = get_node_or_null("/root/SceneManager")
	if not scene_manager:
		# Create SceneManager directly
		scene_manager = Node.new()
		scene_manager.name = "SceneManager"
		scene_manager.set_script(load("res://scripts/scene_manager.gd"))
		get_tree().root.add_child(scene_manager)
		print("Created SceneManager")
	
	# Save player state
	var held_item = -1
	if player.has_method("get_held_item"):
		held_item = player.get_held_item()
	
	var direction = "none"
	if "current_dir" in player:
		direction = player.current_dir
	
	# Calculate exit direction - player continues in same direction they were going
	var exit_direction = direction
	
	var player_state = {
		"held_item": held_item,
		"position": player.global_position,
		"direction": exit_direction,  # Player will continue moving in same direction
		"exit_direction": exit_direction
	}
	
	print("Player state saved - held_item: ", player_state["held_item"])
	
	# Hide player immediately to prevent flashes
	player.visible = false
	
	# Transition to target room instantly
	scene_manager.transition_to_room(target_room, target_position, player_state)

func reset_cooldown():
	time_since_last_transition = 999.0  # Reset to allow transitions
