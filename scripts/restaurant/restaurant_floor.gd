extends Node2D

const FLOOR_SIZE := Vector2(1360, 850)
const TILE := 68.0

const DECORATION_SLOTS := [
	Vector2(1180, 120), Vector2(1275, 120), Vector2(1180, 225),
	Vector2(1275, 225), Vector2(1180, 330), Vector2(1275, 330)
]

func _ready() -> void:
	EventBus.state_changed.connect(_on_state_changed)
	queue_redraw()

func _on_state_changed(key: String) -> void:
	if key in ["decorations", "all"]:
		queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var ink := DataManager.color("ink")
	_draw_tiles()
	## The kitchen zone is wide enough to hold the station on the left and the cooks on the
	## right; chef_agent spawns at x=330 and steps right for each extra cook.
	_draw_zone(Rect2(20, 575, 580, 275), DataManager.color("kitchen"))
	ArtManager.draw_icon(self, "kitchen_station", Vector2(110, 706), Vector2(165, 165))
	draw_string(font, Vector2(40, 612), "KITCHEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, DataManager.color("parchment"))

	_draw_zone(Rect2(630, 700, 560, 110), DataManager.color("counter"))
	ArtManager.draw_icon(self, "counter", Vector2(730, 755), Vector2(210, 105))
	draw_string(font, Vector2(850, 765), "COUNTER / PICKUP", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, ink)

	ArtManager.draw_icon(self, "entrance_door", Vector2(860, 40), Vector2(132, 78))
	draw_string(font, Vector2(935, 48), "ENTRANCE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, ink)

	_draw_post(Rect2(20, 20, 230, 78), DataManager.color("accent"), "hud_coins", "ORDER POINT", font, ink)
	_draw_post(Rect2(95, 120, 110, 110), DataManager.color("cashier"), "hud_coins", "CASHIER", font, ink)
	_draw_post(Rect2(1240, 460, 110, 110), DataManager.color("cleaner"), "table_cleaning", "CLEANER", font, ink)

	var placed: Array = GameManager.state.get("placed_decorations", [])
	for index in min(placed.size(), DECORATION_SLOTS.size()):
		var id := str(placed[index])
		var centre: Vector2 = DECORATION_SLOTS[index]
		if not ArtManager.draw_icon(self, id, centre, Vector2(84, 84)):
			draw_circle(centre, 30, DataManager.color("accent"))
		var item := DataManager.get_shop_item("decorations", id)
		draw_string(font, centre + Vector2(-52, 62), str(item.get("name", id)), HORIZONTAL_ALIGNMENT_CENTER, 104, 13, ink)

## Parchment boards with a faint seam grid — reads as a floor rather than a flat fill.
func _draw_tiles() -> void:
	draw_rect(Rect2(Vector2.ZERO, FLOOR_SIZE), DataManager.color("parchment"), true)
	var seam := DataManager.color("parchment_alt")
	var x := TILE
	while x < FLOOR_SIZE.x:
		draw_line(Vector2(x, 0), Vector2(x, FLOOR_SIZE.y), seam, 2.0)
		x += TILE
	var y := TILE
	while y < FLOOR_SIZE.y:
		draw_line(Vector2(0, y), Vector2(FLOOR_SIZE.x, y), seam, 2.0)
		y += TILE

func _draw_zone(rect: Rect2, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(14)
	style.set_border_width_all(4)
	style.border_color = DataManager.color("outline")
	draw_style_box(style, rect)

func _draw_post(rect: Rect2, color: Color, icon_id: String, label: String, font: Font, ink: Color) -> void:
	_draw_zone(rect, color)
	ArtManager.draw_icon(self, icon_id, rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.38), rect.size * 0.5)
	draw_string(font, rect.position + Vector2(4, rect.size.y - 10), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 8, 16, ink)
