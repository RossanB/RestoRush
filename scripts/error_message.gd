extends CanvasLayer
class_name ErrorMessage

var error_label: Label = null
var display_timer: Timer = null

func _ready():
	# Create error label
	error_label = Label.new()
	error_label.text = ""
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	error_label.add_theme_font_size_override("font_size", 18)
	error_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))  # Red text
	error_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	error_label.add_theme_constant_override("outline_size", 3)
	
	# Position at top center of screen
	var control = Control.new()
	control.anchor_right = 1.0
	control.anchor_bottom = 1.0
	add_child(control)
	
	error_label.anchors_preset = Control.PRESET_TOP_WIDE
	error_label.offset_top = 50
	error_label.offset_bottom = 100
	error_label.visible = false
	control.add_child(error_label)
	
	# Create timer
	display_timer = Timer.new()
	display_timer.wait_time = 2.0
	display_timer.one_shot = true
	display_timer.timeout.connect(_on_timer_timeout)
	add_child(display_timer)

func display_error(message: String):
	error_label.text = message
	error_label.visible = true
	display_timer.start()

func _on_timer_timeout():
	error_label.visible = false
	error_label.text = ""

# Static helper to get or create error message UI
static func get_error_ui() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if not tree:
		return null
	
	var error_ui = tree.get_first_node_in_group("error_message")
	if not error_ui:
		# Create error message UI
		error_ui = preload("res://scenes/error_message.tscn").instantiate()
		error_ui.add_to_group("error_message")
		tree.root.add_child(error_ui)
	
	return error_ui

# Static function to show error message from anywhere
static func show_error(message: String):
	var ui = get_error_ui()
	if ui and ui.has_method("display_error"):
		ui.display_error(message)

