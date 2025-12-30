extends StationBase

var stored_items: Array[int] = []
var is_processing: bool = false
var processing_time: float = 0.0
var processing_duration: float = 2.0  # 2 seconds to process
var progress_bar: Control = null
var processing_ui: CanvasLayer = null

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
	
	# Player has no item - show processing UI
	if stored_items.is_empty():
		return
	
	# If already processing, can't interact
	if is_processing:
		return
	
	# Determine what action button to show based on stored items
	var button_text = "Process"
	# Check if we can determine the action from stored items
	var recipe_check = RecipeChecker.check_recipe(stored_items, "cutting_board")
	if recipe_check["success"]:
		var result_item = recipe_check["result"]
		if result_item == ItemTypes.ItemType.DOUGH:
			button_text = "Mix"
		elif can_chop_any_item():
			button_text = "Chop"
		elif can_assemble_any_item():
			button_text = "Assemble"
	else:
		# Can't determine, but still show UI so player can try
		if can_chop_any_item():
			button_text = "Chop"
		elif can_assemble_any_item():
			button_text = "Assemble"
	
	# Show processing UI
	get_or_create_processing_ui()
	processing_ui.show_processing(stored_items, self, player, button_text)

func get_or_create_processing_ui():
	if not processing_ui:
		processing_ui = preload("res://scenes/processing_ui.tscn").instantiate()
		get_tree().root.add_child(processing_ui)
	return processing_ui

func process_items(player: Node):
	# Called from processing UI when button is pressed
	if stored_items.is_empty() or is_processing:
		return
	
	# Debug: Print stored items
	print("Cutting board stored items: ", stored_items)
	for item in stored_items:
		print("  - Item: ", ItemTypes.get_item_name(item), " (", item, ")")
	
	# Check if stored items match a recipe
	var recipe_check = RecipeChecker.check_recipe(stored_items, "cutting_board")
	
	print("Recipe check result: ", recipe_check)
	
	if not recipe_check["success"]:
		# Recipe doesn't exist - show error but keep UI open
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
	
	# Close processing UI now that we're starting to process
	if processing_ui:
		processing_ui.visible = false
	
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
