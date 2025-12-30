extends Control

@onready var fill: Panel = $Fill
@onready var label: Label = $Label

var progress: float = 0.0
var max_progress: float = 1.0

func _ready():
	visible = false
	z_index = 200  # Make sure progress bar is on top

func set_progress(value: float):
	progress = clamp(value, 0.0, max_progress)
	update_display()

func set_max_progress(value: float):
	max_progress = value
	update_display()

func set_label_text(text: String):
	label.text = text

func update_display():
	if max_progress > 0:
		var percentage = progress / max_progress
		fill.anchor_right = percentage
		fill.offset_right = 0

func show_progress():
	visible = true

func hide_progress():
	visible = false
	progress = 0.0
	update_display()



