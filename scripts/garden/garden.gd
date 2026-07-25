extends BaseScreen

var crop_selector: OptionButton
var fertiliser_selector: OptionButton
var plot_buttons: Array[Button] = []
var last_tick_msec := 0

func _ready() -> void:
	build_shell("Garden")
	SceneManager.current_scene_id = "garden"
	_apply_away_elapsed()
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 16)
	body.add_child(toolbar)
	var seed_label := Label.new()
	seed_label.text = "Seed:"
	toolbar.add_child(seed_label)
	crop_selector = OptionButton.new()
	crop_selector.custom_minimum_size = Vector2(280, 68)
	for crop in DataManager.crops:
		crop_selector.add_item("%s (%d seeds)" % [str(crop.name), GameManager.item_count("seeds", str(crop.id))])
		crop_selector.set_item_metadata(crop_selector.item_count - 1, str(crop.id))
	toolbar.add_child(crop_selector)
	var fertiliser_label := Label.new()
	fertiliser_label.text = "Fertiliser:"
	toolbar.add_child(fertiliser_label)
	fertiliser_selector = OptionButton.new()
	fertiliser_selector.custom_minimum_size = Vector2(300, 68)
	fertiliser_selector.add_item("None")
	fertiliser_selector.set_item_metadata(0, "")
	for fertiliser in DataManager.balance.get("fertilisers", []):
		if not bool(fertiliser.get("global", false)):
			var id := str(fertiliser.id)
			fertiliser_selector.add_item("%s (%d)" % [str(fertiliser.name), GameManager.item_count("fertilisers", id)])
			fertiliser_selector.set_item_metadata(fertiliser_selector.item_count - 1, id)
	toolbar.add_child(fertiliser_selector)
	toolbar.add_child(make_button("Use Garden Time Skip", _use_global_skip, Vector2(300, 68)))
	var help := Label.new()
	help.text = "Tap EMPTY to plant • tap GROWING to fertilise • tap READY to harvest"
	help.add_theme_color_override("font_color", DataManager.color("muted"))
	help.add_theme_font_size_override("font_size", 21)
	body.add_child(help)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	body.add_child(grid)
	for index in GameManager.state.garden.size():
		var button := Button.new()
		button.custom_minimum_size = Vector2(430, 220)
		button.add_theme_font_size_override("font_size", 24)
		button.pressed.connect(func() -> void: _plot_pressed(index))
		grid.add_child(button)
		plot_buttons.append(button)
	last_tick_msec = Time.get_ticks_msec()
	_refresh()

func _process(_delta: float) -> void:
	var now_msec := Time.get_ticks_msec()
	var real_delta := (now_msec - last_tick_msec) / 1000.0
	last_tick_msec = now_msec
	var step := real_delta * TimeManager.speed_multiplier
	var changed := false
	for plot in GameManager.state.garden:
		if plot.status == "GROWING":
			plot.remaining = max(0.0, float(plot.remaining) - step)
			if float(plot.remaining) <= 0.0:
				plot.status = "READY"
			changed = true
	GameManager.state.garden_last_update_unix = TimeManager.unix_now()
	if changed:
		_refresh()

func _apply_away_elapsed() -> void:
	var now := TimeManager.unix_now()
	var previous := int(GameManager.state.get("garden_last_update_unix", now))
	var elapsed: int = clamp(now - previous, 0, int(DataManager.balance.economy.get("offline_max_seconds", 28800)))
	for plot in GameManager.state.garden:
		if plot.status == "GROWING":
			plot.remaining = max(0.0, float(plot.remaining) - elapsed)
			if float(plot.remaining) <= 0.0:
				plot.status = "READY"
	GameManager.state.garden_last_update_unix = now

func _plot_pressed(index: int) -> void:
	var plot: Dictionary = GameManager.state.garden[index]
	match str(plot.status):
		"LOCKED":
			EventBus.notification_requested.emit("Upgrade Garden Plot Count to unlock", false)
		"EMPTY":
			_plant(plot)
		"GROWING":
			_fertilise(plot)
		"READY":
			_harvest(plot)
	_refresh()
	SaveManager.queue_save()

func _plant(plot: Dictionary) -> void:
	var crop_id := str(crop_selector.get_item_metadata(crop_selector.selected))
	if GameManager.item_count("seeds", crop_id) <= 0:
		EventBus.notification_requested.emit("No seeds — visit the Shop", false)
		return
	var crop := DataManager.get_crop(crop_id)
	GameManager.add_item("seeds", crop_id, -1)
	plot.status = "GROWING"
	plot.crop_id = crop_id
	plot.remaining = float(crop.growth)
	plot.fertiliser = ""
	EventBus.notification_requested.emit("Planted " + str(crop.name), true)

func _fertilise(plot: Dictionary) -> void:
	var id := str(fertiliser_selector.get_item_metadata(fertiliser_selector.selected))
	if id.is_empty():
		EventBus.notification_requested.emit("Select a fertiliser first", false)
		return
	if GameManager.item_count("fertilisers", id) <= 0:
		EventBus.notification_requested.emit("No fertiliser in inventory", false)
		return
	var item := _fertiliser(id)
	GameManager.add_item("fertilisers", id, -1)
	plot.remaining = max(0.0, float(plot.remaining) * (1.0 - float(item.get("reduction", 0.0))))
	plot.fertiliser = id
	if float(plot.remaining) <= 0.0:
		plot.status = "READY"
	EventBus.notification_requested.emit("Applied " + str(item.name), true)

func _harvest(plot: Dictionary) -> void:
	var crop := DataManager.get_crop(str(plot.crop_id))
	var amount: int = max(1, int(round(float(crop.yield) * (1.0 + GameManager.bonus("crop_yield") + GameManager.blessing("crop_yield")))))
	GameManager.add_item("crops", str(crop.id), amount)
	GameManager.state.stats.crops_harvested = int(GameManager.state.stats.get("crops_harvested", 0)) + amount
	EventBus.notification_requested.emit("Harvested %d × %s" % [amount, str(crop.name)], true)
	plot.status = "EMPTY"
	plot.crop_id = ""
	plot.remaining = 0.0
	plot.fertiliser = ""

func _use_global_skip() -> void:
	var id := "garden_time_skip"
	if GameManager.item_count("fertilisers", id) <= 0:
		EventBus.notification_requested.emit("No Garden Time Skip", false)
		return
	var item := _fertiliser(id)
	GameManager.add_item("fertilisers", id, -1)
	for plot in GameManager.state.garden:
		if plot.status == "GROWING":
			plot.remaining = max(0.0, float(plot.remaining) * (1.0 - float(item.reduction)))
			if float(plot.remaining) <= 0.0:
				plot.status = "READY"
	EventBus.notification_requested.emit("All active crops accelerated", true)
	_refresh()
	SaveManager.queue_save()

func _fertiliser(id: String) -> Dictionary:
	for item in DataManager.balance.get("fertilisers", []):
		if str(item.id) == id:
			return item
	return {}

func _refresh() -> void:
	if plot_buttons.size() != GameManager.state.garden.size():
		return
	for index in plot_buttons.size():
		var plot: Dictionary = GameManager.state.garden[index]
		var button := plot_buttons[index]
		match str(plot.status):
			"EMPTY":
				button.text = "PLOT %d\nEMPTY" % (index + 1)
				button.add_theme_stylebox_override("normal", panel_style(Color("#7B5E3B"), 14))
			"LOCKED":
				button.text = "PLOT %d\nLOCKED" % (index + 1)
				button.add_theme_stylebox_override("normal", panel_style(DataManager.color("locked"), 14))
			"GROWING":
				var crop := DataManager.get_crop(str(plot.crop_id))
				button.text = "PLOT %d\n%s\n%s" % [index + 1, str(crop.name), UIManager.format_time(float(plot.remaining))]
				button.add_theme_stylebox_override("normal", panel_style(Color(str(crop.color)).darkened(0.2), 14))
			"READY":
				var crop := DataManager.get_crop(str(plot.crop_id))
				button.text = "PLOT %d\n%s\nREADY — HARVEST" % [index + 1, str(crop.name)]
				button.add_theme_stylebox_override("normal", panel_style(DataManager.color("success"), 14))
	for index in crop_selector.item_count:
		var id := str(crop_selector.get_item_metadata(index))
		var crop := DataManager.get_crop(id)
		crop_selector.set_item_text(index, "%s (%d seeds)" % [str(crop.name), GameManager.item_count("seeds", id)])
