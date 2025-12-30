extends StationBase

var stored_items: Array[int] = []
var is_cooking: bool = false
var cooking_time: float = 0.0
var cooking_duration: float = 3.0  # 3 seconds to cook
var progress_bar: Control = null
var processing_ui: CanvasLayer = null

func _ready():
	super._ready()
	station_type = "oven"
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
	
	# If player has an item, place it in the oven
	if held_item != -1:
		stored_items.append(held_item)
		player.clear_item()
		print("Item placed in oven. Stored items: ", stored_items.size())
		return
	
	# Player has no item - show processing UI
	if stored_items.is_empty():
		return
	
	# If already cooking, can't interact
	if is_cooking:
		return
	
	# Show processing UI
	get_or_create_processing_ui()
	processing_ui.show_processing(stored_items, self, player, "Cook")

func get_or_create_processing_ui():
	if not processing_ui:
		processing_ui = preload("res://scenes/processing_ui.tscn").instantiate()
		get_tree().root.add_child(processing_ui)
	return processing_ui

func process_items(player: Node):
	# Called from processing UI when "Cook" button is pressed
	if stored_items.is_empty() or is_cooking:
		return
	
	# Check if stored items match a recipe
	var recipe_check = RecipeChecker.check_recipe(stored_items, "oven")
	
	if not recipe_check["success"]:
		# Recipe doesn't exist - show error
		ErrorMessage.show_error(recipe_check["error"])
		return
	
	# Recipe found - cook it
	var result_item = recipe_check["result"]
	
	# Start cooking
	is_cooking = true
	cooking_time = 0.0
	
	# Show progress bar
	if progress_bar:
		progress_bar.set_label_text("Cooking...")
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
