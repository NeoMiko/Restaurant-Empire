extends Node2D

enum WaiterState { IDLE, TO_COUNTER, TO_TABLE, RETURNING }

var restaurant: Node
var state: WaiterState = WaiterState.IDLE
var dish: Dictionary = {}
var target := Vector2.ZERO
var idle_position := Vector2(1180, 745)

func setup(controller: Node) -> void:
	restaurant = controller
	position = idle_position
	target = idle_position
	queue_redraw()

func _process(delta: float) -> void:
	if state == WaiterState.IDLE:
		dish = restaurant.take_ready_dish()
		if not dish.is_empty():
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
			var table: Node = restaurant.table_for_order(dish)
			if table == null:
				state = WaiterState.RETURNING
				target = idle_position
			else:
				state = WaiterState.TO_TABLE
				target = table.service_position()
		WaiterState.TO_TABLE:
			restaurant.deliver_dish(dish)
			dish = {}
			state = WaiterState.RETURNING
			target = idle_position
		WaiterState.RETURNING:
			state = WaiterState.IDLE
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-42, -55, 84, 110), DataManager.color("waiter"), true)
	draw_string(ThemeDB.fallback_font, Vector2(-38, 5), "WAITER", HORIZONTAL_ALIGNMENT_CENTER, 76, 17, Color("#1A1A1A"))
	if not dish.is_empty():
		draw_circle(Vector2(0, -70), 14, DataManager.color("accent"))
