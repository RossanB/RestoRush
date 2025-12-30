extends StationBase

func _ready():
	super._ready()
	station_type = "sink"

func interact(player: Node):
	if player.has_item():
		# Can't get water if already holding something
		return
	
	# Give water to player
	AudioManager.play_faucet()
	player.set_held_item(ItemTypes.ItemType.WATER)



