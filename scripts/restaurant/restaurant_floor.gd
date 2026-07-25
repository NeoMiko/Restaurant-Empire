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
