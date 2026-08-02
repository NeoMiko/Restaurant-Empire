extends Node2D

enum WaiterState { IDLE, TO_COUNTER, TO_TABLE, RETURNING }

var restaurant: Node
var state: WaiterState = WaiterState.IDLE
var dishes: Array[Dictionary] = []
var target := Vector2.ZERO
var idle_position := Vector2(1270, 700)

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
	var font := ThemeDB.fallback_font
	ArtManager.draw_character(self, Rect2(-44, -55, 88, 110), DataManager.color("waiter"), "waiter_tray")
	draw_string(font, Vector2(-44, 74), "WAITER", HORIZONTAL_ALIGNMENT_CENTER, 88, 17, DataManager.color("ink"))
	if dishes.is_empty():
		return
	## The tray shows what is actually being carried.
	var carried: int = min(dishes.size(), 4)
	for index in carried:
		var offset := Vector2((index - (carried - 1) * 0.5) * 42.0, -82.0)
		if not ArtManager.draw_icon(self, str(dishes[index].get("recipe_id", "")), offset, Vector2(38, 38)):
			draw_circle(offset, 10, DataManager.color("accent"))
	draw_string(font, Vector2(-55, -104), "TRAY %d/%d" % [dishes.size(), 1 + GameManager.upgrade_level("waiter_capacity")], HORIZONTAL_ALIGNMENT_CENTER, 110, 14, DataManager.color("ink"))
