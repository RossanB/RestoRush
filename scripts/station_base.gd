extends Area2D
class_name StationBase

@export var station_type: String = ""  # "fridge", "cabinet", "cutting_board", "oven", "stove", "sink", "mixer"

var interact_prompt: Label = null

func _ready():
	add_to_group("stations")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	create_interact_prompt()

func create_interact_prompt():
	# Create a label to show "[E]" prompt with pixel-style font
	interact_prompt = Label.new()
	interact_prompt.text = "[E]"
	interact_prompt.add_theme_font_size_override("font_size", 12)  # Smaller pixel-style size
	interact_prompt.add_theme_color_override("font_color", Color.WHITE)
	interact_prompt.add_theme_color_override("font_outline_color", Color.BLACK)
	interact_prompt.add_theme_constant_override("outline_size", 2)  # Smaller outline
	interact_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interact_prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	interact_prompt.position = Vector2(-20, -25)  # Position above the station, adjusted for "[E]"
	interact_prompt.visible = false
	interact_prompt.z_index = 100  # Make sure it's on top
	add_child(interact_prompt)

func _on_body_entered(body):
	# Show "E" prompt when player enters
	if body.is_in_group("player"):
		if interact_prompt:
			interact_prompt.visible = true

func _on_body_exited(body):
	# Hide "E" prompt when player leaves
	if body.is_in_group("player"):
		if interact_prompt:
			interact_prompt.visible = false

func show_interact_prompt():
	if interact_prompt:
		interact_prompt.visible = true

func hide_interact_prompt():
	if interact_prompt:
		interact_prompt.visible = false

func interact(player: Node):
	pass



