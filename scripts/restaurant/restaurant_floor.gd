extends Node2D

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 0, 1360, 850), Color("#F4E1C1"), true)
	draw_rect(Rect2(20, 610, 430, 220), DataManager.color("kitchen"), true)
	draw_string(font, Vector2(45, 655), "KITCHEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.WHITE)
	draw_rect(Rect2(470, 710, 610, 100), DataManager.color("counter"), true)
	draw_string(font, Vector2(680, 770), "COUNTER / PICKUP", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("#1A1A1A"))
	draw_rect(Rect2(600, 0, 170, 64), Color("#7A5235"), true)
	draw_string(font, Vector2(630, 42), "ENTRANCE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
	draw_rect(Rect2(20, 20, 220, 70), Color("#E9C46A"), true)
	draw_string(font, Vector2(40, 64), "ORDER POINT", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#1A1A1A"))
	draw_string(font, Vector2(1100, 800), "WAITER IDLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#333333"))
	draw_rect(Rect2(95, 110, 90, 100), DataManager.color("cashier"), true)
	draw_string(font, Vector2(102, 165), "CASHIER", HORIZONTAL_ALIGNMENT_CENTER, 76, 16, Color("#222222"))
	draw_rect(Rect2(1110, 560, 90, 100), DataManager.color("cleaner"), true)
	draw_string(font, Vector2(1115, 615), "CLEANER", HORIZONTAL_ALIGNMENT_CENTER, 80, 15, Color("#222222"))
	draw_string(font, Vector2(1080, 682), "AUTO TABLE RESET", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#333333"))
	var decoration_positions := [Vector2(1160, 110), Vector2(1240, 110), Vector2(1160, 210), Vector2(1240, 210), Vector2(1160, 310), Vector2(1240, 310)]
	var placed: Array = GameManager.state.get("placed_decorations", [])
	for index in min(placed.size(), decoration_positions.size()):
		var id := str(placed[index])
		var item := DataManager.get_shop_item("decorations", id)
		var color := Color("#7AC74F") if id == "potted_plant" else (Color("#FFD166") if id == "warm_lamp" else Color("#4EA5D9"))
		draw_circle(decoration_positions[index], 28, color)
		draw_string(font, decoration_positions[index] + Vector2(-55, 50), str(item.get("name", id)), HORIZONTAL_ALIGNMENT_CENTER, 110, 13, Color("#222222"))
