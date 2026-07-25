extends BaseScreen

func _ready() -> void:
	build_shell("City Hub", false)
	SceneManager.current_scene_id = "city"
	var intro := Label.new()
	intro.text = "Choose a destination — your empire grows from every building."
	intro.add_theme_font_size_override("font_size", 26)
	var menu_button := make_button("Save & Main Menu", func() -> void: SaveManager.save_game(); SceneManager.go_to("menu"), Vector2(280, 68))
	menu_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	body.add_child(menu_button)
	body.add_child(intro)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	body.add_child(grid)
	var reputation := EconomyManager.balance("reputation")
	for building in DataManager.balance.get("buildings", []):
		var required := int(building.get("reputation", 0))
		var unlocked: bool = reputation >= required
		if unlocked and str(building.id) not in GameManager.state.unlocked_buildings:
			GameManager.state.unlocked_buildings.append(str(building.id))
		var button := Button.new()
		button.text = "%s\n%s" % [str(building.name), "OPEN" if unlocked else "LOCKED — %d ★" % required]
		button.custom_minimum_size = Vector2(430, 270)
		button.add_theme_font_size_override("font_size", 28)
		button.disabled = not unlocked
		var style := panel_style(Color(str(building.color)), 20)
		button.add_theme_stylebox_override("normal", style)
		var scene_id := str(building.scene)
		button.pressed.connect(func() -> void: SceneManager.go_to(scene_id))
		grid.add_child(button)
	_show_offline_popup()

func _show_offline_popup() -> void:
	var pending: Dictionary = GameManager.state.get("offline_pending", {})
	if int(pending.get("seconds", 0)) < 60:
		return
	var popup := ConfirmationDialog.new()
	popup.title = "Welcome back!"
	popup.dialog_text = "Offline: %s\nCoins ready: %d\nXP ready: %d" % [UIManager.format_time(float(pending.seconds)), int(pending.coins), int(pending.xp)]
	popup.ok_button_text = "Claim"
	popup.confirmed.connect(func() -> void: OfflineProgressManager.claim_pending(); refresh_currency_bar())
	add_child(popup)
	popup.popup_centered(Vector2i(620, 360))
