extends Control

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("#14222d")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var title := Label.new()
	title.text = "RESTAURANT EMPIRE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(title)

	print("Restaurant Empire boot OK")
	await get_tree().create_timer(0.25).timeout
	if DataManager.validation_errors.is_empty():
		SceneManager.go_to("menu")
