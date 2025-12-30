extends Node
class_name CustomerManager

# Spawn settings
@export var entrance_position: Vector2 = Vector2(200, 23)  # Spawn to the left of player start position
@export var exit_position: Vector2 = Vector2(226, 23)
@export var spawn_interval: float = 10.0  # Seconds between spawn attempts (reduced since timer pauses when in kitchen)
@export var max_customers: int = 10  # Maximum customers in restaurant

# Restaurant boundaries - adjust these to match your restaurant's walkable area
@export var restaurant_min_x: float = -200.0
@export var restaurant_max_x: float = 300.0
@export var restaurant_min_y: float = -100.0
@export var restaurant_max_y: float = 150.0

var spawn_timer: float = 0.0
var customer_scene = preload("res://scenes/Customer.tscn")

# Available NPC sprite resources
var npc_sprites = [
	preload("res://tres/npc1.tres"),
	preload("res://tres/npc2.tres"),
	preload("res://tres/npc3.tres"),
	preload("res://tres/npc4.tres"),
	preload("res://tres/npc5.tres")
]

# Party size distribution (chance for each party size)
var party_size_weights = {
	1: 60,  # 60% chance for single customer
	2: 35,  # 35% chance for 2 customers
	3: 5    # 5% chance for 3 customers (seldom)
	# 4 people parties removed
}

var should_restore: bool = false

func _ready():
	add_to_group("customer_manager")
	
	# Validate and clamp entrance/exit positions to ensure they're inside restaurant
	entrance_position = clamp_position_to_restaurant(entrance_position)
	exit_position = clamp_position_to_restaurant(exit_position)
	
	# Check if we should restore customers or spawn new ones
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager and scene_manager.customer_states.size() > 0:
		# Customers exist in saved state, mark for restoration
		should_restore = true
		print("Customers found in saved state, will restore instead of spawning")
	else:
		# No saved customers, spawn first customer immediately
		should_restore = false
		call_deferred("try_spawn_customer_party")

func clamp_position_to_restaurant(pos: Vector2) -> Vector2:
	# Clamp position to restaurant boundaries
	return Vector2(
		clamp(pos.x, restaurant_min_x, restaurant_max_x),
		clamp(pos.y, restaurant_min_y, restaurant_max_y)
	)

func _process(delta):
	# Don't spawn if we're waiting to restore customers
	if should_restore:
		return
	
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		try_spawn_customer_party()

func try_spawn_customer_party():
	# Check if we're at max capacity
	var current_customers = get_tree().get_nodes_in_group("customers")
	if current_customers.size() >= max_customers:
		return
	
	# Determine party size
	var party_size = determine_party_size()
	
	# Find a table that can accommodate this party
	var table = find_available_table(party_size)
	if not table:
		# No available table, skip this spawn
		print("No available table for party of ", party_size)
		return
	
	# Spawn the party
	spawn_customer_party(party_size, table)

func determine_party_size() -> int:
	var total_weight = 0
	for weight in party_size_weights.values():
		total_weight += weight
	
	var random = randi() % total_weight
	var current_weight = 0
	
	for party_size in party_size_weights.keys():
		current_weight += party_size_weights[party_size]
		if random < current_weight:
			return party_size
	
	return 1  # Default to single customer

func find_available_table(party_size: int) -> Node:
	var tables = get_tree().get_nodes_in_group("tables")
	
	# Collect all tables that can accommodate the party
	var available_tables: Array[Node] = []
	for table in tables:
		if table.has_method("can_accommodate") and table.can_accommodate(party_size):
			available_tables.append(table)
	
	# If no tables available, return null
	if available_tables.is_empty():
		return null
	
	# Randomly select from available tables
	var random_index = randi() % available_tables.size()
	return available_tables[random_index]

func spawn_customer_party(party_size: int, table: Node):
	print("Spawning party of ", party_size, " at table: ", table.name)
	print("Table can accommodate: ", table.table_size if table.has_method("get") else "unknown")
	
	# Spawn customers one by one with a delay to prevent pushing each other
	spawn_customer_with_delay(party_size, table, 0)

func spawn_customer_with_delay(party_size: int, table: Node, customer_index: int):
	if customer_index >= party_size:
		print("Party of ", party_size, " spawned successfully")
		return
	
	print("Spawning customer ", customer_index + 1, " of ", party_size)
	var customer = customer_scene.instantiate()
	
	# Assign to table and get seat position and facing direction
	var seat_data = table.assign_customer(customer, -1)
	var seat_pos = seat_data.get("position", Vector2.ZERO)
	var facing_dir = seat_data.get("facing", "down")
	
	# Set party size for order generation
	customer.party_size = party_size
	# Mark if this is the first customer of the party (for bell sound)
	customer.is_first_in_party = (customer_index == 0)
	
	# Assign random NPC sprite and save index
	var sprite_index = randi() % npc_sprites.size()
	var random_sprite = npc_sprites[sprite_index]
	if customer.has_node("AnimatedSprite2D"):
		customer.get_node("AnimatedSprite2D").sprite_frames = random_sprite
	# Save sprite index for restoration
	if "npc_sprite_index" in customer:
		customer.npc_sprite_index = sprite_index
	
	# Better spacing for multiple customers - spread them out more
	# For parties, space customers horizontally so they don't overlap or push each other
	var entrance_offset: Vector2
	if party_size > 1:
		# Space party members horizontally (left to right)
		# First customer goes left, second goes right, etc.
		var spacing = 40.0  # More space between customers (was 30)
		var offset_x = (customer_index - (party_size - 1) / 2.0) * spacing
		var offset_y = randf_range(-5, 5)  # Small vertical variation
		entrance_offset = Vector2(offset_x, offset_y)
	else:
		# Single customer, small random offset
		entrance_offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
	
	var final_entrance_pos = entrance_position + entrance_offset
	
	# Clamp to restaurant boundaries to ensure customers spawn inside
	final_entrance_pos.x = clamp(final_entrance_pos.x, restaurant_min_x, restaurant_max_x)
	final_entrance_pos.y = clamp(final_entrance_pos.y, restaurant_min_y, restaurant_max_y)
	
	customer.set_entrance_position(final_entrance_pos)
	customer.set_exit_position(exit_position)
	
	# Set seat position and facing direction (already got from assign_customer above)
	customer.set_seat_position(seat_pos)
	customer.set_facing_direction(facing_dir)
	customer.set_table(table)
	
	# Add to scene
	get_tree().current_scene.add_child(customer)
	
	# Spawn next customer after a delay (only if there are more customers to spawn)
	if customer_index + 1 < party_size:
		# Wait 1.5 seconds before spawning next customer (increased from 0.5)
		await get_tree().create_timer(1.5).timeout
		spawn_customer_with_delay(party_size, table, customer_index + 1)

func on_customer_left(customer: Node):
	# Find which table the customer was at and free up the seat
	var tables = get_tree().get_nodes_in_group("tables")
	for table in tables:
		if table.has_method("remove_customer"):
			table.remove_customer(customer)

func restore_customers(saved_customer_states: Array[Dictionary], saved_table_states: Dictionary, elapsed_time: float = 0.0):
	print("CustomerManager: restore_customers called with ", saved_customer_states.size(), " customers")
	should_restore = false  # Clear flag so spawning can resume
	
	# Make a copy of the arrays to prevent issues if they get cleared elsewhere
	var customer_states_copy = saved_customer_states.duplicate()
	var table_states_copy = saved_table_states.duplicate()
	
	# Restore table states first (set occupied_seats count)
	print("CustomerManager: Restoring ", table_states_copy.size(), " table states")
	for table_id in table_states_copy.keys():
		# Find table by name in tables group
		var table = null
		var tables = get_tree().get_nodes_in_group("tables")
		for t in tables:
			if t.name == table_id:
				table = t
				break
		
		if table and table.has_method("restore_table_state"):
			table.restore_table_state(table_states_copy[table_id])
	
	# Group customers by table so they restore together (parties stay together)
	var customers_by_table: Dictionary = {}  # table_id -> Array of customer states
	for customer_state in customer_states_copy:
		var table_id = customer_state.get("table_id", "")
		if table_id == "":
			table_id = "no_table"
		
		if not customers_by_table.has(table_id):
			customers_by_table[table_id] = []
		customers_by_table[table_id].append(customer_state)
	
	# Restore customers grouped by table (so parties restore together)
	print("CustomerManager: Starting to restore ", customer_states_copy.size(), " customers across ", customers_by_table.size(), " tables")
	var restored_count = 0
	
	for table_id in customers_by_table.keys():
		var table_customers = customers_by_table[table_id]
		print("CustomerManager: Restoring ", table_customers.size(), " customers at table: ", table_id)
		
		# Find the table
		var table = null
		if table_id != "no_table":
			var tables = get_tree().get_nodes_in_group("tables")
			for t in tables:
				if t.name == table_id:
					table = t
					break
		
		# Restore all customers at this table together
		for customer_state in table_customers:
			var customer = customer_scene.instantiate()
			
			# Set restoring flag BEFORE adding to scene (so _ready() doesn't generate new order)
			customer.is_restoring = true
			
			# Restore order items immediately to prevent _ready() from generating new order
			var saved_order = customer_state.get("order_items", [])
			if saved_order.size() > 0:
				customer.order_items = saved_order.duplicate()
			
			# Restore NPC sprite from saved index
			var saved_sprite_index = customer_state.get("npc_sprite_index", -1)
			if saved_sprite_index >= 0 and saved_sprite_index < npc_sprites.size():
				var saved_sprite = npc_sprites[saved_sprite_index]
				if customer.has_node("AnimatedSprite2D"):
					customer.get_node("AnimatedSprite2D").sprite_frames = saved_sprite
				customer.npc_sprite_index = saved_sprite_index
			else:
				# Fallback to random if index invalid
				var sprite_index = randi() % npc_sprites.size()
				var random_sprite = npc_sprites[sprite_index]
				if customer.has_node("AnimatedSprite2D"):
					customer.get_node("AnimatedSprite2D").sprite_frames = random_sprite
				customer.npc_sprite_index = sprite_index
			
			# Restore table assignment with specific seat index
			var saved_seat_index = customer_state.get("seat_index", -1)
			if table:
				customer.set_table(table)
				# Restore to specific seat (don't increment occupied_seats since we're restoring)
				if table.has_method("restore_customer"):
					table.restore_customer(customer, saved_seat_index)
			
			# Hide customer initially (will show after restore)
			customer.visible = false
			
			# Add to scene first so _ready() runs and UI is created
			get_tree().current_scene.add_child(customer)
			
			# Wait one frame for _ready() to complete, then restore immediately
			await get_tree().process_frame
			
			# Restore customer state (after table assignment and UI creation)
			if customer.has_method("restore_customer_state"):
				customer.restore_customer_state(customer_state, elapsed_time)
			
			# Clear restoring flag
			customer.is_restoring = false
			
			# Make customer visible now that everything is restored
			customer.visible = true
			
			restored_count += 1
			print("CustomerManager: Customer restored at table: ", table_id, " seat: ", saved_seat_index, " position: ", customer.global_position)
	
	print("CustomerManager: Successfully restored ", restored_count, " customers")
