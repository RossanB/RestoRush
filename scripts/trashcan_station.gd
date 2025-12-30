extends StationBase

func _ready():
	super._ready()
	station_type = "trashcan"

func interact(player: Node):
	if not player.has_item():
		# Can't throw away nothing
		return
	
	# Discard the item the player is holding
	player.clear_item()
	print("Item discarded in trashcan")

