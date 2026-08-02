extends Node2D

enum CustomerState {
	SPAWNING, ENTERING, WAITING_FOR_TABLE, WALKING_TO_TABLE,
	READING_MENU, ORDERING, WAITING_FOR_FOOD, EATING,
	PAYING, LEAVING, ANGRY_LEAVING
}

const STATE_NAMES := ["SPAWN", "ENTER", "WAIT TABLE", "TO TABLE", "MENU", "ORDER", "WAIT FOOD", "EATING", "PAYING", "LEAVING", "ANGRY"]
var restaurant: Node
var uid := -1
var customer_data: Dictionary = {}
var state: CustomerState = CustomerState.SPAWNING
var active := false
var patience := 0.0
var timer := 0.0
var target := Vector2.ZERO
var table: Node
var recipe: Dictionary = {}
var order_id := -1
var satisfaction := 1.0
var group_size := 1

func activate(controller: Node, new_uid: int, data: Dictionary) -> void:
	restaurant = controller
	uid = new_uid
	customer_data = data
	active = true
	visible = true
	position = Vector2(860, -35)
	target = Vector2(860, 130)
	patience = float(DataManager.balance.simulation.get("customer_patience", 42.0)) * float(data.get("patience", 1.0)) * (1.0 + GameManager.bonus("customer_patience"))
	timer = 0.2
	table = null
	recipe = {}
	order_id = -1
	satisfaction = 1.0
	var maximum_group: int = min(int(restaurant.table_seat_capacity()), int(DataManager.balance.simulation.get("maximum_group_size", 6)))
	group_size = randi_range(1, max(1, maximum_group))
	state = CustomerState.SPAWNING
	add_to_group("customer")
	set_process(true)
	queue_redraw()

func deactivate() -> void:
	active = false
	visible = false
	set_process(false)
	if is_in_group("customer"):
		remove_from_group("customer")

func _process(delta: float) -> void:
	if not active:
		return
	var step := TimeManager.scaled(delta)
	if state in [CustomerState.WAITING_FOR_TABLE, CustomerState.READING_MENU, CustomerState.ORDERING, CustomerState.WAITING_FOR_FOOD]:
		patience -= step
		if patience <= 0.0:
			_become_angry()
			return
	match state:
		CustomerState.SPAWNING:
			timer -= step
			if timer <= 0.0:
				state = CustomerState.ENTERING
		CustomerState.ENTERING:
			if _move(step):
				restaurant.join_table_queue(uid)
				state = CustomerState.WAITING_FOR_TABLE
		CustomerState.WAITING_FOR_TABLE:
			target = restaurant.queue_position(uid)
			_move(step)
			table = restaurant.request_table(uid)
			if table != null:
				target = table.customer_position()
				state = CustomerState.WALKING_TO_TABLE
		CustomerState.WALKING_TO_TABLE:
			if _move(step):
				table.occupy()
				timer = randf_range(float(DataManager.balance.simulation.get("menu_read_min", 2.0)), float(DataManager.balance.simulation.get("menu_read_max", 4.0)))
				state = CustomerState.READING_MENU
		CustomerState.READING_MENU:
			timer -= step
			if timer <= 0.0:
				timer = float(DataManager.balance.simulation.get("order_time", 1.2))
				state = CustomerState.ORDERING
		CustomerState.ORDERING:
			timer -= step
			if timer <= 0.0:
				recipe = restaurant.choose_recipe(customer_data)
				order_id = restaurant.place_order(uid, table.table_index, recipe, group_size)
				state = CustomerState.WAITING_FOR_FOOD
		CustomerState.WAITING_FOR_FOOD:
			pass
		CustomerState.EATING:
			timer -= step
			if timer <= 0.0:
				timer = float(DataManager.balance.simulation.get("payment_time", 1.0))
				state = CustomerState.PAYING
		CustomerState.PAYING:
			timer -= step
			if timer <= 0.0:
				restaurant.customer_paid(self)
				table.start_cleaning()
				target = Vector2(860, -50)
				state = CustomerState.LEAVING
		CustomerState.LEAVING, CustomerState.ANGRY_LEAVING:
			if _move(step):
				restaurant.recycle_customer(self)
	queue_redraw()

func receive_food(received_order_id: int) -> void:
	if state == CustomerState.WAITING_FOR_FOOD and received_order_id == order_id:
		timer = randf_range(float(DataManager.balance.simulation.get("eat_min", 5.0)), float(DataManager.balance.simulation.get("eat_max", 8.0)))
		state = CustomerState.EATING

func _move(step: float) -> bool:
	var speed := float(DataManager.balance.simulation.get("customer_speed", 190.0)) * float(customer_data.get("speed", 1.0))
	position = position.move_toward(target, speed * step)
	return position.distance_to(target) <= 5.0

func _become_angry() -> void:
	restaurant.leave_table_queue(uid)
	satisfaction = 0.0
	if table != null:
		table.release_immediately()
	restaurant.customer_angry(self)
	target = Vector2(860, -50)
	state = CustomerState.ANGRY_LEAVING

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var ink := DataManager.color("ink")
	var color := DataManager.color("danger") if state == CustomerState.ANGRY_LEAVING else DataManager.color("customer")
	ArtManager.draw_character(self, Rect2(-32, -36, 64, 72), color, "customers")
	draw_string(font, Vector2(-55, 56), "%s #%d ×%d" % [STATE_NAMES[state], uid, group_size], HORIZONTAL_ALIGNMENT_CENTER, 110, 12, ink)
	## Once a dish is chosen the guest carries its icon, so the room reads at a glance.
	if not recipe.is_empty() and state >= CustomerState.WAITING_FOR_FOOD and state <= CustomerState.PAYING:
		ArtManager.draw_icon(self, str(recipe.get("id", "")), Vector2(0, -76), Vector2(46, 46))
	if active and state < CustomerState.EATING:
		var max_patience := float(DataManager.balance.simulation.get("customer_patience", 42.0)) * float(customer_data.get("patience", 1.0)) * (1.0 + GameManager.bonus("customer_patience"))
		var fraction: float = clamp(patience / max(0.1, max_patience), 0.0, 1.0)
		var bar := DataManager.color("success") if fraction > 0.5 else (DataManager.color("accent") if fraction > 0.25 else DataManager.color("danger"))
		ArtManager.draw_meter(self, Rect2(-35, -50, 70, 10), fraction, bar)
