extends BaseScreen

func _ready() -> void:
	build_shell("Settings")
	SceneManager.current_scene_id = "settings"
	var box := titled_panel("Audio & Interface")
	_add_slider(box, "Music", "music")
	_add_slider(box, "SFX", "sfx")
	var notifications := CheckButton.new()
	notifications.text = "Notifications"
	notifications.button_pressed = bool(GameManager.state.settings.get("notifications", true))
	notifications.toggled.connect(func(value: bool) -> void: GameManager.state.settings.notifications = value; SaveManager.queue_save())
	box.add_child(notifications)
	box.add_child(make_button("Save Settings", func() -> void: AudioManager.apply_settings(); SaveManager.save_game(); EventBus.notification_requested.emit("Settings saved", true)))
	box.add_child(make_button("Replay Tutorial", _reset_tutorial))

func _reset_tutorial() -> void:
	GameManager.state.tutorial = {"step":0,"completed":false}
	SaveManager.queue_save()
	EventBus.notification_requested.emit("Tutorial will restart in City", true)

func _add_slider(parent: Control, label_text: String, key: String) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 220
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = float(GameManager.state.settings.get(key, 0.7))
	slider.custom_minimum_size = Vector2(600, 64)
	slider.value_changed.connect(func(value: float) -> void: GameManager.state.settings[key] = value)
	row.add_child(slider)
	parent.add_child(row)
