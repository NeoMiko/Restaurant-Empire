extends BaseScreen

var list: VBoxContainer
var active_label: Label

func _ready() -> void:
	build_shell("Fairy Blessings")
	SceneManager.current_scene_id = "fairy"
	active_label = Label.new()
	active_label.add_theme_font_size_override("font_size", 24)
	body.add_child(active_label)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	list = VBoxContainer.new()
	list.custom_minimum_size.x = 1780
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_refresh)
	add_child(timer)
	_refresh()

func _refresh() -> void:
	for child in list.get_children():
		child.queue_free()
	var now := TimeManager.unix_now()
	var descriptions: Array[String] = []
	for id in GameManager.state.active_blessings.keys():
		var active: Dictionary = GameManager.state.active_blessings[id]
		var remaining: int = max(0, int(active.get("ends_at", 0)) - now)
		if remaining > 0:
			descriptions.append("%s: %s" % [str(active.get("name", id)), UIManager.format_time(float(remaining))])
	active_label.text = "Active: " + ("None" if descriptions.is_empty() else " • ".join(descriptions))
	for item in DataManager.balance.get("blessings", []):
		var id := str(item.id)
		var active: bool = GameManager.blessing(str(item.stat)) > 0.0
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", panel_style(DataManager.color("panel"), 12))
		list.add_child(panel)
		var row := HBoxContainer.new()
		panel.add_child(row)
		var label := Label.new()
		label.text = "%s\n+%.0f%% %s • %s" % [str(item.name), float(item.value) * 100.0, str(item.stat).replace("_", " "), UIManager.format_time(float(item.duration))]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 23)
		row.add_child(label)
		var button := make_button("ACTIVE" if active else "Bless — %d ◆" % int(item.cost), func() -> void: _buy(id), Vector2(280, 72))
		button.disabled = active
		row.add_child(button)

func _buy(id: String) -> void:
	var item: Dictionary = {}
	for candidate in DataManager.balance.get("blessings", []):
		if str(candidate.id) == id:
			item = candidate
			break
	if item.is_empty() or GameManager.blessing(str(item.stat)) > 0.0:
		return
	if EconomyManager.spend("diamonds", int(item.cost), "fairy " + id):
		GameManager.state.active_blessings[id] = {"name":str(item.name),"stat":str(item.stat),"value":float(item.value),"ends_at":TimeManager.unix_now() + int(item.duration)}
		EventBus.notification_requested.emit("Blessing activated: " + str(item.name), true)
		SaveManager.queue_save()
		refresh_currency_bar()
		_refresh()
