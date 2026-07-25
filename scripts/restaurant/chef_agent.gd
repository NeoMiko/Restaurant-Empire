extends Node2D

enum ChefState { IDLE, COOKING }

var restaurant: Node
var state: ChefState = ChefState.IDLE
var current_order: Dictionary = {}
var remaining := 0.0
var total := 1.0

func setup(controller: Node) -> void:
	restaurant = controller
	position = Vector2(220, 720)
	queue_redraw()

func _process(delta: float) -> void:
	if state == ChefState.IDLE:
		current_order = restaurant.take_next_order()
		if not current_order.is_empty():
			state = ChefState.COOKING
			total = float(current_order.get("cook_time", 5.0)) / (1.0 + GameManager.bonus("kitchen_speed") + GameManager.blessing("chef_speed"))
			remaining = total
			queue_redraw()
		return
	remaining -= TimeManager.scaled(delta)
	if remaining <= 0.0:
		restaurant.finish_order(current_order)
		current_order = {}
		state = ChefState.IDLE
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-55, -45, 110, 90), DataManager.color("chef"), true)
	draw_string(ThemeDB.fallback_font, Vector2(-42, 5), "CHEF", HORIZONTAL_ALIGNMENT_CENTER, 84, 20, Color("#222222"))
	if state == ChefState.COOKING:
		draw_rect(Rect2(-55, 55, 110, 12), Color("#1D2630"), true)
		var progress: float = clamp(1.0 - remaining / max(0.01, total), 0.0, 1.0)
		draw_rect(Rect2(-55, 55, 110 * progress, 12), DataManager.color("success"), true)
		draw_string(ThemeDB.fallback_font, Vector2(-65, 88), str(current_order.get("recipe_name", "")), HORIZONTAL_ALIGNMENT_CENTER, 130, 16, Color.WHITE)
