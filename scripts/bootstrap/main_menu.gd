extends Control

const SKYLINE := ["garden", "bazaar", "house", "office", "fairy", "shop", "progression"]

func _ready() -> void:
	add_child(_backdrop())
	add_child(_skyline())
	var panel := PanelContainer.new()
	panel.position = Vector2(610, 110)
	panel.size = Vector2(700, 860)
	var style := StyleBoxFlat.new()
	style.bg_color = DataManager.color("panel")
	style.set_corner_radius_all(24)
	style.set_content_margin_all(44)
	style.set_border_width_all(4)
	style.border_color = DataManager.color("outline")
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	var title := Label.new()
	title.text = "RESTAURANT EMPIRE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 54)
	box.add_child(title)
	box.add_child(ArtManager.icon_rect("restaurant", Vector2(0, 250)))
	var subtitle := Label.new()
	subtitle.text = "Cook • Grow • Hire • Expand"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", DataManager.color("accent"))
	subtitle.add_theme_font_size_override("font_size", 24)
	box.add_child(subtitle)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 28
	box.add_child(spacer)
	box.add_child(_button("New Game", _new_game, "ui_wax_seal_star"))
	var continue_button := _button("Continue", _continue_game, "toast_check")
	continue_button.disabled = not SaveManager.has_save()
	box.add_child(continue_button)
	box.add_child(_button("Settings", func() -> void: SceneManager.go_to("settings"), "btn_settings"))
	box.add_child(_button("Exit", func() -> void: SaveManager.save_game(); get_tree().quit(), "btn_close"))
	SceneManager.current_scene_id = "menu"

func _backdrop() -> TextureRect:
	var base := DataManager.color("background")
	var gradient := Gradient.new()
	gradient.set_color(0, base.lightened(0.12))
	gradient.set_color(1, base.darkened(0.35))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(0.0, 1.0)
	var backdrop := TextureRect.new()
	backdrop.texture = texture
	backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return backdrop

## Dimmed building art behind the menu panel, so the title screen previews the city.
func _skyline() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	row.offset_top = -320
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.modulate = Color(1.0, 1.0, 1.0, 0.28)
	for id in SKYLINE:
		row.add_child(ArtManager.icon_rect(id, Vector2(230, 230)))
	return row

func _button(text: String, callback: Callable, icon_id: String = "") -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(500, 82)
	button.add_theme_font_size_override("font_size", 28)
	button.pressed.connect(callback)
	if not icon_id.is_empty():
		ArtManager.apply_button_icon(button, icon_id, 48)
	return button

func _new_game() -> void:
	SaveManager.new_game()
	SceneManager.go_to("city")

func _continue_game() -> void:
	if SaveManager.load_game():
		SceneManager.go_to("city")
	else:
		EventBus.notification_requested.emit("Save could not be loaded", false)
