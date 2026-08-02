extends Control

var dots := 0
var label: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = DataManager.color("background")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 24)
	stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stack)
	stack.add_child(ArtManager.icon_rect("restaurant", Vector2(0, 280)))
	label = Label.new()
	label.text = "Loading"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	stack.add_child(label)
	var timer := Timer.new()
	timer.wait_time = 0.35
	timer.autostart = true
	timer.timeout.connect(func() -> void: dots = (dots + 1) % 4; label.text = "Loading" + ".".repeat(dots))
	add_child(timer)
