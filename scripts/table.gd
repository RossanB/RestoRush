extends Node2D
class_name Table

# Table sizes
enum TableSize {
	TWO_SEATER = 2,
	FOUR_SEATER = 4
}

@export var table_size: TableSize = TableSize.TWO_SEATER
@export var seat_positions: Array[Vector2] = []  # Positions where customers sit at this table
@export var seat_facing_directions: Array[String] = []  # Facing direction for each seat ("up", "down", "left", "right")

# Easy-to-edit facing directions for 2-seater tables
@export_group("2-Seater Facing (Easy Edit)")
@export var left_seat_facing: String = "right"  # Left customer faces: "left", "right", "up", "down"
@export var right_seat_facing: String = "left"  # Right customer faces: "left", "right", "up", "down"

# Easy-to-edit facing directions for 4-seater tables
@export_group("4-Seater Facing (Easy Edit)")
@export var top_left_facing: String = "down"
@export var top_right_facing: String = "down"
@export var bottom_left_facing: String = "up"
@export var bottom_right_facing: String = "up"

var occupied_seats: int = 0
var customers: Array[Node] = []  # Customers currently at this table

func _ready():
	add_to_group("tables")
	
	# Always ensure arrays are initialized in _ready
	# Generate default positions first
	if seat_positions.is_empty():
		generate_default_seat_positions()
	
	# Then apply facing directions (this will also check and generate if needed)
	apply_easy_edit_facing()
	
	# Final safety check - ensure arrays are synchronized
	if seat_positions.size() != seat_facing_directions.size():
		print("Table ", name, ": WARNING - Arrays out of sync in _ready. Regenerating...")
		generate_default_seat_positions()
		apply_easy_edit_facing()

func generate_default_seat_positions():
	# Generate positions around the table based on size
	# Seat positions are relative to the table center (global_position)
	# Increased distance from table (30px instead of 20px)
	seat_positions.clear()
	seat_facing_directions.clear()
	
	match table_size:
		TableSize.TWO_SEATER:
			# Two seats: left and right of table center, facing each other
			seat_positions.append(Vector2(-22, 2))  # Left seat, further from table
			seat_facing_directions.append("right")   # Face right (toward table)
			seat_positions.append(Vector2(22, 2))    # Right seat, further from table
			seat_facing_directions.append("left")    # Face left (toward table)
		TableSize.FOUR_SEATER:
			# Four seats: around the table center, all facing toward table
			seat_positions.append(Vector2(-38, -20))  # Top-left, further from table
			seat_facing_directions.append("down")     # Face down (toward table)
			seat_positions.append(Vector2(38, -20))    # Top-right, further from table
			seat_facing_directions.append("down")     # Face down (toward table)
			seat_positions.append(Vector2(-38, 20))   # Bottom-left, further from table
			seat_facing_directions.append("up")       # Face up (toward table)
			seat_positions.append(Vector2(38, 20))    # Bottom-right, further from table
			seat_facing_directions.append("up")       # Face up (toward table)

func can_accommodate(party_size: int) -> bool:
	# Tables are reserved for entire parties - only assign to completely empty tables
	# This ensures that once a party is seated, no other party can be assigned to that table
	return occupied_seats == 0 and party_size <= table_size

func assign_customer(customer: Node, seat_index: int = -1) -> Dictionary:
	# Returns both position and facing direction
	# Ensure arrays are initialized before assigning
	if seat_positions.is_empty():
		generate_default_seat_positions()
	if seat_facing_directions.is_empty():
		apply_easy_edit_facing()
	
	# Ensure arrays are synchronized
	if seat_positions.size() != seat_facing_directions.size():
		apply_easy_edit_facing()
	
	if seat_index == -1:
		# Find first available seat
		for i in range(seat_positions.size()):
			if i >= occupied_seats:
				seat_index = i
				break
	
	if seat_index >= 0 and seat_index < seat_positions.size():
		occupied_seats += 1
		customers.append(customer)
		# Seat positions are relative to table center, so add global_position
		var seat_pos = global_position + seat_positions[seat_index]
		var facing_dir = "down"  # Default
		if seat_index < seat_facing_directions.size():
			facing_dir = seat_facing_directions[seat_index]
		else:
			print("Table ", name, ": WARNING - seat_index ", seat_index, " out of bounds for seat_facing_directions (size: ", seat_facing_directions.size(), ")")
			# Try to apply facing directions again
			apply_easy_edit_facing()
			if seat_index < seat_facing_directions.size():
				facing_dir = seat_facing_directions[seat_index]
		print("Table ", name, ": Assigning customer to seat ", seat_index, " with facing: ", facing_dir, " (seat_facing_directions: ", seat_facing_directions, ")")
		return {"position": seat_pos, "facing": facing_dir}
	
	return {"position": global_position, "facing": "down"}  # Fallback

func remove_customer(customer: Node):
	if customer in customers:
		customers.erase(customer)
		occupied_seats -= 1
		# Ensure occupied_seats doesn't go negative
		occupied_seats = max(0, occupied_seats)

func get_available_seats() -> int:
	return table_size - occupied_seats

func is_full() -> bool:
	return occupied_seats >= table_size

func get_customers() -> Array[Node]:
	# Return all customers currently at this table
	return customers.duplicate()

func get_customer_facing(customer: Node) -> String:
	# Get the facing direction for a specific customer at this table
	# Ensure arrays are initialized
	if seat_facing_directions.is_empty():
		apply_easy_edit_facing()
	
	var seat_index = get_customer_seat_index(customer)
	if seat_index >= 0 and seat_index < seat_facing_directions.size():
		return seat_facing_directions[seat_index]
	return "down"  # Default

func get_customer_seat_index(customer: Node) -> int:
	# Find which seat index a customer is at
	# Ensure arrays are initialized
	if seat_positions.is_empty():
		generate_default_seat_positions()
	
	if customer not in customers:
		return -1
	
	# Find the customer's position and match it to a seat
	var customer_pos = customer.global_position
	for i in range(seat_positions.size()):
		if i >= seat_positions.size():
			break
		var seat_pos = global_position + seat_positions[i]
		if customer_pos.distance_to(seat_pos) < 10.0:  # Within 10 pixels
			return i
	
	return -1

func get_table_state() -> Dictionary:
	return {
		"occupied_seats": occupied_seats,
		"customer_paths": []
	}

func restore_table_state(state: Dictionary):
	occupied_seats = state.get("occupied_seats", 0)
	customers.clear()  # Will be repopulated when customers are restored

func restore_customer(customer: Node, seat_index: int = -1):
	# Restore customer to table without incrementing occupied_seats
	# (since we already restored the count)
	# Ensure arrays are initialized before accessing
	if seat_positions.is_empty():
		generate_default_seat_positions()
	if seat_facing_directions.is_empty():
		apply_easy_edit_facing()
	
	if customer not in customers:
		customers.append(customer)
		# If seat_index is specified, ensure customer is positioned at that exact seat
		# (occupied_seats is already set from restore_table_state)
		if seat_index >= 0 and seat_index < seat_positions.size():
			# Position customer at the saved seat
			var seat_pos = global_position + seat_positions[seat_index]
			customer.global_position = seat_pos
			# Set facing direction for that seat
			if seat_index < seat_facing_directions.size():
				var facing_dir = seat_facing_directions[seat_index]
				if customer.has_method("set_facing_direction"):
					customer.set_facing_direction(facing_dir)
			else:
				# Fallback if facing directions array is out of sync
				print("Table ", name, ": WARNING - seat_index ", seat_index, " out of bounds for seat_facing_directions during restore. Using default.")
				if customer.has_method("set_facing_direction"):
					customer.set_facing_direction("down")

func apply_easy_edit_facing():
	# Apply the easy-edit facing directions to the array
	# This makes it easy to edit individual seat facing in the inspector
	# Always apply, even if positions were manually set
	
	# First ensure seat positions exist
	if seat_positions.is_empty():
		generate_default_seat_positions()
	
	match table_size:
		TableSize.TWO_SEATER:
			# Ensure we have 2 seats, generate if needed
			if seat_positions.size() < 2:
				generate_default_seat_positions()
			# Now apply easy-edit facing directions
			seat_facing_directions.clear()
			seat_facing_directions.append(left_seat_facing)
			seat_facing_directions.append(right_seat_facing)
			# Ensure arrays are synchronized
			if seat_facing_directions.size() != seat_positions.size():
				generate_default_seat_positions()
				seat_facing_directions.clear()
				seat_facing_directions.append(left_seat_facing)
				seat_facing_directions.append(right_seat_facing)
			print("Table ", name, ": Applied facing directions - Left: ", left_seat_facing, " Right: ", right_seat_facing)
		TableSize.FOUR_SEATER:
			# Ensure we have 4 seats, generate if needed
			if seat_positions.size() < 4:
				generate_default_seat_positions()
			# Now apply easy-edit facing directions
			seat_facing_directions.clear()
			seat_facing_directions.append(top_left_facing)
			seat_facing_directions.append(top_right_facing)
			seat_facing_directions.append(bottom_left_facing)
			seat_facing_directions.append(bottom_right_facing)
			# Ensure arrays are synchronized
			if seat_facing_directions.size() != seat_positions.size():
				generate_default_seat_positions()
				seat_facing_directions.clear()
				seat_facing_directions.append(top_left_facing)
				seat_facing_directions.append(top_right_facing)
				seat_facing_directions.append(bottom_left_facing)
				seat_facing_directions.append(bottom_right_facing)
