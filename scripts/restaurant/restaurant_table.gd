extends Node2D

enum TableState { FREE, RESERVED, OCCUPIED, WAITING_FOR_CLEANING, CLEANING }

var table_index := 0
var state: TableState = TableState.FREE
var customer_id := -1
var cleaning_remaining := 0.0
var seat_capacity := 2

func setup(index: int, at_position: Vector2, capacity: int = 2) -> void:
	table_index = index
	position = at_position
	seat_capacity = max(1, capacity)
	set_process(false)
	queue_redraw()

func reserve(id: int) -> bool:
	if state != TableState.FREE:
		return false
	state = TableState.RESERVED
	customer_id = id
	queue_redraw()
	return true

func occupy() -> void:
	state = TableState.OCCUPIED
	queue_redraw()

func start_cleaning() -> void:
	state = TableState.WAITING_FOR_CLEANING
	cleaning_remaining = float(DataManager.balance.simulation.get("cleaning_time", 2.5))
	state = TableState.CLEANING
	set_process(true)
	queue_redraw()

func release_immediately() -> void:
	state = TableState.FREE
	customer_id = -1
	cleaning_remaining = 0.0
	set_process(false)
	queue_redraw()

func _process(delta: float) -> void:
	cleaning_remaining -= TimeManager.scaled(delta)
	if cleaning_remaining <= 0.0:
		release_immediately()
	else:
		queue_redraw()

func service_position() -> Vector2:
	return position + Vector2(0, 95)

func customer_position() -> Vector2:
	return position + Vector2(0, -95)

func _draw() -> void:
	var fill := DataManager.color("table_free") if state == TableState.FREE else DataManager.color("table_busy")
	draw_rect(Rect2(-65, -45, 130, 90), fill, true)
	var chair_positions := [Vector2(-45, -78), Vector2(-45, 53), Vector2(-92, -12), Vector2(67, -12), Vector2(-92, 28), Vector2(67, 28)]
	for index in min(seat_capacity, chair_positions.size()):
		draw_rect(Rect2(chair_positions[index], Vector2(25, 25)), Color("#4B3A32"), true)
	var names := ["FREE", "RESERVED", "OCCUPIED", "DIRTY", "CLEANING"]
	draw_string(ThemeDB.fallback_font, Vector2(-62, 8), "T%d %s • %d seats" % [table_index + 1, names[state], seat_capacity], HORIZONTAL_ALIGNMENT_CENTER, 124, 14, Color.WHITE)
	if state == TableState.CLEANING:
		draw_string(ThemeDB.fallback_font, Vector2(-45, 30), "%.1fs" % cleaning_remaining, HORIZONTAL_ALIGNMENT_CENTER, 90, 14, Color.WHITE)
