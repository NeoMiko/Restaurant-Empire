extends BaseScreen

const FLOOR_SCRIPT = preload("res://scripts/restaurant/restaurant_floor.gd")
const TABLE_SCRIPT = preload("res://scripts/restaurant/restaurant_table.gd")
const CUSTOMER_SCRIPT = preload("res://scripts/customers/customer_agent.gd")
const CHEF_SCRIPT = preload("res://scripts/restaurant/chef_agent.gd")
const WAITER_SCRIPT = preload("res://scripts/restaurant/waiter_agent.gd")

var floor_node: Node2D
var tables: Array[Node] = []
var customer_pool: Array[Node] = []
var order_queue: Array[Dictionary] = []
var ready_dishes: Array[Dictionary] = []
var waiting_queue: Array[int] = []
var next_customer_id := 1
var next_order_id := 1
var spawn_elapsed := 3.5
var status_label: Label
var upgrade_buttons: Dictionary = {}
var chef: Node
var waiter: Node
var chefs: Array[Node] = []
var waiters: Array[Node] = []

func _ready() -> void:
	build_shell("Restaurant")
	SceneManager.current_scene_id = "restaurant"
	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 16)
	body.add_child(split)
	var floor_holder := PanelContainer.new()
	floor_holder.custom_minimum_size = Vector2(1380, 850)
	floor_holder.clip_contents = true
	floor_holder.add_theme_stylebox_override("panel", panel_style(DataManager.color("parchment"), 12, 4))
	split.add_child(floor_holder)
	var floor_control := Control.new()
	floor_control.custom_minimum_size = Vector2(1360, 850)
	floor_holder.add_child(floor_control)
	floor_node = FLOOR_SCRIPT.new()
	floor_control.add_child(floor_node)
	_create_tables()
	_create_staff()
	_create_customer_pool()
	_build_upgrade_panel(split)
	EventBus.spawn_customer_requested.connect(spawn_customer)
	EventBus.clear_customers_requested.connect(clear_customers)
	spawn_customer()

func _process(delta: float) -> void:
	spawn_elapsed += TimeManager.scaled(delta)
	var interval := float(DataManager.balance.simulation.get("spawn_interval", 4.0)) / (1.0 + GameManager.blessing("customers"))
	if spawn_elapsed >= interval:
		spawn_elapsed = 0.0
		spawn_customer()
	if is_instance_valid(status_label):
		status_label.text = "ACTIVE %d/%d | QUEUE %d | ORDERS %d | READY %d | SERVED %d" % [_active_count(), customer_pool.size(), waiting_queue.size(), order_queue.size(), ready_dishes.size(), int(GameManager.state.stats.get("customers_served", 0))]

func _create_tables() -> void:
	var count: int = min(8, 4 + GameManager.upgrade_level("table_count"))
	for _index in count:
		_add_table()

func _create_staff() -> void:
	for _index in 1 + GameManager.upgrade_level("kitchen_capacity"):
		_add_chef()
	_add_waiter()

func _add_table() -> void:
	## Two rows of four. Spacing is set by the table sprite's footprint plus its name plaque,
	## and keeps clear of the kitchen (below y 575) and the decoration column (beyond x 1130).
	var positions := [
		Vector2(300, 240), Vector2(520, 240), Vector2(740, 240), Vector2(960, 240),
		Vector2(300, 430), Vector2(520, 430), Vector2(740, 430), Vector2(960, 430)
	]
	if tables.size() >= positions.size():
		return
	var table: Node = TABLE_SCRIPT.new()
	floor_node.add_child(table)
	table.setup(tables.size(), positions[tables.size()], table_seat_capacity())
	tables.append(table)

## Cooks fill a 3-wide, 2-row grid inside the kitchen zone — kitchen_capacity tops out at 5,
## so six cooks is the most that ever has to fit.
func _add_chef() -> void:
	chef = CHEF_SCRIPT.new()
	floor_node.add_child(chef)
	chef.setup(self)
	var slot := chefs.size()
	chef.position = Vector2(320 + (slot % 3) * 90, 680 + floori(slot / 3.0) * 88)
	chefs.append(chef)

func _add_waiter() -> void:
	waiter = WAITER_SCRIPT.new()
	floor_node.add_child(waiter)
	waiter.setup(self)
	waiter.idle_position += Vector2(-90 * waiters.size(), 0)
	waiter.position = waiter.idle_position
	waiters.append(waiter)

func _create_customer_pool() -> void:
	var limit := int(DataManager.balance.simulation.get("spawn_limit", 12))
	for _index in limit:
		var customer: Node = CUSTOMER_SCRIPT.new()
		floor_node.add_child(customer)
		customer.deactivate()
		customer_pool.append(customer)

func _build_upgrade_panel(parent: HBoxContainer) -> void:
	var side := VBoxContainer.new()
	side.custom_minimum_size.x = 435
	side.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(side)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size.y = 70
	status_label.add_theme_font_size_override("font_size", 18)
	side.add_child(status_label)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(scroll)
	var list := VBoxContainer.new()
	list.custom_minimum_size.x = 400
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)
	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation", 10)
	list.add_child(heading)
	heading.add_child(ArtManager.icon_rect("ui_wax_seal_star", Vector2(44, 44)))
	var heading_label := Label.new()
	heading_label.text = "UPGRADES"
	heading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading_label.add_theme_font_size_override("font_size", 28)
	heading.add_child(heading_label)
	for item in DataManager.balance.get("upgrades", []):
		var id := str(item.id)
		var button := make_button("", func() -> void: _buy_upgrade(id), Vector2(390, 82), ArtManager.upgrade_icon(id), 52)
		button.add_theme_font_size_override("font_size", 17)
		upgrade_buttons[id] = button
		list.add_child(button)
	_refresh_upgrades()

func _refresh_upgrades() -> void:
	for item in DataManager.balance.get("upgrades", []):
		var id := str(item.id)
		var level := GameManager.upgrade_level(id)
		var maximum := int(item.get("max", 1))
		var cost := EconomyManager.upgrade_cost(id)
		upgrade_buttons[id].text = "%s  Lv.%d/%d\n%d coins" % [str(item.name), level, maximum, cost]
		var current_bonus := float(level) * float(item.get("value", 0.0))
		var next_bonus := float(min(level + 1, maximum)) * float(item.get("value", 0.0))
		var effect_text := "Current: %.0f%% • Next: %.0f%%" % [current_bonus * 100.0, next_bonus * 100.0]
		if id == "table_capacity":
			effect_text = "Current seats: %d • Next: %d" % [table_seat_capacity(), min(int(DataManager.balance.simulation.get("maximum_group_size", 6)), table_seat_capacity() + 1)]
		elif id == "waiter_capacity":
			effect_text = "Current tray: %d dishes • Next: %d" % [1 + level, 1 + min(level + 1, maximum)]
		upgrade_buttons[id].tooltip_text = "%s\n%s\nCost formula: base × 1.15^level" % [str(item.name), effect_text]
		upgrade_buttons[id].disabled = level >= maximum

func _buy_upgrade(id: String) -> void:
	if EconomyManager.purchase_upgrade(id):
		if id == "table_count":
			_add_table()
		elif id == "kitchen_capacity":
			_add_chef()
		elif id == "table_capacity":
			for table in tables:
				table.seat_capacity = table_seat_capacity()
				table.queue_redraw()
		_refresh_upgrades()
		refresh_currency_bar()

func spawn_customer() -> void:
	for customer in customer_pool:
		if not customer.active:
			var types: Array = DataManager.people.get("customers", [])
			customer.activate(self, next_customer_id, types.pick_random())
			next_customer_id += 1
			return

func request_table(customer_id: int) -> Node:
	if waiting_queue.is_empty() or waiting_queue[0] != customer_id:
		return null
	for table in tables:
		if int(table.state) == 0 and table.reserve(customer_id):
			waiting_queue.pop_front()
			return table
	return null

func join_table_queue(customer_id: int) -> void:
	if customer_id not in waiting_queue:
		waiting_queue.append(customer_id)

func leave_table_queue(customer_id: int) -> void:
	waiting_queue.erase(customer_id)

## Guests line up leftwards from the entrance door drawn at x=860. Spacing has to clear the
## per-guest caption, which is wider than the guest sprite.
func queue_position(customer_id: int) -> Vector2:
	var index := waiting_queue.find(customer_id)
	if index < 0:
		return Vector2(860, 130)
	return Vector2(860 - min(index, 6) * 115, 130)

func table_seat_capacity() -> int:
	var base := int(DataManager.balance.simulation.get("base_table_capacity", 2))
	return min(int(DataManager.balance.simulation.get("maximum_group_size", 6)), base + GameManager.upgrade_level("table_capacity"))

func choose_recipe(customer_data: Dictionary) -> Dictionary:
	var unlocked: Array = GameManager.state.get("unlocked_recipes", [])
	var preferred: Array[Dictionary] = []
	for recipe_id in customer_data.get("preferences", []):
		if recipe_id in unlocked:
			var recipe := DataManager.get_recipe(str(recipe_id))
			if not recipe.is_empty():
				preferred.append(recipe)
	if not preferred.is_empty():
		return preferred.pick_random()
	var available: Array[Dictionary] = []
	for recipe_id in unlocked:
		var recipe := DataManager.get_recipe(str(recipe_id))
		if not recipe.is_empty():
			available.append(recipe)
	return DataManager.get_recipe("burger") if available.is_empty() else available.pick_random()

func place_order(customer_id: int, table_index: int, recipe: Dictionary, quantity: int = 1) -> int:
	var order := {
		"id":next_order_id,"customer_id":customer_id,"table_index":table_index,
		"recipe_id":str(recipe.id),"recipe_name":str(recipe.name),
		"quantity":max(1, quantity),
		"cook_time":float(recipe.cook_time) * (1.0 + max(0, quantity - 1) * float(DataManager.balance.simulation.get("group_cook_time_per_guest", 0.45))),
		"created_at":TimeManager.unix_now()
	}
	order_queue.append(order)
	next_order_id += 1
	return int(order.id)

func take_next_order() -> Dictionary:
	if order_queue.is_empty():
		return {}
	return order_queue.pop_front()

func finish_order(order: Dictionary) -> void:
	ready_dishes.append(order)

func take_ready_dish() -> Dictionary:
	var batch := take_ready_dishes(1)
	return {} if batch.is_empty() else batch[0]

func take_ready_dishes(capacity: int) -> Array[Dictionary]:
	var batch: Array[Dictionary] = []
	while not ready_dishes.is_empty() and batch.size() < max(1, capacity):
		batch.append(ready_dishes.pop_front())
	return batch

func table_for_order(order: Dictionary) -> Node:
	var index := int(order.get("table_index", -1))
	if index < 0 or index >= tables.size():
		return null
	var table: Node = tables[index]
	return table if int(table.customer_id) == int(order.get("customer_id", -1)) else null

func deliver_dish(order: Dictionary) -> void:
	for customer in customer_pool:
		if customer.active and customer.uid == int(order.get("customer_id", -1)):
			customer.receive_food(int(order.id))
			return

func customer_paid(customer: Node) -> void:
	var payment: Dictionary = EconomyManager.calculate_meal_payment(customer.recipe, float(customer.customer_data.get("spend", 1.0)), float(customer.customer_data.get("tip", 1.0)), int(customer.group_size))
	EconomyManager.add("coins", int(payment.coins), "meal " + str(customer.recipe.name))
	var reputation_gain := 1
	if randf() < GameManager.bonus("restaurant_reputation"):
		reputation_gain += 1
	EconomyManager.add("reputation", reputation_gain, "satisfied customer")
	EconomyManager.add_player_xp(int(payment.xp))
	GameManager.state.stats.customers_served = int(GameManager.state.stats.get("customers_served", 0)) + int(customer.group_size)
	GameManager.state.lifetime_stats.customers_served = int(GameManager.state.lifetime_stats.get("customers_served", 0)) + int(customer.group_size)
	var customers_per_level := int(DataManager.balance.get("prestige", {}).get("customers_per_restaurant_level", 10))
	GameManager.state.player.restaurant_level = 1 + int(GameManager.state.stats.customers_served / max(1.0, float(customers_per_level)))
	var recipe_id := str(customer.recipe.id)
	GameManager.state.recipe_mastery[recipe_id] = int(GameManager.state.recipe_mastery.get(recipe_id, 0)) + int(customer.group_size)
	EventBus.notification_requested.emit("+%d coins • group x%d%s" % [int(payment.coins), int(customer.group_size), " (tip %d)" % int(payment.tip) if int(payment.tip) > 0 else ""], true)
	SaveManager.queue_save()

func customer_angry(_customer: Node) -> void:
	leave_table_queue(int(_customer.uid))
	GameManager.state.stats.angry_customers = int(GameManager.state.stats.get("angry_customers", 0)) + int(_customer.group_size)
	GameManager.state.lifetime_stats.angry_customers = int(GameManager.state.lifetime_stats.get("angry_customers", 0)) + int(_customer.group_size)
	EventBus.notification_requested.emit("A customer left angry", false)

func recycle_customer(customer: Node) -> void:
	leave_table_queue(int(customer.uid))
	customer.deactivate()

func clear_customers() -> void:
	for customer in customer_pool:
		customer.deactivate()
	for table in tables:
		table.release_immediately()
	order_queue.clear()
	ready_dishes.clear()
	waiting_queue.clear()
	EventBus.notification_requested.emit("Restaurant cleared", true)

func _active_count() -> int:
	var count := 0
	for customer in customer_pool:
		if customer.active:
			count += 1
	return count
