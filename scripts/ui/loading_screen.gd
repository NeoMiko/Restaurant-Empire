extends Control

var dots := 0
var label: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = DataManager.color("background")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	label = Label.new()
	label.text = "Loading"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(label)
	var timer := Timer.new()
	timer.wait_time = 0.35
	timer.autostart = true
	timer.timeout.connect(func() -> void: dots = (dots + 1) % 4; label.text = "Loading" + ".".repeat(dots))
	add_child(timer)
