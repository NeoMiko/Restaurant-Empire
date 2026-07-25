extends Node

func balance(currency_id: String) -> int:
	return int(GameManager.state.get("currencies", {}).get(currency_id, 0))

func add(currency_id: String, amount: int, reason: String = "") -> int:
	if amount < 0:
		print("ECONOMY rejected negative add")
		return balance(currency_id)
	var currencies: Dictionary = GameManager.state.currencies
	currencies[currency_id] = max(0, int(currencies.get(currency_id, 0)) + amount)
	if currency_id == "coins":
		GameManager.state.stats.coins_earned = int(GameManager.state.stats.get("coins_earned", 0)) + amount
	EventBus.currency_changed.emit(currency_id, int(currencies[currency_id]), amount)
	if not reason.is_empty():
		print("ECONOMY +%d %s (%s)" % [amount, currency_id, reason])
	return int(currencies[currency_id])

func spend(currency_id: String, amount: int, reason: String = "") -> bool:
	if amount < 0 or balance(currency_id) < amount:
		EventBus.notification_requested.emit("Not enough " + currency_id.replace("_", " "), false)
		return false
	GameManager.state.currencies[currency_id] = balance(currency_id) - amount
	EventBus.currency_changed.emit(currency_id, balance(currency_id), -amount)
	if not reason.is_empty():
		print("ECONOMY -%d %s (%s)" % [amount, currency_id, reason])
	return true

func upgrade_cost(id: String, level_override: int = -1) -> int:
	var item := DataManager.get_upgrade(id)
	var level := GameManager.upgrade_level(id) if level_override < 0 else level_override
	var growth := float(DataManager.balance.get("economy", {}).get("upgrade_growth", 1.15))
	return int(round(float(item.get("base", 100)) * pow(growth, level)))

func purchase_upgrade(id: String) -> bool:
	var item := DataManager.get_upgrade(id)
	if item.is_empty():
		return false
	var level := GameManager.upgrade_level(id)
	if level >= int(item.get("max", 1)):
		EventBus.notification_requested.emit("Upgrade already at maximum", false)
		return false
	var cost := upgrade_cost(id)
	if not spend("coins", cost, "upgrade " + id):
		return false
	GameManager.state.upgrades[id] = level + 1
	if id == "garden_plot_count":
		for plot in GameManager.state.garden:
			if plot.status == "LOCKED":
				plot.status = "EMPTY"
				break
	EventBus.state_changed.emit("upgrades")
	EventBus.notification_requested.emit("Upgraded " + str(item.get("name", id)), true)
	SaveManager.queue_save()
	return true

func add_player_xp(amount: int) -> void:
	var player: Dictionary = GameManager.state.player
	player.xp = int(player.get("xp", 0)) + max(0, amount)
	var needed := int(player.level) * 100
	while int(player.xp) >= needed:
		player.xp = int(player.xp) - needed
		player.level = int(player.level) + 1
		needed = int(player.level) * 100
		EventBus.notification_requested.emit("Player level %d" % int(player.level), true)
	EventBus.state_changed.emit("player")

func calculate_meal_payment(recipe: Dictionary, spend_multiplier: float, tip_multiplier: float) -> Dictionary:
	var gross := float(recipe.get("price", 0)) * spend_multiplier * (1.0 + GameManager.bonus("meal_value")) * (1.0 + GameManager.bonus("table_capacity")) * (1.0 + GameManager.blessing("income"))
	var net: int = max(1, int(round(gross - float(recipe.get("cost", 0)))))
	var tip := 0
	var chance := float(DataManager.balance.economy.get("tip_chance", 0.25))
	if randf() < chance:
		var percent := float(DataManager.balance.economy.get("tip_percent", 0.1))
		tip = int(round(gross * percent * tip_multiplier * (1.0 + GameManager.bonus("tips") + GameManager.blessing("tips"))))
	return {"coins":net + tip,"tip":tip,"xp":int(recipe.get("xp", 0))}
