extends Control

func _ready() -> void:
	var background := ColorRect.new()
	background.color = DataManager.color("background")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var panel := PanelContainer.new()
	panel.position = Vector2(610, 150)
	panel.size = Vector2(700, 780)
	var style := StyleBoxFlat.new()
	style.bg_color = DataManager.color("panel")
	style.set_corner_radius_all(24)
	style.set_content_margin_all(48)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	panel.add_child(box)
	var title := Label.new()
	title.text = "RESTAURANT EMPIRE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 54)
	box.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Cook • Grow • Hire • Expand"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", DataManager.color("accent"))
	subtitle.add_theme_font_size_override("font_size", 24)
	box.add_child(subtitle)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 50
	box.add_child(spacer)
	box.add_child(_button("New Game", _new_game))
	var continue_button := _button("Continue", _continue_game)
	continue_button.disabled = not SaveManager.has_save()
	box.add_child(continue_button)
	box.add_child(_button("Settings", func() -> void: SceneManager.go_to("settings")))
	box.add_child(_button("Exit", func() -> void: SaveManager.save_game(); get_tree().quit()))
	SceneManager.current_scene_id = "menu"

func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(500, 82)
	button.add_theme_font_size_override("font_size", 28)
	button.pressed.connect(callback)
	return button

func _new_game() -> void:
	SaveManager.new_game()
	SceneManager.go_to("city")

func _continue_game() -> void:
	if SaveManager.load_game():
		SceneManager.go_to("city")
	else:
		EventBus.notification_requested.emit("Save could not be loaded", false)
