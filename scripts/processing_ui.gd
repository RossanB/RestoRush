extends CanvasLayer

var stored_items: Array[int] = []
var station: Node = null
var player: Node = null
var process_button_text: String = "Process"

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
	
	# Create item displays (non-interactive, just show what's stored)
	for item_type in stored_items:
		var container = Panel.new()
		container.custom_minimum_size = Vector2(50, 50)
		# Style the container
		var container_style = StyleBoxFlat.new()
		container_style.bg_color = Color(0.25, 0.25, 0.3, 1)
		container_style.border_width_left = 2
		container_style.border_width_top = 2
		container_style.border_width_right = 2
		container_style.border_width_bottom = 2
		container_style.border_color = Color(0.5, 0.4, 0.3, 1)
		container_style.corner_radius_top_left = 3
		container_style.corner_radius_top_right = 3
		container_style.corner_radius_bottom_right = 3
		container_style.corner_radius_bottom_left = 3
		container.add_theme_stylebox_override("panel", container_style)
		
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
					# Add padding so textures don't touch edges
					texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
					texture_rect.offset_left = 6
					texture_rect.offset_top = 6
					texture_rect.offset_right = -6
					texture_rect.offset_bottom = -6
					container.add_child(texture_rect)
		
		# Add tooltip
		container.tooltip_text = ItemTypes.get_item_name(item_type)
		
		grid.add_child(container)
	
	# Enable/disable process button based on whether there are items
	process_button.disabled = stored_items.is_empty()

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

