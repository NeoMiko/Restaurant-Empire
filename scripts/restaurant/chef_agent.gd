extends Node2D

enum ChefState { IDLE, COOKING }

var restaurant: Node
var state: ChefState = ChefState.IDLE
var current_order: Dictionary = {}
var remaining := 0.0
var total := 1.0

func setup(controller: Node) -> void:
	restaurant = controller
	position = Vector2(320, 680)
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
	var font := ThemeDB.fallback_font
	ArtManager.draw_character(self, Rect2(-42, -46, 84, 92), DataManager.color("chef"), "chef_speed")
	draw_string(font, Vector2(-42, 62), "CHEF", HORIZONTAL_ALIGNMENT_CENTER, 84, 16, DataManager.color("parchment"))
	if state != ChefState.COOKING:
		return
	## The dish being cooked shows as its own icon above the cook's head.
	ArtManager.draw_icon(self, str(current_order.get("recipe_id", "")), Vector2(0, -72), Vector2(46, 46))
	var progress: float = clamp(1.0 - remaining / max(0.01, total), 0.0, 1.0)
	ArtManager.draw_meter(self, Rect2(-42, 70, 84, 12), progress, DataManager.color("success"))
