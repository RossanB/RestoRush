extends CanvasLayer

var stored_items: Array[int] = []
var station: Node = null
var player: Node = null
var process_button_text: String = "Process"
var selected_item_index: int = -1
var remove_button: Button = null

func setup(items: Array[int], station_node: Node, player_node: Node, button_text: String = "Process"):
	stored_items = items
	station = station_node
	player = player_node
	process_button_text = button_text

func show_processing(items: Array[int], station_node: Node, player_node: Node, button_text: String = "Process"):
	stored_items = items
	station = station_node
	player = player_node
	process_button_text = button_text
	visible = true
	populate_items()

func populate_items():
	var grid = $Control/VBoxContainer/ItemGrid
	var process_button = $Control/VBoxContainer/ProcessButton
	
	# Update process button text
	process_button.text = process_button_text
	
	# Clear existing items
	for child in grid.get_children():
		child.queue_free()
	
	# Hide remove button initially
	if remove_button:
		remove_button.visible = false
	selected_item_index = -1
	
	# Create item displays (clickable buttons)
	for i in range(stored_items.size()):
		var item_type = stored_items[i]
		var button = Button.new()
		button.custom_minimum_size = Vector2(48, 48)
		# Style the button
		var button_style = StyleBoxFlat.new()
		button_style.bg_color = Color(0.25, 0.25, 0.3, 1)
		button_style.border_width_left = 1
		button_style.border_width_top = 1
		button_style.border_width_right = 1
		button_style.border_width_bottom = 1
		button_style.border_color = Color(0.5, 0.4, 0.3, 1)
		button_style.corner_radius_top_left = 2
		button_style.corner_radius_top_right = 2
		button_style.corner_radius_bottom_right = 2
		button_style.corner_radius_bottom_left = 2
		button.add_theme_stylebox_override("normal", button_style)
		
		var button_hover_style = StyleBoxFlat.new()
		button_hover_style.bg_color = Color(0.35, 0.35, 0.4, 1)
		button_hover_style.border_width_left = 1
		button_hover_style.border_width_top = 1
		button_hover_style.border_width_right = 1
		button_hover_style.border_width_bottom = 1
		button_hover_style.border_color = Color(0.8, 0.6, 0.4, 1)
		button_hover_style.corner_radius_top_left = 2
		button_hover_style.corner_radius_top_right = 2
		button_hover_style.corner_radius_bottom_right = 2
		button_hover_style.corner_radius_bottom_left = 2
		button.add_theme_stylebox_override("hover", button_hover_style)
		button.add_theme_stylebox_override("pressed", button_hover_style)
		
		# Load item texture
		var texture_path = ItemTypes.get_item_texture_path(item_type)
		if texture_path != "":
			if not ResourceLoader.exists(texture_path):
				print("Warning: Texture file not found: ", texture_path, " for item: ", ItemTypes.get_item_name(item_type))
			else:
				var texture = load(texture_path)
				if texture:
					var texture_rect = TextureRect.new()
					texture_rect.texture = texture
					texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
					texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
					texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
					# Fit within 48x48 with 10px padding to prevent overflow
					texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
					texture_rect.offset_left = 10
					texture_rect.offset_top = 10
					texture_rect.offset_right = -10
					texture_rect.offset_bottom = -10
					button.add_child(texture_rect)
		
		# Add tooltip
		button.tooltip_text = ItemTypes.get_item_name(item_type)
		
		# Connect button signal to select item
		button.pressed.connect(_on_item_clicked.bind(i))
		
		grid.add_child(button)
	
	# Enable/disable process button based on whether there are items
	process_button.disabled = stored_items.is_empty()

func _on_item_clicked(item_index: int):
	selected_item_index = item_index
	# Show remove button
	if not remove_button:
		create_remove_button()
	remove_button.visible = true
	remove_button.text = "Remove " + ItemTypes.get_item_name(stored_items[item_index])

func create_remove_button():
	var vbox = $Control/VBoxContainer
	remove_button = Button.new()
	remove_button.text = "Remove Item"
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.5, 0.2, 0.2, 1)
	button_style.border_width_left = 2
	button_style.border_width_top = 2
	button_style.border_width_right = 2
	button_style.border_width_bottom = 2
	button_style.border_color = Color(0.8, 0.4, 0.4, 1)
	button_style.corner_radius_top_left = 2
	button_style.corner_radius_top_right = 2
	button_style.corner_radius_bottom_right = 2
	button_style.corner_radius_bottom_left = 2
	remove_button.add_theme_stylebox_override("normal", button_style)
	
	var button_hover_style = StyleBoxFlat.new()
	button_hover_style.bg_color = Color(0.6, 0.3, 0.3, 1)
	button_hover_style.border_width_left = 2
	button_hover_style.border_width_top = 2
	button_hover_style.border_width_right = 2
	button_hover_style.border_width_bottom = 2
	button_hover_style.border_color = Color(1.0, 0.5, 0.5, 1)
	button_hover_style.corner_radius_top_left = 2
	button_hover_style.corner_radius_top_right = 2
	button_hover_style.corner_radius_bottom_right = 2
	button_hover_style.corner_radius_bottom_left = 2
	remove_button.add_theme_stylebox_override("hover", button_hover_style)
	remove_button.add_theme_stylebox_override("pressed", button_hover_style)
	remove_button.add_theme_font_size_override("font_size", 12)
	remove_button.add_theme_color_override("font_color", Color(1, 0.9, 0.7, 1))
	
	# Insert before CloseButton
	var close_button = $Control/VBoxContainer/CloseButton
	var close_index = vbox.get_child_index(close_button)
	vbox.add_child(remove_button)
	vbox.move_child(remove_button, close_index)
	remove_button.pressed.connect(_on_remove_pressed)
	remove_button.visible = false

func _on_remove_pressed():
	if selected_item_index >= 0 and selected_item_index < stored_items.size() and player and station:
		var item_to_remove = stored_items[selected_item_index]
		# Give item back to player
		if not player.has_item():
			player.set_held_item(item_to_remove)
			# Remove from station's stored items directly (arrays are passed by reference, but be explicit)
			if "stored_items" in station:
				station.stored_items.remove_at(selected_item_index)
			# Update local stored_items to match
			stored_items.remove_at(selected_item_index)
			# Refresh UI
			populate_items()

func _on_process_pressed():
	if station and station.has_method("process_items"):
		station.process_items(player)
	visible = false

func _ready():
	$Control/VBoxContainer/ProcessButton.pressed.connect(_on_process_pressed)
	$Control/VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)

func _on_close_pressed():
	visible = false

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false

