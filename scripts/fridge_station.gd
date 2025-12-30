extends StationBase

var item_selection_ui: CanvasLayer = null
var freezing_items: Dictionary = {}  # item_id -> {time: float, duration: float, result: int}
var progress_bar: Control = null

func _ready():
	super._ready()
	station_type = "fridge"
	create_progress_bar()

func _process(delta):
	# Update freezing progress
	for item_id in freezing_items.keys():
		var item_data = freezing_items[item_id]
		item_data.time += delta
		
		if progress_bar and progress_bar.visible:
			progress_bar.set_progress(item_data.time)
		
		if item_data.time >= item_data.duration:
			# Freezing complete - item is ready
			freezing_items.erase(item_id)
			if progress_bar:
				progress_bar.hide_progress()

func create_progress_bar():
	progress_bar = preload("res://scenes/progress_bar.tscn").instantiate()
	add_child(progress_bar)
	progress_bar.position = Vector2(-50, -40)
	progress_bar.set_max_progress(5.0)  # 5 seconds to freeze
	progress_bar.visible = false

func get_or_create_ui():
	if not item_selection_ui:
		item_selection_ui = preload("res://scenes/item_selection_ui.tscn").instantiate()
		get_tree().root.add_child(item_selection_ui)
		item_selection_ui.setup(Recipes.FRIDGE_ITEMS, self)
	return item_selection_ui

func interact(player: Node):
	var held_item = player.get_held_item()
	
	# If player has icecream (mixed milk), they can freeze it
	if held_item == ItemTypes.ItemType.ICECREAM:
		# Start freezing process
		var item_id = str(get_instance_id()) + "_freeze"
		freezing_items[item_id] = {
			"time": 0.0,
			"duration": 5.0,  # 5 seconds to freeze
			"result": ItemTypes.ItemType.ICECREAM,
			"player": player
		}
		
		# Show progress bar
		if progress_bar:
			progress_bar.set_label_text("Freezing...")
			progress_bar.set_max_progress(5.0)
			progress_bar.show_progress()
			progress_bar.set_progress(0.0)
		
		player.clear_item()
		
		# Wait for freezing to complete
		await get_tree().create_timer(5.0).timeout
		
		# Give frozen icecream to player
		if player and not player.has_item():
			player.set_held_item(ItemTypes.ItemType.ICECREAM)
		
		if progress_bar:
			progress_bar.hide_progress()
		
		if item_id in freezing_items:
			freezing_items.erase(item_id)
		return
	
	if player.has_item():
		# Can't take items if already holding something
		return
	
	# Show item selection UI
	var ui = get_or_create_ui()
	if ui:
		ui.show_selection(Recipes.FRIDGE_ITEMS, player)

func give_item_to_player(player: Node, item_type: int):
	player.set_held_item(item_type)

