extends BaseScreen

var list: VBoxContainer
var summary: Label

func _ready() -> void:
	build_shell("Bazaar")
	SceneManager.current_scene_id = "bazaar"
	_refresh_market_if_needed()
	var header := HBoxContainer.new()
	body.add_child(header)
	summary = Label.new()
	summary.add_theme_font_size_override("font_size", 24)
	summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(summary)
	header.add_child(make_button("Sell Everything", _sell_everything, Vector2(260, 68)))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	list = VBoxContainer.new()
	list.custom_minimum_size.x = 1800
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)
	_rebuild()

func _refresh_market_if_needed() -> void:
	var day := int(TimeManager.unix_now() / 86400)
	if int(GameManager.state.market.get("day", -1)) == day:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = day * 7919 + 47
	var bands := [0.75, 1.0, 1.3]
	var multipliers: Dictionary = {}
	for crop in DataManager.crops:
		multipliers[str(crop.id)] = bands[rng.randi_range(0, bands.size() - 1)]
	GameManager.state.market = {"day":day,"multipliers":multipliers}
	SaveManager.queue_save()

func _rebuild() -> void:
	for child in list.get_children():
		child.queue_free()
	var total_value := 0
	for crop in DataManager.crops:
		var id := str(crop.id)
		var owned := GameManager.item_count("crops", id)
		var multiplier := float(GameManager.state.market.multipliers.get(id, 1.0))
		var price := int(round(float(crop.value) * multiplier))
		total_value += owned * price
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", panel_style(DataManager.color("panel"), 10))
		list.add_child(row)
		var columns := HBoxContainer.new()
		columns.add_theme_constant_override("separation", 20)
		row.add_child(columns)
		var name_label := Label.new()
		name_label.text = str(crop.name)
		name_label.custom_minimum_size.x = 300
		name_label.add_theme_font_size_override("font_size", 24)
		columns.add_child(name_label)
		var stock := Label.new()
		stock.text = "Owned: %d" % owned
		stock.custom_minimum_size.x = 220
		columns.add_child(stock)
		var indicator := "LOW" if multiplier < 0.9 else ("HIGH" if multiplier > 1.1 else "NORMAL")
		var price_label := Label.new()
		price_label.text = "%d coins each — %s" % [price, indicator]
		price_label.custom_minimum_size.x = 360
		price_label.add_theme_color_override("font_color", DataManager.color("danger") if indicator == "LOW" else (DataManager.color("success") if indicator == "HIGH" else DataManager.color("text")))
		columns.add_child(price_label)
		var quantity := SpinBox.new()
		quantity.min_value = 1
		quantity.max_value = max(1, owned)
		quantity.value = 1
		quantity.custom_minimum_size.x = 180
		quantity.editable = owned > 0
		columns.add_child(quantity)
		var sell_button := make_button("Sell", func() -> void: _sell(id, int(quantity.value)), Vector2(180, 64))
		sell_button.disabled = owned <= 0
		columns.add_child(sell_button)
		var all_button := make_button("Sell All", func() -> void: _sell(id, GameManager.item_count("crops", id)), Vector2(180, 64))
		all_button.disabled = owned <= 0
		columns.add_child(all_button)
	summary.text = "Current inventory market value: %d coins" % total_value

func _sell(crop_id: String, quantity: int) -> void:
	var owned := GameManager.item_count("crops", crop_id)
	var amount: int = clamp(quantity, 0, owned)
	if amount <= 0:
		return
	var crop := DataManager.get_crop(crop_id)
	var multiplier := float(GameManager.state.market.multipliers.get(crop_id, 1.0))
	var income := int(round(float(crop.value) * multiplier)) * amount
	GameManager.add_item("crops", crop_id, -amount)
	EconomyManager.add("coins", income, "bazaar sale")
	EventBus.notification_requested.emit("Sold %d × %s for %d" % [amount, str(crop.name), income], true)
	SaveManager.queue_save()
	call_deferred("_rebuild")

func _sell_everything() -> void:
	var total := 0
	for crop in DataManager.crops:
		var id := str(crop.id)
		var amount := GameManager.item_count("crops", id)
		if amount > 0:
			var multiplier := float(GameManager.state.market.multipliers.get(id, 1.0))
			total += int(round(float(crop.value) * multiplier)) * amount
			GameManager.add_item("crops", id, -amount)
	if total > 0:
		EconomyManager.add("coins", total, "sell all crops")
		EventBus.notification_requested.emit("Sold all crops for %d coins" % total, true)
		SaveManager.queue_save()
	call_deferred("_rebuild")
