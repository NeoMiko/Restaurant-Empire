extends BaseScreen

var pity_label: Label
var results_label: Label
var collection_list: VBoxContainer

func _ready() -> void:
	build_shell("Employment Office")
	SceneManager.current_scene_id = "office"
	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 20)
	body.add_child(split)
	var recruit := VBoxContainer.new()
	recruit.custom_minimum_size.x = 650
	recruit.add_theme_constant_override("separation", 16)
	split.add_child(recruit)
	var heading := Label.new()
	heading.text = "RECRUIT STAFF"
	heading.add_theme_font_size_override("font_size", 32)
	recruit.add_child(heading)
	var rates := Label.new()
	rates.text = "Common 70% • Rare 20% • Epic 7%\nLegendary 2.5% • Mythic 0.5%"
	rates.add_theme_font_size_override("font_size", 22)
	recruit.add_child(rates)
	pity_label = Label.new()
	pity_label.add_theme_font_size_override("font_size", 24)
	recruit.add_child(pity_label)
	recruit.add_child(make_button("Recruit ×1 — 1 Ticket", func() -> void: _roll_ui(1), Vector2(460, 78)))
	recruit.add_child(make_button("Recruit ×10 — 10 Tickets", func() -> void: _roll_ui(10), Vector2(460, 78)))
	results_label = Label.new()
	results_label.text = "Results appear here."
	results_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	results_label.add_theme_font_size_override("font_size", 22)
	recruit.add_child(results_label)
	var collection_scroll := ScrollContainer.new()
	collection_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	collection_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(collection_scroll)
	collection_list = VBoxContainer.new()
	collection_list.custom_minimum_size.x = 1050
	collection_list.add_theme_constant_override("separation", 8)
	collection_scroll.add_child(collection_list)
	_refresh()

func perform_rolls(count: int, charge: bool = true) -> Array[Dictionary]:
	var gacha: Dictionary = DataManager.balance.get("gacha", {})
	var cost := int(gacha.get("single_cost", 1)) * count
	if charge and not EconomyManager.spend("gacha_tickets", cost, "staff recruit"):
		return []
	var results: Array[Dictionary] = []
	for _index in count:
		var rarity := _roll_rarity()
		var candidates: Array[Dictionary] = []
		for employee in DataManager.people.get("employees", []):
			if str(employee.rarity) == rarity:
				candidates.append(employee)
		if candidates.is_empty():
			continue
		var employee: Dictionary = candidates.pick_random()
		var id := str(employee.id)
		var duplicate: bool = GameManager.state.staff_collection.has(id)
		if duplicate:
			GameManager.state.staff_collection[id].count = int(GameManager.state.staff_collection[id].get("count", 1)) + 1
			EconomyManager.add("coins", int(gacha.get("duplicate_coins", 25)), "staff duplicate")
		else:
			GameManager.state.staff_collection[id] = {"count":1,"level":1}
		var result := employee.duplicate(true)
		result["duplicate"] = duplicate
		results.append(result)
	SaveManager.queue_save()
	return results

func _roll_rarity() -> String:
	var gacha: Dictionary = DataManager.balance.get("gacha", {})
	var pity_limit := int(gacha.get("pity_limit", 50))
	if int(GameManager.state.pity_counter) >= pity_limit - 1:
		GameManager.state.pity_counter = 0
		return "Legendary"
	var roll := randf()
	var cumulative := 0.0
	var rarity := "Common"
	for id in ["Common", "Rare", "Epic", "Legendary", "Mythic"]:
		cumulative += float(gacha.get("rates", {}).get(id, 0.0))
		if roll <= cumulative:
			rarity = id
			break
	if rarity in ["Legendary", "Mythic"]:
		GameManager.state.pity_counter = 0
	else:
		GameManager.state.pity_counter = int(GameManager.state.pity_counter) + 1
	return rarity

func _roll_ui(count: int) -> void:
	var results := perform_rolls(count, true)
	if results.is_empty():
		return
	var lines: Array[String] = []
	for result in results:
		lines.append("[%s] %s — %s%s" % [str(result.rarity), str(result.name), str(result.role), " (duplicate +coins)" if bool(result.duplicate) else " NEW!"])
	results_label.text = "\n".join(lines)
	EventBus.notification_requested.emit("Recruitment complete", true)
	refresh_currency_bar()
	_refresh()

func _refresh() -> void:
	var limit := int(DataManager.balance.gacha.get("pity_limit", 50))
	pity_label.text = "Tickets: %d\nLegendary pity: %d / %d" % [EconomyManager.balance("gacha_tickets"), int(GameManager.state.pity_counter), limit]
	for child in collection_list.get_children():
		child.queue_free()
	var title := Label.new()
	title.text = "STAFF COLLECTION (%d/%d)" % [GameManager.state.staff_collection.size(), DataManager.people.get("employees", []).size()]
	title.add_theme_font_size_override("font_size", 30)
	collection_list.add_child(title)
	for employee in DataManager.people.get("employees", []):
		var id := str(employee.id)
		var owned: bool = GameManager.state.staff_collection.has(id)
		var copies := int(GameManager.state.staff_collection.get(id, {}).get("count", 0))
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", panel_style(DataManager.color("panel") if owned else DataManager.color("locked"), 10))
		collection_list.add_child(panel)
		var label := Label.new()
		label.text = "%s  [%s]  %s\nSpeed %.2f • Capacity %d • %s%s" % [str(employee.name) if owned else "???", str(employee.rarity), str(employee.role), float(employee.speed), int(employee.capacity), str(employee.passive), " • Copies %d" % copies if owned else ""]
		label.add_theme_font_size_override("font_size", 20)
		panel.add_child(label)
