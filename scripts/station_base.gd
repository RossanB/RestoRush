extends Area2D
class_name StationBase

@export var station_type: String = ""  # "fridge", "cabinet", "cutting_board", "oven", "stove", "sink", "mixer"

func _ready():
	add_to_group("stations")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	pass

func _on_body_exited(body):
	pass

func interact(player: Node):
	pass



