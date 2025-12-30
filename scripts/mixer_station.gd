extends StationBase

var stored_items: Array[int] = []
var is_mixing: bool = false
var mixing_time: float = 0.0
var mixing_duration: float = 2.0  # 2 seconds to mix
var progress_bar: Control = null
var error_ui: Node = null

func _ready():
	super._ready()
	station_type = "mixer"
	create_progress_bar()
	error_ui = ErrorMessage.get_error_ui()

func _process(delta):
	if is_mixing:
		mixing_time += delta
		if progress_bar:
			progress_bar.set_progress(mixing_time)
		
		if mixing_time >= mixing_duration:
			# Mixing complete
			is_mixing = false
			mixing_time = 0.0
			if progress_bar:
				progress_bar.hide_progress()

func create_progress_bar():
	progress_bar = preload("res://scenes/progress_bar.tscn").instantiate()
	add_child(progress_bar)
	progress_bar.position = Vector2(-50, -40)
	progress_bar.set_max_progress(mixing_duration)
	progress_bar.visible = false

func interact(player: Node):
	var held_item = player.get_held_item()
	
	# If player has an item, place it in the mixer
	if held_item != -1:
		stored_items.append(held_item)
		player.clear_item()
		print("Item placed in mixer. Stored items: ", stored_items.size())
		return
	
	# Player has no item - try to mix stored items
	if stored_items.is_empty():
		return
	
	# If already mixing, can't interact
	if is_mixing:
		return
	
	# Check if stored items match a recipe
	var recipe_check = RecipeChecker.check_recipe(stored_items, "mixer")
	
	if not recipe_check["success"]:
		# Recipe doesn't exist - show error
		if error_ui and error_ui.has_method("show_error_message"):
			error_ui.show_error_message(recipe_check["error"])
		else:
			print(recipe_check["error"])
		return
	
	# Recipe found - mix it
	var result_item = recipe_check["result"]
	
	# Start mixing
	is_mixing = true
	mixing_time = 0.0
	
	# Show progress bar
	if progress_bar:
		progress_bar.set_label_text("Mixing...")
		progress_bar.show_progress()
		progress_bar.set_progress(0.0)
	
	# Clear stored items
	stored_items.clear()
	
	# Wait for mixing to complete
	await get_tree().create_timer(mixing_duration).timeout
	
	# Give mixed result to player
	if player and not player.has_item():
		player.set_held_item(result_item)
	
	is_mixing = false
	if progress_bar:
		progress_bar.hide_progress()
