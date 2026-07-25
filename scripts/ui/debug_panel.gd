extends PanelContainer

var stats_label: Label
var confirm_reset: ConfirmationDialog

func _ready() -> void:
	visible = false
	z_index = 200
	position = Vector2(300, 130)
	size = Vector2(1320, 820)
	add_theme_stylebox_override("panel", _style())
	var box := VBoxContainer.new()
	add_child(box)
	var title := Label.new()
	title.text = "DEBUG PANEL — F12"
	title.add_theme_font_size_override("font_size", 32)
	box.add_child(title)
	stats_label = Label.new()
	box.add_child(stats_label)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	box.add_child(grid)
	_add(grid, "+10k Coins", func() -> void: EconomyManager.add("coins", 10000, "debug"))
	_add(grid, "+100 Diamonds", func() -> void: EconomyManager.add("diamonds", 100, "debug"))
	_add(grid, "+50 Tickets", func() -> void: EconomyManager.add("gacha_tickets", 50, "debug"))
	_add(grid, "+100 Reputation", func() -> void: EconomyManager.add("reputation", 100, "debug"))
	_add(grid, "Unlock All", DebugManager.unlock_all)
	_add(grid, "Save", func() -> void: SaveManager.save_game(); EventBus.notification_requested.emit("Game saved", true))
	_add(grid, "Load", func() -> void: SaveManager.load_game(); EventBus.notification_requested.emit("Game loaded", true))
	_add(grid, "Cycle Speed", TimeManager.cycle_speed)
	_add(grid, "Spawn Customer", func() -> void: EventBus.spawn_customer_requested.emit())
	_add(grid, "Clear Customers", func() -> void: EventBus.clear_customers_requested.emit())
	_add(grid, "Finish Crops", DebugManager.finish_crops)
	_add(grid, "All Ingredients", _all_ingredients)
	_add(grid, "Test Offline 2h", _test_offline)
	_add(grid, "Reset Save", _ask_reset)
	_add(grid, "Close", func() -> void: visible = false)
	confirm_reset = ConfirmationDialog.new()
	confirm_reset.dialog_text = "Reset all local progress?"
	confirm_reset.confirmed.connect(SaveManager.reset_save)
	add_child(confirm_reset)
	var timer := Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(_update_stats)
	add_child(timer)

func _add(parent: Control, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(290, 64)
	button.pressed.connect(callback)
	parent.add_child(button)

func _style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#101820F2")
	style.border_color = DataManager.color("accent")
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(24)
	return style

func _all_ingredients() -> void:
	for crop in DataManager.crops:
		GameManager.state.inventory.seeds[str(crop.id)] = 99
		GameManager.state.inventory.crops[str(crop.id)] = 99
	EventBus.state_changed.emit("inventory")
	EventBus.notification_requested.emit("Inventory filled", true)

func _test_offline() -> void:
	GameManager.state.last_save_unix = TimeManager.unix_now() - 7200
	OfflineProgressManager.apply_elapsed(int(GameManager.state.last_save_unix))
	EventBus.notification_requested.emit("2h offline reward prepared", true)

func _ask_reset() -> void:
	confirm_reset.popup_centered()

func _update_stats() -> void:
	stats_label.text = "FPS: %d | Nodes: %d | Customers: %d | Speed: x%s" % [Engine.get_frames_per_second(), get_tree().get_node_count(), get_tree().get_nodes_in_group("customer").size(), str(TimeManager.speed_multiplier)]
