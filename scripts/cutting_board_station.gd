extends StationBase

var stored_items: Array[ItemTypes.ItemType] = []
var is_processing: bool = false
var processing_time: float = 0.0
var processing_duration: float = 2.0  # 2 seconds to cut
var processing_item: ItemTypes.ItemType = -1
var processing_result: ItemTypes.ItemType = -1
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

func create_progress_bar():
	progress_bar = preload("res://scenes/progress_bar.tscn").instantiate()
	add_child(progress_bar)
	progress_bar.position = Vector2(-50, -40)
	progress_bar.set_max_progress(processing_duration)
	progress_bar.visible = false

func interact(player: Node):
	var held_item = player.get_held_item()
	
	if held_item == -1:
		# Player has no item - can't do anything
		return
	
	# If already processing, can't interact
	if is_processing:
		return
	
	# Check if item can be chopped
	if can_chop(held_item):
		# Start cutting process
		is_processing = true
		processing_time = 0.0
		processing_item = held_item
		processing_result = get_chopped_result(held_item)
		
		# Show progress bar
		if progress_bar:
			progress_bar.set_label_text("Cutting...")
			progress_bar.show_progress()
			progress_bar.set_progress(0.0)
		
		# Remove item from player and start processing
		player.clear_item()
		
		# Wait for processing to complete
		await get_tree().create_timer(processing_duration).timeout
		
		# Give result to player
		if player and not player.has_item():
			player.set_held_item(processing_result)
		
		is_processing = false
		if progress_bar:
			progress_bar.hide_progress()
		return
	
	# Check if items can be mixed (dough)
	if held_item == ItemTypes.ItemType.FLOUR:
		# Need water to make dough
		if stored_items.has(ItemTypes.ItemType.WATER):
			stored_items.erase(ItemTypes.ItemType.WATER)
			player.clear_item()
			player.set_held_item(ItemTypes.ItemType.DOUGH)
			return
		else:
			# Store flour, wait for water
			stored_items.append(held_item)
			player.clear_item()
			return
	
	if held_item == ItemTypes.ItemType.WATER:
		# Check if flour is stored
		if stored_items.has(ItemTypes.ItemType.FLOUR):
			stored_items.erase(ItemTypes.ItemType.FLOUR)
			player.clear_item()
			player.set_held_item(ItemTypes.ItemType.DOUGH)
			return
		else:
			# Store water, wait for flour
			stored_items.append(held_item)
			player.clear_item()
			return
	
	# Check if items can be assembled
	if can_assemble(held_item):
		# Try to assemble with stored items
		var assembly_result = try_assemble(held_item)
		if assembly_result != -1:
			player.clear_item()
			player.set_held_item(assembly_result)
			stored_items.clear()
			return
		else:
			# Store item for assembly
			stored_items.append(held_item)
			player.clear_item()
			return
	
	# If nothing else, just store the item
	stored_items.append(held_item)
	player.clear_item()

func can_chop(item: ItemTypes.ItemType) -> bool:
	return item in [ItemTypes.ItemType.LETTUCE, ItemTypes.ItemType.TOMATO, ItemTypes.ItemType.MEAT, ItemTypes.ItemType.PEPPERONI, ItemTypes.ItemType.POTATO]

func get_chopped_result(item: ItemTypes.ItemType) -> ItemTypes.ItemType:
	match item:
		ItemTypes.ItemType.LETTUCE: return ItemTypes.ItemType.CHOPPED_LETTUCE
		ItemTypes.ItemType.TOMATO: return ItemTypes.ItemType.CHOPPED_TOMATO
		ItemTypes.ItemType.MEAT: return ItemTypes.ItemType.CHOPPED_MEAT
		ItemTypes.ItemType.PEPPERONI: return ItemTypes.ItemType.CHOPPED_PEPPERONI
		ItemTypes.ItemType.POTATO: return ItemTypes.ItemType.UNCUT_FRIES
		_: return item

func can_assemble(item: ItemTypes.ItemType) -> bool:
	# Check if this item is part of any assembly recipe
	return item in [ItemTypes.ItemType.DOUGH, ItemTypes.ItemType.CHOPPED_LETTUCE, ItemTypes.ItemType.CHOPPED_TOMATO, ItemTypes.ItemType.CHOPPED_MEAT, ItemTypes.ItemType.CHOPPED_PEPPERONI, ItemTypes.ItemType.GLAZE]

func try_assemble(item: ItemTypes.ItemType) -> ItemTypes.ItemType:
	# Taco assembly: DOUGH + CHOPPED_LETTUCE + CHOPPED_MEAT + CHOPPED_TOMATO
	if item == ItemTypes.ItemType.DOUGH or item == ItemTypes.ItemType.CHOPPED_LETTUCE or item == ItemTypes.ItemType.CHOPPED_MEAT or item == ItemTypes.ItemType.CHOPPED_TOMATO:
		var items = stored_items.duplicate()
		items.append(item)
		if items.has(ItemTypes.ItemType.DOUGH) and items.has(ItemTypes.ItemType.CHOPPED_LETTUCE) and items.has(ItemTypes.ItemType.CHOPPED_MEAT) and items.has(ItemTypes.ItemType.CHOPPED_TOMATO):
			return ItemTypes.ItemType.TACO
	
	# Pizza assembly: DOUGH + CHOPPED_PEPPERONI
	if item == ItemTypes.ItemType.DOUGH or item == ItemTypes.ItemType.CHOPPED_PEPPERONI:
		var items = stored_items.duplicate()
		items.append(item)
		if items.has(ItemTypes.ItemType.DOUGH) and items.has(ItemTypes.ItemType.CHOPPED_PEPPERONI):
			return ItemTypes.ItemType.PIZZA
	
	# Donuts assembly: DOUGH + GLAZE
	if item == ItemTypes.ItemType.DOUGH or item == ItemTypes.ItemType.GLAZE:
		var items = stored_items.duplicate()
		items.append(item)
		if items.has(ItemTypes.ItemType.DOUGH) and items.has(ItemTypes.ItemType.GLAZE):
			return ItemTypes.ItemType.DONUTS
	
	return -1

