extends StationBase

var stored_items: Array[int] = []
var is_cooking: bool = false
var cooking_time: float = 0.0
var cooking_duration: float = 2.5  # 2.5 seconds to fry
var progress_bar: Control = null
var processing_ui: CanvasLayer = null

func _ready():
	super._ready()
	station_type = "stove"
	create_progress_bar()

func _process(delta):
	if is_cooking:
		cooking_time += delta
		if progress_bar:
			progress_bar.set_progress(cooking_time)
		
		if cooking_time >= cooking_duration:
			# Cooking complete
			is_cooking = false
			cooking_time = 0.0
			if progress_bar:
				progress_bar.hide_progress()

func create_progress_bar():
	progress_bar = preload("res://scenes/progress_bar.tscn").instantiate()
	add_child(progress_bar)
	progress_bar.position = Vector2(-50, -40)
	progress_bar.set_max_progress(cooking_duration)
	progress_bar.visible = false

func interact(player: Node):
	var held_item = player.get_held_item()
	
	# If player has an item, place it on the stove
	if held_item != -1:
		stored_items.append(held_item)
		player.clear_item()
		print("Item placed on stove. Stored items: ", stored_items.size())
		return
	
	# Player has no item - show processing UI
	if stored_items.is_empty():
		return
	
	# If already cooking, can't interact
	if is_cooking:
		return
	
	# Determine button text based on what action will be performed
	var button_text = "Fry"
	var recipe_check = RecipeChecker.check_recipe(stored_items, "stove")
	if recipe_check["success"]:
		# Check if it's an assemble action by looking at recipes
		for recipe_result in Recipes.RECIPES.keys():
			var recipe = Recipes.RECIPES[recipe_result]
			for step in recipe["steps"]:
				if step.has("station") and step["station"] == "stove" and step.has("action"):
					if step["action"] == "assemble":
						# Check if stored items match this assemble step
						if step.has("items"):
							var items_array: Array = step["items"] as Array
							var needed_items: Array[int] = []
							for item in items_array:
								needed_items.append(item as int)
							if RecipeChecker.items_match(stored_items, needed_items):
								button_text = "Assemble"
								break
	
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
	if stored_items.is_empty() or is_cooking:
		return
	
	# Debug: Print stored items
	print("Stove stored items: ", stored_items)
	for item in stored_items:
		print("  - Item: ", ItemTypes.get_item_name(item), " (", item, ")")
	
	# Check if stored items match a recipe
	var recipe_check = RecipeChecker.check_recipe(stored_items, "stove")
	
	print("Stove recipe check result: ", recipe_check)
	
	if not recipe_check["success"]:
		# Recipe doesn't exist - show error but keep UI open
		ErrorMessage.show_error(recipe_check["error"])
		return
	
	# Recipe found - process it (could be cook or assemble)
	var result_item = recipe_check["result"]
	
	# Determine process type
	var process_type = "Frying..."
	for recipe_result in Recipes.RECIPES.keys():
		var recipe = Recipes.RECIPES[recipe_result]
		for step in recipe["steps"]:
			if step.has("station") and step["station"] == "stove" and step.get("result", -1) == result_item:
				if step.has("action") and step["action"] == "assemble":
					process_type = "Assembling..."
					break
	
	# Close processing UI now that we're starting to process
	if processing_ui:
		processing_ui.visible = false
	
	# Start processing
	is_cooking = true
	cooking_time = 0.0
	
	# Play frying sound
	AudioManager.play_frying()
	
	# Show progress bar
	if progress_bar:
		progress_bar.set_label_text(process_type)
		progress_bar.show_progress()
		progress_bar.set_progress(0.0)
	
	# Clear stored items
	stored_items.clear()
	
	# Wait for cooking to complete
	await get_tree().create_timer(cooking_duration).timeout
	
	# Give cooked result to player
	if player and not player.has_item():
		player.set_held_item(result_item)
	
	is_cooking = false
	if progress_bar:
		progress_bar.hide_progress()
