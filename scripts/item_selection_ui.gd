extends CanvasLayer

var available_items: Array = []
var station: Node = null
var player: Node = null

func setup(items: Array, station_node: Node):
	available_items = items
	station = station_node

func show_selection(items: Array, player_node: Node):
	available_items = items
	player = player_node
	visible = true
	populate_items()

func populate_items():
	var grid = $Control/VBoxContainer/ItemGrid
	
	# Clear existing items
	for child in grid.get_children():
		child.queue_free()
	
	# Create item buttons
	for item_type in available_items:
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
					# Fit within 48x48 with 6px padding for better visibility
					texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
					texture_rect.offset_left = 6
					texture_rect.offset_top = 6
					texture_rect.offset_right = -6
					texture_rect.offset_bottom = -6
					button.add_child(texture_rect)
		
		# Add tooltip
		button.tooltip_text = ItemTypes.get_item_name(item_type)
		
		# Connect button signal
		button.pressed.connect(_on_item_selected.bind(item_type))
		
		grid.add_child(button)

func _on_item_selected(item_type: int):
	if player and station:
		if station.has_method("give_item_to_player"):
			station.give_item_to_player(player, item_type)
	visible = false

func _ready():
	$Control/VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)

func _on_close_pressed():
	visible = false

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false
