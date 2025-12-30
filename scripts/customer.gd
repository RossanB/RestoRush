extends CharacterBody2D
class_name Customer

# Customer states
enum CustomerState {
	WALKING_TO_SEAT,    # Walking from entrance to seat
	WAITING_FOR_ORDER,  # Waiting for player to take order
	ORDER_TAKEN,        # Order taken, waiting for food
	SATISFIED,          # Order fulfilled, customer leaves
	WALKING_TO_EXIT,    # Walking to exit
	LEAVING             # Customer is leaving
}

var customer_state: CustomerState = CustomerState.WALKING_TO_SEAT
var order_items: Array[int] = []  # Array of item types the customer wants
var waiting_time: float = 0.0
var max_waiting_time: float = 60.0  # Customer will leave if order not taken in 60 seconds
var patience_time: float = 0.0
var max_patience_time: float = 90.0  # Customer will leave if order not fulfilled in 90 seconds

# Movement
const CUSTOMER_SPEED = 100.0
@export var target_seat_position: Vector2 = Vector2.ZERO
@export var entrance_position: Vector2 = Vector2.ZERO
@export var exit_position: Vector2 = Vector2.ZERO
var current_dir: String = "down"
var arrival_threshold: float = 5.0  # Distance to consider "arrived"
var assigned_table: Node = null  # Reference to the table this customer is assigned to
var party_size: int = 1  # Size of the party this customer belongs to
var is_first_in_party: bool = false  # True if this is the first customer of the party
var stuck_timer: float = 0.0
var last_position: Vector2 = Vector2.ZERO
var stuck_threshold: float = 2.0  # Consider stuck if moved less than 2 pixels in 1 second

# UI elements
var waiting_bar: ProgressBar = null
var order_display: Control = null
var interact_prompt: Label = null

# Order combinations
static var EASY_ORDERS = [
	["fries_drink"],  # Fries + any drink
	["donut"],
	["icecream"],
	["sunny_sideup"]
]

static var HARD_ORDERS = [
	["taco"],
	["pizza"]
]

var is_restoring: bool = false  # Flag to prevent order generation during restore

func set_is_restoring(value: bool):
	is_restoring = value

func _ready():
	add_to_group("customers")
	
	# Set z_index same as player
	z_index = 2  # Same as player
	
	# Only generate order if not restoring (restore will set order_items)
	if not is_restoring or order_items.is_empty():
		generate_order()
	
	create_ui_elements()
	
	# Set up collision - customers should collide with walls but NOT tables or other customers
	collision_layer = 2  # Customers are on layer 2
	collision_mask = 1  # Customers collide with layer 1 (walls, TileMap) but NOT tables or other customers
	
	# If no seat position is set, use current position as seat
	if target_seat_position == Vector2.ZERO:
		target_seat_position = global_position
	
	# If no entrance position is set, start at current position
	if entrance_position == Vector2.ZERO:
		entrance_position = global_position
		# If starting at seat, skip walking (this is for restored customers)
		customer_state = CustomerState.WAITING_FOR_ORDER
	else:
		# Start at entrance and walk to seat (initial arrival)
		# Ensure entrance position is valid (not outside restaurant)
		global_position = entrance_position
		customer_state = CustomerState.WALKING_TO_SEAT
	
	# Set exit position (default to entrance)
	if exit_position == Vector2.ZERO:
		exit_position = entrance_position
	
	# Add Area2D for interaction
	var area = Area2D.new()
	area.name = "InteractionArea"
	area.collision_layer = 0
	area.collision_mask = 1  # Detect player
	
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(24, 24)
	collision_shape.shape = shape
	collision_shape.position = Vector2(0, -10)
	
	area.add_child(collision_shape)
	add_child(area)
	
	area.body_entered.connect(_on_player_entered)
	area.body_exited.connect(_on_player_exited)
	
	# Start animation - will be updated when facing direction is set
	if has_node("AnimatedSprite2D"):
		# Don't set animation here, let it be set when facing direction is applied
		pass

func _physics_process(delta):
	# Reset stuck timer if we're not walking
	if customer_state != CustomerState.WALKING_TO_SEAT and customer_state != CustomerState.WALKING_TO_EXIT:
		stuck_timer = 0.0
		last_position = global_position
	
	# Handle movement
	if customer_state == CustomerState.WALKING_TO_SEAT:
		move_towards_target(target_seat_position, delta)
		if global_position.distance_to(target_seat_position) <= arrival_threshold:
			# Arrived at seat
			global_position = target_seat_position
			customer_state = CustomerState.WAITING_FOR_ORDER
			
			# Play bell sound to notify player that a customer has arrived
			# Only play for the first customer of a party to avoid multiple bells
			if is_first_in_party:
				AudioManager.play_bell()
			
			# Restore saved facing direction when arriving at seat - ALWAYS prioritize saved facing
			if saved_facing_direction != "":
				current_dir = saved_facing_direction
				print("Customer arrived at seat, restoring facing direction: ", saved_facing_direction)
			else:
				# If no saved facing, try to get it from table
				if assigned_table and assigned_table.has_method("get_customer_facing"):
					var facing = assigned_table.get_customer_facing(self)
					if facing != "":
						current_dir = facing
						saved_facing_direction = facing
						print("Customer: Got facing direction from table: ", facing)
			
			# Convert up/down to left/right based on seat position relative to table
			# When seated, customers should always face left or right (side animations)
			if assigned_table:
				var table_pos = assigned_table.global_position
				var seat_pos = global_position
				# If facing up/down, convert to left/right based on position
				if current_dir == "up" or current_dir == "down":
					# Determine if customer is on left or right side of table
					if seat_pos.x < table_pos.x:
						current_dir = "right"  # On left side, face right (towards table)
					else:
						current_dir = "left"  # On right side, face left (towards table)
					saved_facing_direction = current_dir
					print("Customer: Converted facing from up/down to: ", current_dir, " based on seat position")
			
			# Force update animation immediately with correct facing
			play_animation(0)  # Idle animation with correct facing
			# Also ensure it's applied in the next frame
			call_deferred("play_animation", 0)
			if waiting_bar:
				waiting_bar.visible = true
	
	elif customer_state == CustomerState.WALKING_TO_EXIT:
		move_towards_target(exit_position, delta)
		if global_position.distance_to(exit_position) <= arrival_threshold:
			# Arrived at exit, remove customer
			customer_state = CustomerState.LEAVING
			queue_free()
	
	# Handle timers
	if customer_state == CustomerState.WAITING_FOR_ORDER:
		waiting_time += delta
		if waiting_bar:
			var progress = 1.0 - (waiting_time / max_waiting_time)
			waiting_bar.value = progress * 100.0
			if progress <= 0:
				# Customer leaves if order not taken
				AudioManager.play_angry_grunt()
				start_leaving()
	
	elif customer_state == CustomerState.ORDER_TAKEN:
		patience_time += delta
		if waiting_bar:
			var progress = 1.0 - (patience_time / max_patience_time)
			waiting_bar.value = progress * 100.0
			if progress <= 0:
				# Customer leaves if order not fulfilled in time (only if still waiting)
				# Don't leave if order is partially fulfilled - they should wait for all items
				if order_items.size() > 0:
					# For parties, check if all table customers can leave together
					if party_size > 1 and assigned_table:
						# If all table customers are also out of patience, they can all leave
						if all_table_customers_out_of_patience():
							AudioManager.play_angry_grunt()
							start_leaving()
					else:
						AudioManager.play_angry_grunt()
						start_leaving()
	elif customer_state == CustomerState.SATISFIED:
		# If satisfied but waiting for party members, periodically check if all are satisfied
		if party_size > 1 and assigned_table:
			if all_table_customers_satisfied():
				# All party members are satisfied, can leave now
				if not (customer_state == CustomerState.WALKING_TO_EXIT or customer_state == CustomerState.LEAVING):
					start_leaving()

func _process(delta):
	# Empty - timers moved to _physics_process
	pass

func generate_order():
	# For parties of 3 or more, only use easy orders (no pizza/tacos)
	var is_hard = false
	if party_size >= 3:
		is_hard = false  # Force easy orders for 3+ people
	else:
		is_hard = randf() < 0.1  # 10% chance for hard order for 1-2 people (seldom)
	
	var order_type = ""
	if is_hard:
		order_type = HARD_ORDERS[randi() % HARD_ORDERS.size()][0]
	else:
		order_type = EASY_ORDERS[randi() % EASY_ORDERS.size()][0]
	
	# Convert order type to item IDs
	match order_type:
		"fries_drink":
			# Fries + random drink (Cola or Fruit)
			order_items = [
				ItemTypes.ItemType.FRIES,
				ItemTypes.ItemType.COLA if randf() < 0.5 else ItemTypes.ItemType.FRUIT
			]
		"donut":
			order_items = [ItemTypes.ItemType.DONUTS]
		"icecream":
			order_items = [ItemTypes.ItemType.ICECREAM]
		"sunny_sideup":
			order_items = [ItemTypes.ItemType.SUNNY_SIDEUP_EGG]
		"taco":
			order_items = [ItemTypes.ItemType.TACO]
		"pizza":
			order_items = [ItemTypes.ItemType.PIZZA]
	
	print("Customer order generated: ", order_items)

func create_ui_elements():
	# Create order display (shown after order is taken) - positioned higher
	order_display = Control.new()
	order_display.name = "OrderDisplay"
	order_display.custom_minimum_size = Vector2(64, 32)
	order_display.position = Vector2(-32, -45)  # Higher position, above customer
	order_display.visible = false
	order_display.z_index = 10
	
	# Create a nicer background with border
	var order_bg = ColorRect.new()
	order_bg.name = "OrderBG"
	order_bg.color = Color(0.1, 0.1, 0.1, 0.95)  # Darker, more opaque
	order_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	order_display.add_child(order_bg)
	
	# Add a border effect
	var border = ColorRect.new()
	border.name = "Border"
	border.color = Color(0.8, 0.8, 0.8, 0.9)  # Light border
	border.set_anchors_preset(Control.PRESET_FULL_RECT)
	border.offset_left = -2
	border.offset_top = -2
	border.offset_right = 2
	border.offset_bottom = 2
	border.z_index = -1
	order_display.add_child(border)
	
	var order_grid = GridContainer.new()
	order_grid.name = "OrderGrid"
	order_grid.columns = 2
	order_grid.set_anchors_preset(Control.PRESET_FULL_RECT)
	order_grid.offset_left = 6
	order_grid.offset_top = 6
	order_grid.offset_right = -6
	order_grid.offset_bottom = -6
	order_grid.add_theme_constant_override("h_separation", 4)
	order_grid.add_theme_constant_override("v_separation", 4)
	order_display.add_child(order_grid)
	
	add_child(order_display)
	
	# Create waiting bar - positioned ABOVE customer initially, will move above order when taken
	waiting_bar = ProgressBar.new()
	waiting_bar.name = "WaitingBar"
	waiting_bar.custom_minimum_size = Vector2(60, 3)  # Slightly bigger bar (3px height, 60px width)
	waiting_bar.max_value = 100.0
	waiting_bar.value = 100.0
	waiting_bar.position = Vector2(-30, -50)  # Above customer initially
	waiting_bar.z_index = 10
	waiting_bar.show_percentage = false  # Hide percentage text
	
	# Style the progress bar - super thin and simple
	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	style_bg.border_color = Color(1, 1, 1, 1)
	style_bg.border_width_left = 1
	style_bg.border_width_right = 1
	style_bg.border_width_top = 1
	style_bg.border_width_bottom = 1
	waiting_bar.add_theme_stylebox_override("background", style_bg)
	
	var style_fill = StyleBoxFlat.new()
	style_fill.bg_color = Color(0, 1, 0, 0.9)  # Green when full
	waiting_bar.add_theme_stylebox_override("fill", style_fill)
	
	add_child(waiting_bar)
	
	# Create interact prompt
	interact_prompt = Label.new()
	interact_prompt.name = "InteractPrompt"
	interact_prompt.text = "[E]"
	interact_prompt.add_theme_font_size_override("font_size", 8)
	interact_prompt.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	interact_prompt.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	interact_prompt.add_theme_constant_override("outline_size", 1)
	interact_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interact_prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	interact_prompt.position = Vector2(-10, -25)
	interact_prompt.visible = false
	interact_prompt.z_index = 10
	add_child(interact_prompt)

func show_order_display():
	if not order_display:
		return
	
	order_display.visible = true
	update_order_display()

func update_order_display():
	# Update the order display to show current remaining items
	if not order_display:
		return
	
	var order_grid = order_display.get_node("OrderGrid")
	
	# Clear existing items
	for child in order_grid.get_children():
		child.queue_free()
	
	# Add remaining order items
	for item_type in order_items:
		var texture_path = ItemTypes.get_item_texture_path(item_type)
		if texture_path != "" and ResourceLoader.exists(texture_path):
			var texture = load(texture_path)
			if texture:
				var texture_rect = TextureRect.new()
				texture_rect.texture = texture
				texture_rect.custom_minimum_size = Vector2(16, 16)
				texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				order_grid.add_child(texture_rect)

func take_order(player: Node):
	if customer_state != CustomerState.WAITING_FOR_ORDER:
		return false
	
	customer_state = CustomerState.ORDER_TAKEN
	waiting_time = 0.0
	patience_time = 0.0
	
	# Play order taken sound (pencil writing)
	AudioManager.play_order_taken()
	
	# Update waiting bar color to yellow (patience) and move above order
	if waiting_bar:
		var style_fill = StyleBoxFlat.new()
		style_fill.bg_color = Color(1, 1, 0, 0.8)  # Yellow
		waiting_bar.add_theme_stylebox_override("fill", style_fill)
		# Move bar above order display (order is at -45, so bar should be at -60)
		waiting_bar.position = Vector2(-30, -60)
	
	show_order_display()
	hide_interact_prompt()
	
	print("Order taken! Customer wants: ", order_items)
	return true

func check_order_fulfilled(player: Node) -> bool:
	if customer_state != CustomerState.ORDER_TAKEN:
		return false
	
	# Check if player has the required items
	if not player.has_item():
		return false
	
	var player_item = player.held_item
	
	# Check if player has any item from the order
	# For combo orders (like fries + drink), we'll accept either item
	# For single item orders, player must have that exact item
	if player_item in order_items:
		# Order fulfilled!
		fulfill_order(player)
		return true
	
	return false

func fulfill_order(player: Node):
	# Remove item from player and from order list
	if player.has_item():
		var player_item = player.held_item
		if player_item in order_items:
			# Remove the item from the order list
			var item_index = order_items.find(player_item)
			if item_index >= 0:
				order_items.remove_at(item_index)
				player.set_held_item(-1)
				print("Customer received: ", ItemTypes.get_item_name(player_item), ". Remaining items: ", order_items)
			
			# Update order display to show remaining items
			update_order_display()
			
			# Check if order is completely fulfilled
			if order_items.is_empty():
				# All items fulfilled! Mark as satisfied
				customer_state = CustomerState.SATISFIED
				print("Order completely fulfilled! Customer is satisfied.")
				
				# Play money sound for satisfied customer
				AudioManager.play_money()
				
				# Hide UI
				if waiting_bar:
					waiting_bar.visible = false
				if order_display:
					order_display.visible = false
				
				# Check if all customers at the table are satisfied (for parties)
				if party_size > 1 and assigned_table:
					# Wait for all party members to be satisfied
					if all_table_customers_satisfied():
						print("All customers at table are satisfied. Party can leave.")
						# All customers at table are satisfied, everyone can leave
						await get_tree().create_timer(1.0).timeout
						start_leaving()
					else:
						print("Waiting for other party members to finish their orders...")
						# Don't leave yet, wait for others
				else:
					# Single customer, can leave immediately
					await get_tree().create_timer(1.0).timeout
					start_leaving()
			else:
				# Still waiting for more items
				print("Customer still waiting for: ", order_items)

func all_table_customers_satisfied() -> bool:
	# Check if all customers at this table are satisfied
	if not assigned_table:
		return true  # No table, can leave
	
	if not assigned_table.has_method("get_customers"):
		return true  # Table doesn't have get_customers method, assume can leave
	
	var table_customers = assigned_table.get_customers()
	if table_customers.is_empty():
		return true
	
	# Check if all customers at the table are satisfied
	for customer in table_customers:
		if customer == self:
			continue  # Skip self
		if not customer.has_method("is_satisfied"):
			continue
		if not customer.is_satisfied():
			return false  # At least one customer is not satisfied
	
	return true  # All customers are satisfied

func is_satisfied() -> bool:
	return customer_state == CustomerState.SATISFIED

func all_table_customers_out_of_patience() -> bool:
	# Check if all customers at this table are out of patience
	if not assigned_table:
		return true
	
	if not assigned_table.has_method("get_customers"):
		return true
	
	var table_customers = assigned_table.get_customers()
	if table_customers.is_empty():
		return true
	
	# Check if all customers at the table are out of patience
	for customer in table_customers:
		if customer == self:
			continue  # Skip self
		if not customer.has_method("is_out_of_patience"):
			continue
		if not customer.is_out_of_patience():
			return false  # At least one customer still has patience
	
	return true  # All customers are out of patience

func is_out_of_patience() -> bool:
	return customer_state == CustomerState.ORDER_TAKEN and patience_time >= max_patience_time

var saved_facing_direction: String = ""  # Save the facing direction from table assignment

func move_towards_target(target: Vector2, delta: float):
	var direction = (target - global_position).normalized()
	var distance = global_position.distance_to(target)
	
	if distance > arrival_threshold:
		# Check for obstacles (tables) and steer around them
		var adjusted_direction = avoid_obstacles(direction, target)
		velocity = adjusted_direction * CUSTOMER_SPEED
		
		# Update direction for animation (only while walking, don't override saved facing)
		if abs(adjusted_direction.x) > abs(adjusted_direction.y):
			current_dir = "right" if adjusted_direction.x > 0 else "left"
		else:
			current_dir = "down" if adjusted_direction.y > 0 else "up"
		
		play_animation(1)  # Walking animation
		
		# Move and check if we actually moved
		var before_move = global_position
		move_and_slide()
		var after_move = global_position
		
		# Clamp position to restaurant boundaries to prevent going outside
		# This ensures customers stay inside even if pushed by other customers or obstacles
		# Use same boundaries as player movement
		# BUT: Allow customers to go outside when leaving (WALKING_TO_EXIT)
		if customer_state != CustomerState.WALKING_TO_EXIT:
			global_position.x = clamp(global_position.x, -250.0, 500.0)
			global_position.y = clamp(global_position.y, -200.0, 200.0)
		
		# If we didn't move much, we might be stuck - try different directions
		if before_move.distance_to(after_move) < 1.0:
			stuck_timer += delta
			if stuck_timer > 0.3:
				# Try multiple escape directions
				var escape_directions = [
					Vector2(-adjusted_direction.y, adjusted_direction.x),  # Perpendicular left
					Vector2(adjusted_direction.y, -adjusted_direction.x),  # Perpendicular right
					Vector2(-adjusted_direction.x, -adjusted_direction.y),  # Opposite
					Vector2(1, 0),  # Right
					Vector2(-1, 0),  # Left
					Vector2(0, 1),  # Down
					Vector2(0, -1)   # Up
				]
				
				# Try each direction until one works
				var escape_index = int(stuck_timer * 2) % escape_directions.size()
				var escape_dir = escape_directions[escape_index].normalized()
				velocity = escape_dir * CUSTOMER_SPEED * 1.5  # Move faster to escape
				move_and_slide()
				# Clamp again after escape movement (but allow leaving)
				if customer_state != CustomerState.WALKING_TO_EXIT:
					global_position.x = clamp(global_position.x, -250.0, 500.0)
					global_position.y = clamp(global_position.y, -200.0, 200.0)
		else:
			# Reset stuck timer if we're moving
			stuck_timer = 0.0
	else:
		velocity = Vector2.ZERO
		# Restore saved facing direction when close to target (but not yet arrived)
		# This ensures we face the correct direction before arriving
		if saved_facing_direction != "":
			current_dir = saved_facing_direction
			play_animation(0)  # Idle animation with correct facing

func avoid_obstacles(direction: Vector2, target: Vector2) -> Vector2:
	# Check if we're stuck (not moving)
	var distance_moved = global_position.distance_to(last_position)
	if distance_moved < stuck_threshold:
		stuck_timer += get_physics_process_delta_time()
	else:
		stuck_timer = 0.0
	last_position = global_position
	
	# If stuck for more than 0.5 seconds, try to unstick by going directly toward target
	if stuck_timer > 0.5:
		var direct_to_target = (target - global_position).normalized()
		# Try a more direct path, ignoring obstacles temporarily
		# Also try moving perpendicular to current direction to escape
		var escape_dir = Vector2(-direction.y, direction.x)  # Perpendicular
		return (direct_to_target + escape_dir * 0.3).normalized()
	
	# Always check for obstacles, but be smarter about it
	var distance_to_target = global_position.distance_to(target)
	
	# Check for tables in the path - use multiple raycasts
	var check_distance = 60.0  # Check further ahead
	var tables = get_tree().get_nodes_in_group("tables")
	var closest_obstacle = null
	var closest_distance = check_distance + 20.0
	var obstacle_blocking = false
	
	# Check multiple points along the path
	for i in range(3):
		var check_dist = 30.0 + (i * 20.0)  # Check at 30, 50, 70 pixels ahead
		var check_pos = global_position + direction * check_dist
		
		for table in tables:
			var table_pos = table.global_position
			var distance_to_table = global_position.distance_to(table_pos)
			var distance_to_path = point_to_line_distance(table_pos, global_position, check_pos)
			
			# If table is blocking the path
			if distance_to_path < 50.0 and distance_to_table < closest_distance:
				var to_table = (table_pos - global_position).normalized()
				var to_target = (target - global_position).normalized()
				
				# Check if table is between us and target
				var table_angle = direction.angle_to(to_table)
				var target_angle = direction.angle_to(to_target)
				
				# If table is in front and closer than target
				if abs(table_angle) < 1.5 and distance_to_table < distance_to_target:
					closest_obstacle = table
					closest_distance = distance_to_table
					obstacle_blocking = true
					break
		
		if obstacle_blocking:
			break
	
	if closest_obstacle:
		# Obstacle detected, steer around it more aggressively
		var to_obstacle = (closest_obstacle.global_position - global_position).normalized()
		# Steer perpendicular to the obstacle
		var steer = Vector2(-to_obstacle.y, to_obstacle.x)  # Perpendicular vector
		
		# Choose the steering direction that's closer to the target
		var to_target = (target - global_position).normalized()
		var left_steer = steer
		var right_steer = -steer
		
		# More aggressive steering when close to obstacle
		var steer_strength = 0.8 if closest_distance < 40.0 else 0.6
		
		if left_steer.dot(to_target) > right_steer.dot(to_target):
			# Steer left (relative to obstacle)
			return (direction + left_steer * steer_strength).normalized()
		else:
			# Steer right (relative to obstacle)
			return (direction + right_steer * steer_strength).normalized()
	
	# No obstacle, use original direction
	return direction

func point_to_line_distance(point: Vector2, line_start: Vector2, line_end: Vector2) -> float:
	# Calculate distance from a point to a line segment
	var line = line_end - line_start
	var line_length = line.length()
	if line_length < 0.001:
		return point.distance_to(line_start)
	
	var t = clamp((point - line_start).dot(line) / (line_length * line_length), 0.0, 1.0)
	var projection = line_start + line * t
	return point.distance_to(projection)

func play_animation(movement: int):
	if not has_node("AnimatedSprite2D"):
		return
	
	var anim = $AnimatedSprite2D
	
	match current_dir:
		"right":
			anim.flip_h = false  # Face right (normal, not flipped)
			anim.play("side_run" if movement == 1 else "side_idle")
		"left":
			anim.flip_h = true  # Face left (flipped)
			anim.play("side_run" if movement == 1 else "side_idle")
		"down":
			anim.flip_h = false
			anim.play("front_run" if movement == 1 else "front_idle")
		"up":
			anim.flip_h = false
			anim.play("back_run" if movement == 1 else "back_idle")
		_:
			anim.flip_h = false
			anim.play("front_idle")

func start_leaving():
	if customer_state == CustomerState.LEAVING or customer_state == CustomerState.WALKING_TO_EXIT:
		return
	
	# Play sound based on why customer is leaving (check before changing state)
	var was_satisfied = (customer_state == CustomerState.SATISFIED)
	
	customer_state = CustomerState.WALKING_TO_EXIT
	
	# Play sound based on why customer is leaving
	if not was_satisfied:
		# Customer leaving due to timeout/anger (not satisfied)
		AudioManager.play_angry_grunt()
	# If satisfied, money sound was already played in fulfill_order
	
	# Notify table that customer is leaving
	if assigned_table and assigned_table.has_method("remove_customer"):
		assigned_table.remove_customer(self)
	
	# Notify customer manager
	var manager = get_tree().get_first_node_in_group("customer_manager")
	if manager and manager.has_method("on_customer_left"):
		manager.on_customer_left(self)
	
	# Hide all UI
	if waiting_bar:
		waiting_bar.visible = false
	if order_display:
		order_display.visible = false
	if interact_prompt:
		interact_prompt.visible = false

func leave_customer():
	start_leaving()

func _on_player_entered(body):
	if body.is_in_group("player"):
		if customer_state == CustomerState.WAITING_FOR_ORDER:
			show_interact_prompt()
		elif customer_state == CustomerState.ORDER_TAKEN:
			# Show interact prompt to serve food
			show_interact_prompt()
			# Also check if player can fulfill order immediately
			check_order_fulfilled(body)

func _on_player_exited(body):
	if body.is_in_group("player"):
		hide_interact_prompt()

func show_interact_prompt():
	if interact_prompt:
		interact_prompt.visible = true

func hide_interact_prompt():
	if interact_prompt:
		interact_prompt.visible = false

func interact(player: Node):
	if customer_state == CustomerState.WAITING_FOR_ORDER:
		take_order(player)
	elif customer_state == CustomerState.ORDER_TAKEN:
		check_order_fulfilled(player)

# Public methods to set positions (call these when instancing the customer)
func set_entrance_position(pos: Vector2):
	entrance_position = pos

func set_seat_position(pos: Vector2):
	target_seat_position = pos

func set_exit_position(pos: Vector2):
	exit_position = pos

func set_facing_direction(dir: String):
	current_dir = dir
	saved_facing_direction = dir  # Save it so it's restored when arriving at seat
	print("Customer: Set facing direction to: ", dir, " (saved: ", saved_facing_direction, ")")
	# Update animation immediately
	play_animation(0)  # Idle animation with correct facing

func set_table(table: Node):
	assigned_table = table

var npc_sprite_index: int = -1  # Store the sprite index for restoration

func get_customer_state() -> Dictionary:
	# Get table identifier for restoration (use table's name or position)
	var table_id = ""
	if assigned_table:
		# Use table's name as identifier
		table_id = assigned_table.name
	
	# Find which seat index this customer was at
	var seat_index = -1
	if assigned_table and assigned_table.has_method("get_customer_seat_index"):
		seat_index = assigned_table.get_customer_seat_index(self)
	
	return {
		"order_items": order_items.duplicate(),
		"customer_state": customer_state,
		"waiting_time": waiting_time,
		"patience_time": patience_time,
		"seat_position": target_seat_position,
		"entrance_position": entrance_position,
		"exit_position": exit_position,
		"table_id": table_id,
		"seat_index": seat_index,  # Save which seat they were at
		"party_size": party_size,
		"facing_direction": current_dir,
		"npc_sprite_index": npc_sprite_index  # Save the sprite index
	}

func restore_customer_state(state: Dictionary, elapsed_time: float = 0.0):
	# Restore order items first (before anything else)
	var saved_order = state.get("order_items", [])
	if saved_order.size() > 0:
		order_items = saved_order.duplicate()
		print("Customer: Restored order items: ", order_items)
	
	customer_state = state.get("customer_state", CustomerState.WAITING_FOR_ORDER)
	# Restore timers and add elapsed time (time passed while player was in kitchen)
	waiting_time = state.get("waiting_time", 0.0) + elapsed_time
	patience_time = state.get("patience_time", 0.0) + elapsed_time
	print("Customer: Restored timers - waiting_time: ", waiting_time, " patience_time: ", patience_time, " (added ", elapsed_time, " seconds)")
	target_seat_position = state.get("seat_position", Vector2.ZERO)
	entrance_position = state.get("entrance_position", Vector2.ZERO)
	exit_position = state.get("exit_position", Vector2.ZERO)
	party_size = state.get("party_size", 1)
	
	# Restore position
	global_position = target_seat_position
	
	# Restore facing direction
	var saved_facing = state.get("facing_direction", "down")
	if saved_facing != "":
		current_dir = saved_facing
		saved_facing_direction = saved_facing  # Also restore saved facing
		print("Customer: Restored facing direction: ", saved_facing)
	else:
		# If no saved facing, try to get it from table
		if assigned_table and assigned_table.has_method("get_customer_facing"):
			var facing = assigned_table.get_customer_facing(self)
			if facing != "":
				current_dir = facing
				saved_facing_direction = facing
				print("Customer: Got facing direction from table during restore: ", facing)
	
	# Convert up/down to left/right when seated (customers should always use side animations when seated)
	if assigned_table and (customer_state == CustomerState.WAITING_FOR_ORDER or customer_state == CustomerState.ORDER_TAKEN):
		var table_pos = assigned_table.global_position
		var seat_pos = global_position
		# If facing up/down, convert to left/right based on position
		if current_dir == "up" or current_dir == "down":
			# Determine if customer is on left or right side of table
			if seat_pos.x < table_pos.x:
				current_dir = "right"  # On left side, face right (towards table)
			else:
				current_dir = "left"  # On right side, face left (towards table)
			saved_facing_direction = current_dir
			print("Customer: Converted facing from up/down to: ", current_dir, " based on seat position (restore)")
	
	# Update animation with correct facing direction immediately
	# Force update multiple times to ensure it sticks
	if has_node("AnimatedSprite2D"):
		play_animation(0)
		# Also update in next frame to ensure it's applied
		call_deferred("play_animation", 0)
	
	# Restore UI based on state
	if customer_state == CustomerState.WAITING_FOR_ORDER:
		if waiting_bar:
			var progress = 1.0 - (waiting_time / max_waiting_time)
			waiting_bar.value = progress * 100.0
			waiting_bar.visible = true
			# Bar above customer
			waiting_bar.position = Vector2(-30, -50)
	elif customer_state == CustomerState.ORDER_TAKEN:
		if waiting_bar:
			var progress = 1.0 - (patience_time / max_patience_time)
			waiting_bar.value = progress * 100.0
			waiting_bar.visible = true
			# Update bar color to yellow and move above order
			var style_fill = StyleBoxFlat.new()
			style_fill.bg_color = Color(1, 1, 0, 0.8)  # Yellow
			waiting_bar.add_theme_stylebox_override("fill", style_fill)
			# Bar above order display
			waiting_bar.position = Vector2(-30, -60)
		show_order_display()
	
	# Restore animation with correct facing direction
	play_animation(0)  # Idle animation
