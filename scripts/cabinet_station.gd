extends StationBase

var item_selection_ui: Control = null

func _ready():
	super._ready()
	station_type = "cabinet"

func get_or_create_ui():
	if not item_selection_ui:
		item_selection_ui = preload("res://scenes/item_selection_ui.tscn").instantiate()
		get_tree().root.add_child(item_selection_ui)
		item_selection_ui.setup(Recipes.CABINET_ITEMS, self)
	return item_selection_ui

func interact(player: Node):
	if player.has_item():
		# Can't take items if already holding something
		return
	
	# Show item selection UI
	var ui = get_or_create_ui()
	if ui:
		ui.show_selection(Recipes.CABINET_ITEMS, player)

func give_item_to_player(player: Node, item_type: int):
	player.set_held_item(item_type)
