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
	floor_holder.add_theme_stylebox_override("panel", panel_style(Color("#F4E1C1"), 12))
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
		status_label.text = "ACTIVE %d/%d  |  ORDERS %d  |  READY %d  |  SERVED %d" % [_active_count(), customer_pool.size(), order_queue.size(), ready_dishes.size(), int(GameManager.state.stats.get("customers_served", 0))]

func _create_tables() -> void:
	var count: int = min(8, 4 + GameManager.upgrade_level("table_count"))
	for _index in count:
		_add_table()

func _create_staff() -> void:
	for _index in 1 + GameManager.upgrade_level("kitchen_capacity"):
		_add_chef()
	for _index in 1 + GameManager.upgrade_level("waiter_capacity"):
		_add_waiter()

func _add_table() -> void:
	var positions := [Vector2(330, 200), Vector2(670, 200), Vector2(1010, 200), Vector2(330, 450), Vector2(670, 450), Vector2(1010, 450), Vector2(820, 590), Vector2(1120, 590)]
	if tables.size() >= positions.size():
		return
	var table: Node = TABLE_SCRIPT.new()
	floor_node.add_child(table)
	table.setup(tables.size(), positions[tables.size()])
	tables.append(table)

func _add_chef() -> void:
	chef = CHEF_SCRIPT.new()
	floor_node.add_child(chef)
	chef.setup(self)
	chef.position += Vector2(100 * chefs.size(), 0)
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
	var heading := Label.new()
	heading.text = "UPGRADES"
	heading.add_theme_font_size_override("font_size", 28)
	list.add_child(heading)
	for item in DataManager.balance.get("upgrades", []):
		var id := str(item.id)
		var button := make_button("", func() -> void: _buy_upgrade(id), Vector2(390, 72))
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
		upgrade_buttons[id].disabled = level >= maximum

func _buy_upgrade(id: String) -> void:
	if EconomyManager.purchase_upgrade(id):
		if id == "table_count":
			_add_table()
		elif id == "kitchen_capacity":
			_add_chef()
		elif id == "waiter_capacity":
			_add_waiter()
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
	for table in tables:
		if int(table.state) == 0 and table.reserve(customer_id):
			return table
	return null

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

func place_order(customer_id: int, table_index: int, recipe: Dictionary) -> int:
	var order := {
		"id":next_order_id,"customer_id":customer_id,"table_index":table_index,
		"recipe_id":str(recipe.id),"recipe_name":str(recipe.name),
		"cook_time":float(recipe.cook_time),"created_at":TimeManager.unix_now()
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
	if ready_dishes.is_empty():
		return {}
	return ready_dishes.pop_front()

func table_for_order(order: Dictionary) -> Node:
	var index := int(order.get("table_index", -1))
	return tables[index] if index >= 0 and index < tables.size() else null

func deliver_dish(order: Dictionary) -> void:
	for customer in customer_pool:
		if customer.active and customer.uid == int(order.get("customer_id", -1)):
			customer.receive_food(int(order.id))
			return

func customer_paid(customer: Node) -> void:
	var payment: Dictionary = EconomyManager.calculate_meal_payment(customer.recipe, float(customer.customer_data.get("spend", 1.0)), float(customer.customer_data.get("tip", 1.0)))
	EconomyManager.add("coins", int(payment.coins), "meal " + str(customer.recipe.name))
	var reputation_gain := 1
	if randf() < GameManager.bonus("restaurant_reputation"):
		reputation_gain += 1
	EconomyManager.add("reputation", reputation_gain, "satisfied customer")
	EconomyManager.add_player_xp(int(payment.xp))
	GameManager.state.stats.customers_served = int(GameManager.state.stats.get("customers_served", 0)) + 1
	var recipe_id := str(customer.recipe.id)
	GameManager.state.recipe_mastery[recipe_id] = int(GameManager.state.recipe_mastery.get(recipe_id, 0)) + 1
	EventBus.notification_requested.emit("+%d coins%s" % [int(payment.coins), " (tip %d)" % int(payment.tip) if int(payment.tip) > 0 else ""], true)
	SaveManager.queue_save()

func customer_angry(_customer: Node) -> void:
	GameManager.state.stats.angry_customers = int(GameManager.state.stats.get("angry_customers", 0)) + 1
	EventBus.notification_requested.emit("A customer left angry", false)

func recycle_customer(customer: Node) -> void:
	customer.deactivate()

func clear_customers() -> void:
	for customer in customer_pool:
		customer.deactivate()
	for table in tables:
		table.release_immediately()
	order_queue.clear()
	ready_dishes.clear()
	EventBus.notification_requested.emit("Restaurant cleared", true)

func _active_count() -> int:
	var count := 0
	for customer in customer_pool:
		if customer.active:
			count += 1
	return count
