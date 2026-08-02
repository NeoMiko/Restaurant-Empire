extends BaseScreen

var crop_selector: OptionButton
var fertiliser_selector: OptionButton
var plot_buttons: Array[Button] = []
var plot_backgrounds: Array[TextureRect] = []
var plot_icons: Array[TextureRect] = []
var plot_labels: Array[Label] = []
var plot_bars: Array[ProgressBar] = []
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
	crop_selector.custom_minimum_size = Vector2(300, 68)
	for crop in DataManager.crops:
		var crop_id := str(crop.id)
		var label := "%s (%d seeds)" % [str(crop.name), GameManager.item_count("seeds", crop_id)]
		_add_selector_item(crop_selector, crop_id, label, crop_id)
	toolbar.add_child(crop_selector)
	var fertiliser_label := Label.new()
	fertiliser_label.text = "Fertiliser:"
	toolbar.add_child(fertiliser_label)
	fertiliser_selector = OptionButton.new()
	fertiliser_selector.custom_minimum_size = Vector2(320, 68)
	fertiliser_selector.add_item("None")
	fertiliser_selector.set_item_metadata(0, "")
	for fertiliser in DataManager.balance.get("fertilisers", []):
		if not bool(fertiliser.get("global", false)):
			var id := str(fertiliser.id)
			_add_selector_item(fertiliser_selector, id, "%s (%d)" % [str(fertiliser.name), GameManager.item_count("fertilisers", id)], id)
	toolbar.add_child(fertiliser_selector)
	toolbar.add_child(make_button("Use Garden Time Skip", _use_global_skip, Vector2(340, 68), "garden_time_skip", 44))
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
		grid.add_child(_build_plot(index))
	last_tick_msec = Time.get_ticks_msec()
	_refresh()

const SELECTOR_ICON := 38

## Sprites are ~900px on the long edge, so both the button face and the popup rows need an
## explicit cap or a single item swallows the whole toolbar.
func _add_selector_item(selector: OptionButton, icon_id: String, label: String, metadata: String) -> void:
	var art := ArtManager.texture(icon_id)
	if art == null:
		selector.add_item(label)
	else:
		selector.add_icon_item(art, label)
		selector.get_popup().set_item_icon_max_width(selector.item_count - 1, SELECTOR_ICON)
	selector.add_theme_constant_override("icon_max_width", SELECTOR_ICON)
	selector.set_item_metadata(selector.item_count - 1, metadata)

## A plot is an outlined frame holding the plot artwork, with the planted crop and a caption
## band layered over it. Overlays ignore the mouse so the whole tile stays one button.
func _build_plot(index: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(430, 248)
	button.clip_contents = true
	button.pressed.connect(func() -> void: _plot_pressed(index))
	plot_buttons.append(button)

	var background := TextureRect.new()
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(background)
	plot_backgrounds.append(background)

	## Two overlays: the crop sits centred on the bed, the readout is pinned to the bottom.
	var crop_icon := ArtManager.icon_rect("", Vector2.ZERO)
	crop_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	crop_icon.offset_left = 108
	crop_icon.offset_right = -108
	crop_icon.offset_top = 12
	crop_icon.offset_bottom = -58
	button.add_child(crop_icon)
	plot_icons.append(crop_icon)

	var footer := VBoxContainer.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	footer.offset_left = 12
	footer.offset_right = -12
	footer.offset_bottom = -12
	footer.alignment = BoxContainer.ALIGNMENT_END
	footer.add_theme_constant_override("separation", 5)
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(footer)

	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 16
	bar.max_value = 1.0
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_child(bar)
	plot_bars.append(bar)

	var caption_panel := PanelContainer.new()
	var caption_style := panel_style(DataManager.color("outline"), 8)
	caption_style.content_margin_top = 3
	caption_style.content_margin_bottom = 3
	caption_panel.add_theme_stylebox_override("panel", caption_style)
	caption_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_child(caption_panel)
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 21)
	label.add_theme_color_override("font_color", DataManager.color("parchment"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption_panel.add_child(label)
	plot_labels.append(label)
	return button

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
	GameManager.state.lifetime_stats.crops_harvested = int(GameManager.state.lifetime_stats.get("crops_harvested", 0)) + amount
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
		var status := str(plot.status)
		plot_backgrounds[index].texture = ArtManager.texture(ArtManager.plot_icon(status))
		plot_bars[index].visible = status == "GROWING"
		var tint := DataManager.color("locked")
		var caption := "PLOT %d — LOCKED" % (index + 1)
		var crop_icon := ""
		match status:
			"EMPTY":
				tint = DataManager.color("table_free")
				caption = "PLOT %d — TAP TO PLANT" % (index + 1)
			"GROWING":
				var crop := DataManager.get_crop(str(plot.crop_id))
				tint = Color(str(crop.color)).darkened(0.35)
				caption = "%s — %s" % [str(crop.name), UIManager.format_time(float(plot.remaining))]
				crop_icon = str(crop.id)
				var total: float = max(0.01, float(crop.growth))
				plot_bars[index].value = clampf(1.0 - float(plot.remaining) / total, 0.0, 1.0)
			"READY":
				var crop := DataManager.get_crop(str(plot.crop_id))
				tint = DataManager.color("success")
				caption = "%s — READY" % str(crop.name)
				crop_icon = str(crop.id)
		plot_icons[index].texture = ArtManager.texture(crop_icon)
		_style_plot(plot_buttons[index], tint)
		plot_labels[index].text = caption
	for index in crop_selector.item_count:
		var id := str(crop_selector.get_item_metadata(index))
		var crop := DataManager.get_crop(id)
		crop_selector.set_item_text(index, "%s (%d seeds)" % [str(crop.name), GameManager.item_count("seeds", id)])

func _style_plot(button: Button, tint: Color) -> void:
	button.add_theme_stylebox_override("normal", panel_style(tint, 14, 4))
	button.add_theme_stylebox_override("hover", panel_style(tint.lightened(0.12), 14, 4))
	button.add_theme_stylebox_override("pressed", panel_style(tint.darkened(0.2), 14, 4))
	button.add_theme_stylebox_override("disabled", panel_style(tint, 14, 4))
