extends BaseScreen

var tabs: TabContainer

func _ready() -> void:
	build_shell("Shop")
	SceneManager.current_scene_id = "shop"
	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_theme_font_size_override("font_size", 24)
	body.add_child(tabs)
	_build_tabs()

func _build_tabs() -> void:
	for child in tabs.get_children():
		child.queue_free()
	await get_tree().process_frame
	_build_seeds()
	_build_recipes()
	_build_fertilisers()
	_build_generic("Boosters", "boosters", DataManager.shop.get("boosters", []))
	_build_generic("Decorations", "decorations", DataManager.shop.get("decorations", []))

func _tab(name: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = name
	tabs.add_child(scroll)
	var list := VBoxContainer.new()
	list.custom_minimum_size.x = 1780
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)
	return list

func _row(parent: Control, title: String, details: String, button_text: String, callback: Callable, disabled: bool = false) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", panel_style(DataManager.color("panel"), 10))
	parent.add_child(panel)
	var row := HBoxContainer.new()
	panel.add_child(row)
	var title_label := Label.new()
	title_label.text = title
	title_label.custom_minimum_size.x = 350
	title_label.add_theme_font_size_override("font_size", 24)
	row.add_child(title_label)
	var detail_label := Label.new()
	detail_label.text = details
	detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_label.add_theme_color_override("font_color", DataManager.color("muted"))
	row.add_child(detail_label)
	var button := make_button(button_text, callback, Vector2(260, 64))
	button.disabled = disabled
	row.add_child(button)

func _build_seeds() -> void:
	var list := _tab("Seeds")
	for crop in DataManager.crops:
		var id := str(crop.id)
		var cost := int(crop.seed_cost)
		_row(list, str(crop.name) + " Seed", "Owned %d • grows %s" % [GameManager.item_count("seeds", id), UIManager.format_time(float(crop.growth))], "Buy — %d coins" % cost, func() -> void: _buy_item("seeds", id, cost, "coins"))

func _build_recipes() -> void:
	var list := _tab("Recipes")
	var multiplier := float(DataManager.shop.get("recipe_cost_multiplier", 4.0))
	for recipe in DataManager.recipes:
		var id := str(recipe.id)
		var owned: bool = id in GameManager.state.unlocked_recipes
		var cost := int(round(float(recipe.price) * multiplier))
		var gated: bool = int(GameManager.state.player.level) < int(recipe.level) or EconomyManager.balance("reputation") < int(recipe.reputation)
		var detail := "Lv.%d • %d ★ • sells %d" % [int(recipe.level), int(recipe.reputation), int(recipe.price)]
		_row(list, str(recipe.name), detail, "OWNED" if owned else "Unlock — %d" % cost, func() -> void: _buy_recipe(id, cost), owned or gated)

func _build_fertilisers() -> void:
	var list := _tab("Fertilisers")
	for item in DataManager.balance.get("fertilisers", []):
		var id := str(item.id)
		var currency := str(item.get("currency", "coins"))
		var cost := int(item.cost)
		_row(list, str(item.name), "Owned %d • reduces %.0f%%" % [GameManager.item_count("fertilisers", id), float(item.reduction) * 100.0], "Buy — %d %s" % [cost, currency], func() -> void: _buy_item("fertilisers", id, cost, currency))

func _build_generic(tab_name: String, category: String, items: Array) -> void:
	var list := _tab(tab_name)
	for item in items:
		var id := str(item.id)
		var cost := int(item.cost)
		_row(list, str(item.name), "%s • owned %d" % [str(item.description), GameManager.item_count(category, id)], "Buy — %d coins" % cost, func() -> void: _buy_item(category, id, cost, "coins"))

func _buy_item(category: String, id: String, cost: int, currency: String) -> void:
	if EconomyManager.spend(currency, cost, "shop " + id):
		GameManager.add_item(category, id, 1)
		EventBus.notification_requested.emit("Purchased " + id.replace("_", " ").capitalize(), true)
		SaveManager.queue_save()
		refresh_currency_bar()
		_build_tabs()

func _buy_recipe(id: String, cost: int) -> void:
	if id in GameManager.state.unlocked_recipes:
		return
	if EconomyManager.spend("coins", cost, "recipe " + id):
		GameManager.state.unlocked_recipes.append(id)
		GameManager.state.recipe_mastery[id] = 0
		EventBus.notification_requested.emit("Recipe unlocked: " + str(DataManager.get_recipe(id).name), true)
		SaveManager.queue_save()
		refresh_currency_bar()
		_build_tabs()
