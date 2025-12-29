extends Camera2D

@export var follow_player: bool = true
@export var follow_speed: float = 5.0
@export var smooth_follow: bool = true

var target_player: Node = null

func _ready():
	add_to_group("camera")
	find_player()

func _process(delta):
	if follow_player:
		if not target_player or not is_instance_valid(target_player):
			find_player()
		
		if target_player:
			if smooth_follow:
				global_position = global_position.lerp(target_player.global_position, follow_speed * delta)
			else:
				global_position = target_player.global_position

func find_player():
	target_player = get_tree().get_first_node_in_group("player")
	if not target_player:
		# Try alternative names
		target_player = get_tree().get_first_node_in_group("Player")

