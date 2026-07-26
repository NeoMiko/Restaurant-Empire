extends BaseScreen

var tabs: TabContainer

func _ready() -> void:
	build_shell("Legacy Hall")
	SceneManager.current_scene_id = "progression"
	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_theme_font_size_override("font_size", 24)
	body.add_child(tabs)
	GameManager.ensure_daily_quests()
	_rebuild()

func _rebuild() -> void:
	for child in tabs.get_children():
		child.free()
	_build_prestige()
	_build_daily()
	_build_achievements()
	refresh_currency_bar()

func _tab(title: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll)
	var list := VBoxContainer.new()
	list.custom_minimum_size.x = 1780
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)
	return list

func _row(parent: Control, title: String, description: String, progress: int, target: int, button_text: String, callback: Callable, disabled: bool) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", panel_style(DataManager.color("panel"), 12))
	parent.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	panel.add_child(row)
	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_box)
	var heading := Label.new()
	heading.text = title
	heading.add_theme_font_size_override("font_size", 25)
	text_box.add_child(heading)
	var detail := Label.new()
	detail.text = description
	detail.add_theme_color_override("font_color", DataManager.color("muted"))
	text_box.add_child(detail)
	if target > 0:
		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(780, 32)
		bar.max_value = target
		bar.value = min(progress, target)
		bar.show_percentage = false
		text_box.add_child(bar)
		var progress_label := Label.new()
		progress_label.text = "%d / %d" % [min(progress, target), target]
		text_box.add_child(progress_label)
	var button := make_button(button_text, callback, Vector2(290, 72))
	button.disabled = disabled
	row.add_child(button)

func _build_prestige() -> void:
	var list := _tab("Prestige Tree")
	var summary := Label.new()
	summary.text = "PRESTIGE TOKENS: %d  •  Permanent bonuses survive every reset" % EconomyManager.balance("prestige_tokens")
	summary.add_theme_font_size_override("font_size", 28)
	list.add_child(summary)
	for item in DataManager.balance.get("prestige_nodes", []):
		var id := str(item.id)
		var level := GameManager.prestige_node_level(id)
		var maximum := int(item.max)
		var cost := EconomyManager.prestige_node_cost(id)
		var description := "%s • +%.0f%% per level" % [str(item.description), float(item.value) * 100.0]
		_row(list, "%s  Lv.%d/%d" % [str(item.name), level, maximum], description, level, maximum, "MAX" if level >= maximum else "Upgrade — %d tokens" % cost, func() -> void: _buy_node(id), level >= maximum or EconomyManager.balance("prestige_tokens") < cost)

func _build_daily() -> void:
	var list := _tab("Daily Quests")
	var heading := Label.new()
	heading.text = "Daily progress resets on the next UTC day. Completed rewards remain claimable until reset."
	heading.add_theme_font_size_override("font_size", 22)
	list.add_child(heading)
	for item in DataManager.balance.get("daily_quests", []):
		var id := str(item.id)
		var progress := GameManager.daily_quest_progress(id)
		var target := int(item.target)
		var entry: Dictionary = GameManager.state.daily_quests.entries.get(id, {})
		var claimed := bool(entry.get("claimed", false))
		var reward_text := "%d %s" % [int(item.reward), str(item.reward_currency).replace("_", " ")]
		_row(list, str(item.name), "%s • Reward: %s" % [str(item.description), reward_text], progress, target, "CLAIMED" if claimed else "Claim reward", func() -> void: _claim_daily(id), claimed or progress < target)

func _build_achievements() -> void:
	var list := _tab("Achievements")
	for item in DataManager.balance.get("achievements", []):
		var id := str(item.id)
		var progress := GameManager.achievement_progress(id)
		var target := int(item.target)
		var claimed := bool(GameManager.state.get("achievements", {}).get(id, false))
		var reward_text := "%d %s" % [int(item.reward), str(item.reward_currency).replace("_", " ")]
		_row(list, str(item.name), "%s • Reward: %s" % [str(item.description), reward_text], progress, target, "CLAIMED" if claimed else "Claim reward", func() -> void: _claim_achievement(id), claimed or progress < target)

func _buy_node(id: String) -> void:
	if EconomyManager.purchase_prestige_node(id):
		_rebuild()

func _claim_daily(id: String) -> void:
	if GameManager.claim_daily_quest(id):
		_rebuild()

func _claim_achievement(id: String) -> void:
	if GameManager.claim_achievement(id):
		_rebuild()
