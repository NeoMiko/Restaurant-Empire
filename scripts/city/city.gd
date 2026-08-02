extends BaseScreen

const TUTORIAL_STEPS := [
	{"title":"Welcome to Restaurant Empire","text":"This city is your management hub. Start with the Restaurant, where guests arrive automatically and your staff handles the service loop."},
	{"title":"Restaurant Basics","text":"Watch the queue, kitchen and waiter tray. Earn coins, then buy Kitchen Speed or Table upgrades from the restaurant panel."},
	{"title":"Grow Ingredients","text":"Visit the Garden, choose a seed and tap an empty plot. Return when the timer reaches READY to harvest ingredients."},
	{"title":"Trade and Stock Up","text":"Sell crops at the Bazaar when prices are high. The Shop offers seeds, recipes, fertilisers, boosters and decorations."},
	{"title":"Build Your Team","text":"Use tickets in the Employment Office. Fairy blessings are temporary and continue counting down while the game is closed."},
	{"title":"Long-Term Progress","text":"The House contains offline rewards and Prestige. Legacy Hall contains permanent upgrades, daily quests and achievements. Your progress saves automatically."}
]

var tutorial_dialog: ConfirmationDialog

func _ready() -> void:
	build_shell("City Hub", false)
	SceneManager.current_scene_id = "city"
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	body.add_child(header)
	var intro := Label.new()
	intro.text = "Choose a destination — your empire grows from every building."
	intro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	intro.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	intro.add_theme_font_size_override("font_size", 26)
	header.add_child(intro)
	header.add_child(make_button("Save & Main Menu", func() -> void: SaveManager.save_game(); SceneManager.go_to("menu"), Vector2(300, 68), "btn_back", 42))
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
		grid.add_child(_building_card(building, unlocked, required))
	_show_offline_popup()
	call_deferred("_show_tutorial")

## A card is an outlined tile with the building sprite as the hero, name and unlock state
## stacked underneath — rather than a button with an icon glued to its left edge.
func _building_card(building: Dictionary, unlocked: bool, required: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(430, 270)
	button.clip_contents = true
	button.disabled = not unlocked
	button.tooltip_text = str(building.name)
	var tint := Color(str(building.color)) if unlocked else DataManager.color("locked")
	button.add_theme_stylebox_override("normal", panel_style(tint, 20, 4))
	button.add_theme_stylebox_override("hover", panel_style(tint.lightened(0.15), 20, 4))
	button.add_theme_stylebox_override("pressed", panel_style(tint.darkened(0.2), 20, 4))
	button.add_theme_stylebox_override("disabled", panel_style(tint, 20, 4))
	if unlocked:
		var scene_id := str(building.scene)
		button.pressed.connect(func() -> void: SceneManager.go_to(scene_id))

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	button.add_child(margin)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 6)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(stack)
	stack.add_child(ArtManager.icon_rect(str(building.id) if unlocked else "slot_locked", Vector2(0, 148)))
	var name_label := Label.new()
	name_label.text = str(building.name)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(name_label)
	var status := Label.new()
	status.text = "OPEN" if unlocked else "LOCKED — %d reputation" % required
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 20)
	status.add_theme_color_override("font_color", DataManager.color("text") if unlocked else DataManager.color("muted"))
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(status)
	return button

func _show_tutorial() -> void:
	if bool(GameManager.state.get("tutorial", {}).get("completed", false)):
		return
	var step := clampi(int(GameManager.state.tutorial.get("step", 0)), 0, TUTORIAL_STEPS.size() - 1)
	var item: Dictionary = TUTORIAL_STEPS[step]
	tutorial_dialog = ConfirmationDialog.new()
	tutorial_dialog.title = "%d/%d — %s" % [step + 1, TUTORIAL_STEPS.size(), str(item.title)]
	tutorial_dialog.dialog_text = str(item.text)
	tutorial_dialog.ok_button_text = "Got it"
	tutorial_dialog.cancel_button_text = "Later"
	tutorial_dialog.add_button("Skip Tutorial", true, "skip")
	tutorial_dialog.confirmed.connect(_advance_tutorial)
	tutorial_dialog.custom_action.connect(_tutorial_action)
	add_child(tutorial_dialog)
	tutorial_dialog.popup_centered(Vector2i(780, 420))

func _advance_tutorial() -> void:
	var next_step := int(GameManager.state.tutorial.get("step", 0)) + 1
	GameManager.state.tutorial.step = next_step
	if next_step >= TUTORIAL_STEPS.size():
		GameManager.state.tutorial.completed = true
		EventBus.notification_requested.emit("Tutorial completed", true)
	SaveManager.queue_save()

func _tutorial_action(action: StringName) -> void:
	if action == &"skip":
		GameManager.state.tutorial.completed = true
		SaveManager.queue_save()
		tutorial_dialog.hide()

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
