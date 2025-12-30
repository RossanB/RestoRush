extends StationBase

var stored_items: Array[int] = []
var is_processing: bool = false
var processing_time: float = 0.0
var processing_duration: float = 2.0  # 2 seconds to process
var progress_bar: Control = null

func _ready():
	super._ready()
	station_type = "cutting_board"
	create_progress_bar()

func _process(delta):
	if is_processing:
		processing_time += delta
		if progress_bar:
			progress_bar.set_progress(processing_time)
		
		if processing_time >= processing_duration:
			# Processing complete
			is_processing = false
			processing_time = 0.0
			if progress_bar:
				progress_bar.hide_progress()

func create_progress_bar():
	progress_bar = preload("res://scenes/progress_bar.tscn").instantiate()
	add_child(progress_bar)
	progress_bar.position = Vector2(-50, -40)
	progress_bar.set_max_progress(processing_duration)
	progress_bar.visible = false

func interact(player: Node):
	var held_item = player.get_held_item()
	
	# If player has an item, place it on the cutting board
	if held_item != -1:
		# Store the item
		stored_items.append(held_item)
		player.clear_item()
		print("Item placed on cutting board. Stored items: ", stored_items.size())
		return
	
	# Player has no item - try to process stored items
	if stored_items.is_empty():
		return
	
	# If already processing, can't interact
	if is_processing:
		return
	
	# Check if stored items match a recipe
	var recipe_check = RecipeChecker.check_recipe(stored_items, "cutting_board")
	
	if not recipe_check["success"]:
		# Recipe doesn't exist - show error
		ErrorMessage.show_error(recipe_check["error"])
		return
	
	# Recipe found - process it
	var result_item = recipe_check["result"]
	
	# Determine processing type based on result
	var process_type = "Processing..."
	if result_item == ItemTypes.ItemType.DOUGH:
		process_type = "Mixing..."
	elif can_chop_any_item():
		process_type = "Cutting..."
	elif can_assemble_any_item():
		process_type = "Assembling..."
	
	# Start processing
	is_processing = true
	processing_time = 0.0
	
	# Show progress bar
	if progress_bar:
		progress_bar.set_label_text(process_type)
		progress_bar.show_progress()
		progress_bar.set_progress(0.0)
	
	# Clear stored items
	stored_items.clear()
	
	# Wait for processing to complete
	await get_tree().create_timer(processing_duration).timeout
	
	# Give result to player
	if player and not player.has_item():
		player.set_held_item(result_item)
	
	is_processing = false
	if progress_bar:
		progress_bar.hide_progress()

func can_chop_any_item() -> bool:
	for item in stored_items:
		if can_chop(item):
			return true
	return false

func can_assemble_any_item() -> bool:
	for item in stored_items:
		if can_assemble(item):
			return true
	return false

func can_chop(item: int) -> bool:
	return item in [ItemTypes.ItemType.LETTUCE, ItemTypes.ItemType.TOMATO, ItemTypes.ItemType.MEAT, ItemTypes.ItemType.PEPPERONI, ItemTypes.ItemType.POTATO]

func can_assemble(item: int) -> bool:
	return item in [ItemTypes.ItemType.DOUGH, ItemTypes.ItemType.CHOPPED_LETTUCE, ItemTypes.ItemType.CHOPPED_TOMATO, ItemTypes.ItemType.CHOPPED_MEAT, ItemTypes.ItemType.CHOPPED_PEPPERONI, ItemTypes.ItemType.GLAZE]
