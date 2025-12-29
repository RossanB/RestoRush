extends StationBase

var is_mixing: bool = false
var mixing_time: float = 0.0
var mixing_duration: float = 2.0  # 2 seconds to mix
var mixing_item: ItemTypes.ItemType = -1
var mixing_result: ItemTypes.ItemType = -1
var progress_bar: Control = null

func _ready():
	super._ready()
	station_type = "mixer"
	create_progress_bar()

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
	
	if held_item == -1:
		return
	
	# If already mixing, can't interact
	if is_mixing:
		return
	
	# Check if item can be mixed
	if can_mix(held_item):
		# Start mixing process
		is_mixing = true
		mixing_time = 0.0
		mixing_item = held_item
		mixing_result = get_mixed_result(held_item)
		
		# Show progress bar
		if progress_bar:
			progress_bar.set_label_text("Mixing...")
			progress_bar.show_progress()
			progress_bar.set_progress(0.0)
		
		# Remove item from player
		player.clear_item()
		
		# Wait for mixing to complete
		await get_tree().create_timer(mixing_duration).timeout
		
		# Give mixed result to player
		if player and not player.has_item():
			player.set_held_item(mixing_result)
		
		is_mixing = false
		if progress_bar:
			progress_bar.hide_progress()

func can_mix(item: ItemTypes.ItemType) -> bool:
	return item == ItemTypes.ItemType.MILK

func get_mixed_result(item: ItemTypes.ItemType) -> ItemTypes.ItemType:
	if item == ItemTypes.ItemType.MILK:
		return ItemTypes.ItemType.ICECREAM
	return item

