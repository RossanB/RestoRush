extends StationBase

var is_cooking: bool = false
var cooking_time: float = 0.0
var cooking_duration: float = 3.0  # 3 seconds to cook
var cooking_item: ItemTypes.ItemType = -1
var cooking_result: ItemTypes.ItemType = -1
var progress_bar: Control = null

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
	
	if held_item == -1:
		return
	
	# If already cooking, can't interact
	if is_cooking:
		return
	
	# Check if item can be cooked in oven
	if can_cook_in_oven(held_item):
		# Start cooking process
		is_cooking = true
		cooking_time = 0.0
		cooking_item = held_item
		cooking_result = get_cooked_result(held_item)
		
		# Show progress bar
		if progress_bar:
			progress_bar.set_label_text("Cooking...")
			progress_bar.show_progress()
			progress_bar.set_progress(0.0)
		
		# Remove item from player
		player.clear_item()
		
		# Wait for cooking to complete
		await get_tree().create_timer(cooking_duration).timeout
		
		# Give cooked result to player
		if player and not player.has_item():
			player.set_held_item(cooking_result)
		
		is_cooking = false
		if progress_bar:
			progress_bar.hide_progress()

func can_cook_in_oven(item: ItemTypes.ItemType) -> bool:
	return item in [ItemTypes.ItemType.TACO, ItemTypes.ItemType.PIZZA]

func get_cooked_result(item: ItemTypes.ItemType) -> ItemTypes.ItemType:
	# Oven cooking doesn't change the item type, just "cooks" it
	return item

