extends Node

const SAVE_VERSION := 2
var state: Dictionary = {}

func _enter_tree() -> void:
	new_game()

func new_game() -> void:
	var upgrades: Dictionary = {}
	for item in DataManager.balance.get("upgrades", []):
		upgrades[str(item.id)] = 0
	var seeds: Dictionary = {}
	var crops_stock: Dictionary = {}
	for crop in DataManager.crops:
		seeds[str(crop.id)] = 5
		crops_stock[str(crop.id)] = 0
	var plots: Array = []
	for index in 12:
		plots.append({"status":"EMPTY" if index < 6 else "LOCKED", "crop_id":"", "remaining":0.0, "fertiliser":""})
	state = {
		"save_version": SAVE_VERSION,
		"currencies": DataManager.balance.get("economy", {}).get("starting", {}).duplicate(true),
		"player": {"level":1, "xp":0, "restaurant_level":1},
		"unlocked_buildings": ["restaurant","garden","bazaar","shop","house","fairy","office","progression"],
		"unlocked_recipes": ["burger","fries","salad"],
		"recipe_mastery": {"burger":0,"fries":0,"salad":0},
		"upgrades": upgrades,
		"inventory": {"seeds":seeds,"crops":crops_stock,"fertilisers":{"basic_fertiliser":2,"advanced_fertiliser":1,"instant_fertiliser":0,"garden_time_skip":1},"boosters":{},"decorations":{}},
		"garden": plots,
		"staff_collection": {"chef_anna":{"count":1,"level":1},"waiter_leo":{"count":1,"level":1},"cashier_maya":{"count":1,"level":1},"cleaner_max":{"count":1,"level":1}},
		"garden_last_update_unix": TimeManager.unix_now(),
		"pity_counter": 0,
		"active_blessings": {},
		"placed_decorations": [],
		"prestige_tree": {},
		"achievements": {},
		"daily_quests": {"day":-1,"entries":{}},
		"tutorial": {"step":0,"completed":false},
		"offline_pending": {"seconds":0,"coins":0,"xp":0},
		"market": {"day":-1,"multipliers":{}},
		"settings": {"music":0.7,"sfx":0.8,"notifications":true},
		"stats": {"customers_served":0,"crops_harvested":0,"coins_earned":0,"angry_customers":0},
		"lifetime_stats": {"customers_served":0,"crops_harvested":0,"coins_earned":0,"angry_customers":0},
		"last_save_unix": TimeManager.unix_now()
	}
	EventBus.state_changed.emit("all")

func apply_loaded(loaded: Dictionary) -> void:
	var defaults := state.duplicate(true)
	state = loaded.duplicate(true)
	_merge_defaults(state, defaults)
	EventBus.state_changed.emit("all")

func _merge_defaults(target: Dictionary, defaults: Dictionary) -> void:
	for key in defaults:
		if not target.has(key):
			target[key] = defaults[key]
		elif target[key] is Dictionary and defaults[key] is Dictionary:
			_merge_defaults(target[key], defaults[key])

func upgrade_level(id: String) -> int:
	return int(state.get("upgrades", {}).get(id, 0))

func bonus(id: String) -> float:
	var item := DataManager.get_upgrade(id)
	return float(upgrade_level(id)) * float(item.get("value", 0.0)) + decoration_bonus(id) + prestige_tree_bonus(id)

func blessing(stat: String) -> float:
	var now := TimeManager.unix_now()
	var strongest := 0.0
	for value in state.get("active_blessings", {}).values():
		if str(value.get("stat", "")) == stat and int(value.get("ends_at", 0)) > now:
			strongest = max(strongest, float(value.get("value", 0.0)))
	return strongest

func add_item(category: String, id: String, amount: int) -> void:
	var group: Dictionary = state.inventory.get(category, {})
	group[id] = max(0, int(group.get(id, 0)) + amount)
	state.inventory[category] = group
	EventBus.state_changed.emit("inventory")

func item_count(category: String, id: String) -> int:
	return int(state.get("inventory", {}).get(category, {}).get(id, 0))

func activate_booster(id: String) -> bool:
	var item := DataManager.get_shop_item("boosters", id)
	if item.is_empty() or item_count("boosters", id) <= 0:
		EventBus.notification_requested.emit("No booster available", false)
		return false
	if str(item.effect) == "currency":
		EconomyManager.add(str(item.get("currency", "coins")), int(item.value), "booster " + id)
	else:
		var key := "booster_" + id
		var previous: Dictionary = state.active_blessings.get(key, {})
		if int(previous.get("ends_at", 0)) > TimeManager.unix_now():
			EventBus.notification_requested.emit("Booster is already active", false)
			return false
		state.active_blessings[key] = {"name":str(item.name),"stat":str(item.stat),"value":float(item.value),"ends_at":TimeManager.unix_now() + int(item.duration)}
	add_item("boosters", id, -1)
	EventBus.notification_requested.emit("Used " + str(item.name), true)
	SaveManager.queue_save()
	return true

func place_decoration(id: String) -> bool:
	var item := DataManager.get_shop_item("decorations", id)
	var placed: Array = state.get("placed_decorations", [])
	var slots := int(DataManager.shop.get("decoration_slots", 6))
	if item.is_empty() or placed.size() >= slots or placed.count(id) >= item_count("decorations", id):
		EventBus.notification_requested.emit("No free slot or owned copy", false)
		return false
	placed.append(id)
	state.placed_decorations = placed
	EventBus.state_changed.emit("decorations")
	EventBus.notification_requested.emit("Placed " + str(item.name), true)
	SaveManager.queue_save()
	return true

func remove_decoration(id: String) -> bool:
	var placed: Array = state.get("placed_decorations", [])
	var index := placed.find(id)
	if index < 0:
		return false
	placed.remove_at(index)
	state.placed_decorations = placed
	EventBus.state_changed.emit("decorations")
	EventBus.notification_requested.emit("Removed decoration", true)
	SaveManager.queue_save()
	return true

func decoration_bonus(stat: String) -> float:
	var total := 0.0
	for id in state.get("placed_decorations", []):
		var item := DataManager.get_shop_item("decorations", str(id))
		if str(item.get("stat", "")) == stat:
			total += float(item.get("value", 0.0))
	return total

func prestige_node_level(id: String) -> int:
	return int(state.get("prestige_tree", {}).get(id, 0))

func prestige_tree_bonus(stat: String) -> float:
	var total := 0.0
	for item in DataManager.balance.get("prestige_nodes", []):
		if str(item.get("stat", "")) == stat:
			total += prestige_node_level(str(item.id)) * float(item.get("value", 0.0))
	return total

func progression_stat(stat: String) -> int:
	if stat == "staff_collected":
		return state.get("staff_collection", {}).size()
	if stat == "player_level":
		return int(state.get("player", {}).get("level", 1))
	return int(state.get("lifetime_stats", {}).get(stat, 0))

func achievement_progress(id: String) -> int:
	var item := DataManager.get_achievement(id)
	return progression_stat(str(item.get("stat", "")))

func claim_achievement(id: String) -> bool:
	var item := DataManager.get_achievement(id)
	if item.is_empty() or bool(state.get("achievements", {}).get(id, false)):
		return false
	if achievement_progress(id) < int(item.get("target", 1)):
		EventBus.notification_requested.emit("Achievement is not complete", false)
		return false
	state.achievements[id] = true
	EconomyManager.add(str(item.reward_currency), int(item.reward), "achievement " + id)
	EventBus.notification_requested.emit("Achievement claimed: " + str(item.name), true)
	SaveManager.queue_save()
	return true

func ensure_daily_quests() -> void:
	var day := int(floor(float(TimeManager.unix_now()) / 86400.0))
	if int(state.get("daily_quests", {}).get("day", -1)) == day:
		return
	var entries: Dictionary = {}
	for item in DataManager.balance.get("daily_quests", []):
		entries[str(item.id)] = {"start":progression_stat(str(item.stat)),"claimed":false}
	state.daily_quests = {"day":day,"entries":entries}
	EventBus.state_changed.emit("daily_quests")
	SaveManager.queue_save()

func daily_quest_progress(id: String) -> int:
	ensure_daily_quests()
	var item := DataManager.get_daily_quest(id)
	var entry: Dictionary = state.daily_quests.entries.get(id, {})
	return max(0, progression_stat(str(item.get("stat", ""))) - int(entry.get("start", 0)))

func claim_daily_quest(id: String) -> bool:
	ensure_daily_quests()
	var item := DataManager.get_daily_quest(id)
	var entry: Dictionary = state.daily_quests.entries.get(id, {})
	if item.is_empty() or bool(entry.get("claimed", false)):
		return false
	if daily_quest_progress(id) < int(item.get("target", 1)):
		EventBus.notification_requested.emit("Daily quest is not complete", false)
		return false
	entry.claimed = true
	state.daily_quests.entries[id] = entry
	EconomyManager.add(str(item.reward_currency), int(item.reward), "daily quest " + id)
	EventBus.notification_requested.emit("Daily reward claimed: " + str(item.name), true)
	SaveManager.queue_save()
	return true
