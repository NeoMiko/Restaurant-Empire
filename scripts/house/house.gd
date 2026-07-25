extends BaseScreen

var reward_label: Label
var afk_selector: OptionButton

func _ready() -> void:
	build_shell("House & Offline Progress")
	SceneManager.current_scene_id = "house"
	var pending_box := titled_panel("Offline Rewards")
	var limit := int(DataManager.balance.economy.get("offline_max_seconds", 28800))
	var limit_label := Label.new()
	limit_label.text = "Maximum AFK accumulation: %s" % UIManager.format_time(float(limit))
	limit_label.add_theme_color_override("font_color", DataManager.color("muted"))
	pending_box.add_child(limit_label)
	reward_label = Label.new()
	reward_label.add_theme_font_size_override("font_size", 28)
	pending_box.add_child(reward_label)
	pending_box.add_child(make_button("Claim Offline Rewards", _claim, Vector2(360, 76)))
	var rest_box := titled_panel("Plan Rest")
	afk_selector = OptionButton.new()
	afk_selector.custom_minimum_size = Vector2(420, 70)
	for item in [{"name":"15 minutes","seconds":900},{"name":"1 hour","seconds":3600},{"name":"4 hours","seconds":14400},{"name":"8 hours","seconds":28800}]:
		afk_selector.add_item(str(item.name))
		afk_selector.set_item_metadata(afk_selector.item_count - 1, int(item.seconds))
	rest_box.add_child(afk_selector)
	rest_box.add_child(make_button("Activate AFK Mode & Save", _activate_afk, Vector2(380, 76)))
	var explanation := Label.new()
	explanation.text = "Restaurant earnings are calculated mathematically. Crop timers advance without simulating every second."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rest_box.add_child(explanation)
	_refresh()

func _refresh() -> void:
	var reward: Dictionary = GameManager.state.get("offline_pending", {})
	reward_label.text = "Time: %s    Coins: %d    XP: %d" % [UIManager.format_time(float(reward.get("seconds", 0))), int(reward.get("coins", 0)), int(reward.get("xp", 0))]

func _claim() -> void:
	var reward := OfflineProgressManager.claim_pending()
	if int(reward.get("seconds", 0)) <= 0:
		EventBus.notification_requested.emit("No offline reward available", false)
	else:
		EventBus.notification_requested.emit("Offline reward claimed", true)
	refresh_currency_bar()
	_refresh()

func _activate_afk() -> void:
	var seconds := int(afk_selector.get_item_metadata(afk_selector.selected))
	GameManager.state.afk_mode = true
	GameManager.state.afk_selected_seconds = seconds
	SaveManager.save_game()
	EventBus.notification_requested.emit("AFK mode active for up to " + UIManager.format_time(float(seconds)), true)
