extends StationBase

var is_cooking: bool = false
var cooking_time: float = 0.0
var cooking_duration: float = 2.5  # 2.5 seconds to fry
var cooking_item: int = -1
var cooking_result: int = -1
var progress_bar: Control = null

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
	
	if held_item == -1:
		return
	
	# If already cooking, can't interact
	if is_cooking:
		return
	
	# Check if item can be cooked on stove
	if can_cook_on_stove(held_item):
		# Start cooking process
		is_cooking = true
		cooking_time = 0.0
		cooking_item = held_item
		cooking_result = get_cooked_result(held_item)
		
		# Show progress bar
		if progress_bar:
			progress_bar.set_label_text("Frying...")
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

func can_cook_on_stove(item: int) -> bool:
	return item in [ItemTypes.ItemType.UNCUT_FRIES, ItemTypes.ItemType.EGG]

func get_cooked_result(item: int) -> int:
	match item:
		ItemTypes.ItemType.UNCUT_FRIES: return ItemTypes.ItemType.FRIES
		ItemTypes.ItemType.EGG: return ItemTypes.ItemType.SUNNY_SIDEUP_EGG
		_: return item

