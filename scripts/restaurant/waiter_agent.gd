extends Node2D

enum WaiterState { IDLE, TO_COUNTER, TO_TABLE, RETURNING }

var restaurant: Node
var state: WaiterState = WaiterState.IDLE
var dishes: Array[Dictionary] = []
var target := Vector2.ZERO
var idle_position := Vector2(1180, 745)

func setup(controller: Node) -> void:
	restaurant = controller
	position = idle_position
	target = idle_position
	queue_redraw()

func _process(delta: float) -> void:
	if state == WaiterState.IDLE:
		var capacity := 1 + GameManager.upgrade_level("waiter_capacity")
		dishes = restaurant.take_ready_dishes(capacity)
		if not dishes.is_empty():
			state = WaiterState.TO_COUNTER
			target = Vector2(860, 690)
			queue_redraw()
		return
	var speed := float(DataManager.balance.simulation.get("waiter_speed", 250.0)) * (1.0 + GameManager.bonus("waiter_speed") + GameManager.blessing("waiter_speed"))
	position = position.move_toward(target, speed * TimeManager.scaled(delta))
	if position.distance_to(target) > 5.0:
		return
	match state:
		WaiterState.TO_COUNTER:
			_advance_delivery()
		WaiterState.TO_TABLE:
			if not dishes.is_empty():
				restaurant.deliver_dish(dishes.pop_front())
			_advance_delivery()
		WaiterState.RETURNING:
			state = WaiterState.IDLE
	queue_redraw()

func _advance_delivery() -> void:
	while not dishes.is_empty():
		var table: Node = restaurant.table_for_order(dishes[0])
		if table != null:
			state = WaiterState.TO_TABLE
			target = table.service_position()
			return
		dishes.pop_front()
	state = WaiterState.RETURNING
	target = idle_position

func _draw() -> void:
	draw_rect(Rect2(-42, -55, 84, 110), DataManager.color("waiter"), true)
	draw_string(ThemeDB.fallback_font, Vector2(-38, 5), "WAITER", HORIZONTAL_ALIGNMENT_CENTER, 76, 17, Color("#1A1A1A"))
	for index in min(dishes.size(), 6):
		draw_circle(Vector2(-30 + index * 12, -70), 10, DataManager.color("accent"))
	if not dishes.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(-45, -88), "TRAY %d/%d" % [dishes.size(), 1 + GameManager.upgrade_level("waiter_capacity")], HORIZONTAL_ALIGNMENT_CENTER, 90, 12, Color.WHITE)
