class_name BaseScreen
extends Control

var body: VBoxContainer
var currency_labels: Dictionary = {}
var toast_label: Label
var toast_timer: Timer
var debug_panel: Control

func build_shell(screen_title: String, show_back: bool = true) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = DataManager.color("background")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 12)
	add_child(layout)

	var hud_panel := PanelContainer.new()
	hud_panel.custom_minimum_size.y = 94
	hud_panel.add_theme_stylebox_override("panel", panel_style(DataManager.color("panel"), 0))
	layout.add_child(hud_panel)
	var hud := HBoxContainer.new()
	hud.add_theme_constant_override("separation", 16)
	hud_panel.add_child(hud)
	if show_back:
		hud.add_child(make_button("← City", SceneManager.go_back, Vector2(150, 72)))
	var heading := Label.new()
	heading.text = screen_title
	heading.add_theme_font_size_override("font_size", 34)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud.add_child(heading)
	for currency_id in ["coins", "diamonds", "reputation", "gacha_tickets"]:
		var label := Label.new()
		label.custom_minimum_size.x = 145
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 22)
		currency_labels[currency_id] = label
		hud.add_child(label)
	var speed_button := make_button("Speed x%s" % str(TimeManager.speed_multiplier), TimeManager.cycle_speed, Vector2(145, 72))
	speed_button.name = "SpeedButton"
	EventBus.time_speed_changed.connect(func(value: float) -> void: speed_button.text = "Speed x%s" % str(value))
	hud.add_child(speed_button)
	if DebugManager.enabled:
		hud.add_child(make_button("DEBUG", toggle_debug, Vector2(120, 72)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(margin)
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	margin.add_child(body)

	toast_label = Label.new()
	toast_label.visible = false
	toast_label.z_index = 100
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 24)
	toast_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	toast_label.position = Vector2(-360, -110)
	toast_label.size = Vector2(720, 72)
	add_child(toast_label)
	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.wait_time = 2.5
	toast_timer.timeout.connect(func() -> void: toast_label.visible = false)
	add_child(toast_timer)

	var packed: PackedScene = load("res://scenes/ui/debug_panel.tscn")
	debug_panel = packed.instantiate()
	add_child(debug_panel)
	EventBus.currency_changed.connect(_on_currency_changed)
	EventBus.notification_requested.connect(_show_toast)
	refresh_currency_bar()

func make_button(text: String, callback: Callable, minimum := Vector2(190, 68)) -> Button:
	var button := Button.new()
	button.tooltip_text = text
	button.text = text
	button.custom_minimum_size = minimum
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_stylebox_override("normal", panel_style(DataManager.color("panel_alt"), 12))
	button.add_theme_stylebox_override("hover", panel_style(DataManager.color("accent").darkened(0.15), 12))
	button.add_theme_stylebox_override("pressed", panel_style(DataManager.color("accent").darkened(0.3), 12))
	button.pressed.connect(callback)
	return button

func panel_style(color: Color, radius: int = 12) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func titled_panel(title: String) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", panel_style(DataManager.color("panel")))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 28)
	box.add_child(label)
	return box

func refresh_currency_bar() -> void:
	for currency_id in currency_labels:
		var icon: String = {"coins":"●", "diamonds":"◆", "reputation":"★", "gacha_tickets":"🎟"}.get(currency_id, "")
		currency_labels[currency_id].text = "%s %s" % [icon, UIManager.format_number(EconomyManager.balance(currency_id))]

func _on_currency_changed(_id: String, _balance: int, _delta: int) -> void:
	refresh_currency_bar()

func _show_toast(message: String, success: bool) -> void:
	toast_label.text = message
	toast_label.add_theme_color_override("font_color", DataManager.color("success" if success else "danger"))
	toast_label.visible = true
	toast_timer.start()

func toggle_debug() -> void:
	if DebugManager.enabled and is_instance_valid(debug_panel):
		debug_panel.visible = not debug_panel.visible

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		toggle_debug()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		SceneManager.go_back()
